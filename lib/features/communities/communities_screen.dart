import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/backend/community_response.dart';
import 'package:Zentry/core/providers/auth_controller.dart';
import 'package:Zentry/core/providers/community_controller.dart';
import 'package:Zentry/core/widgets/zentry_network_image.dart';
import 'package:Zentry/features/communities/community_detail_screen.dart';
import 'package:Zentry/features/communities/create_community_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

/// Listado de comunidades REALES del backend (`GET /api/core/communities`).
/// Antes leía `CommunityController.communities` (SharedPreferences, sólo en
/// este dispositivo); ahora una comunidad creada en un teléfono aparece
/// igual en tablet/otro dispositivo con la misma cuenta.
class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityController>().loadBackendCommunities();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _query = query);
    await context.read<CommunityController>().loadBackendCommunities(
      search: query,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;
    final controller = context.watch<CommunityController>();
    final user = context.watch<AuthController>().currentUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          l10n.communitiesScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: l10n.communitiesCreateButton,
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateCommunityScreen(),
                ),
              );
              if (created == true && mounted) {
                context.read<CommunityController>().loadBackendCommunities();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context
            .read<CommunityController>()
            .loadBackendCommunities(search: _query),
        child: _buildBody(l10n, accentColor, controller, user?.id),
      ),
    );
  }

  Widget _buildBody(
    AppLocalizations l10n,
    Color accentColor,
    CommunityController controller,
    int? currentUserId,
  ) {
    final all = controller.backendCommunities;

    if (controller.communitiesLoading && !controller.communitiesLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.communitiesError != null && all.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.error_outline, color: Colors.grey.shade600, size: 48),
          const SizedBox(height: 12),
          Center(
            child: Text(
              controller.communitiesError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () => context
                  .read<CommunityController>()
                  .loadBackendCommunities(search: _query),
              child: Text(l10n.commonRetry),
            ),
          ),
        ],
      );
    }

    final mine = all.where((c) => c.isJoined).toList();
    final notJoined = all.where((c) => !c.isJoined).toList();

    final popular = List<CommunityResponse>.from(notJoined)
      ..sort((a, b) => b.membersCount.compareTo(a.membersCount));

    final newest = List<CommunityResponse>.from(all)
      ..sort((a, b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null || bd == null) return 0;
        return bd.compareTo(ad);
      });

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          l10n.communitiesHeading,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.communitiesSubtitle,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _searchController,
          onSubmitted: _search,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.communitiesSearchHint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      _search('');
                    },
                  ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (all.isEmpty)
          _emptyState(context, l10n, accentColor)
        else if (_query.isNotEmpty)
          _grid(all, accentColor)
        else ...[
          if (mine.isNotEmpty)
            _section(l10n.communitiesSectionMine, mine, accentColor)
          else
            _emptyMineHint(l10n),
          const SizedBox(height: 26),
          if (popular.isNotEmpty)
            _section(l10n.communitiesSectionPopular, popular, accentColor),
          const SizedBox(height: 26),
          if (newest.isNotEmpty)
            _section(l10n.communitiesSectionNew, newest, accentColor),
        ],
      ],
    );
  }

  Widget _emptyMineHint(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff171725),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.groups_outlined, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.communitiesNoneJoinedHint,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(List<CommunityResponse> results, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final community in results)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _CommunityCard(
              community: community,
              accentColor: accentColor,
              horizontal: true,
            ),
          ),
      ],
    );
  }

  Widget _section(
    String title,
    List<CommunityResponse> items,
    Color accentColor,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // CORRECCIÓN overflow ("BOTTOM OVERFLOWED BY 13 PIXELS"): 220 no
        // alcanzaba para portada(92) + padding + título + descripción de 2
        // líneas + categoría opcional + fila de miembros/botón dentro de
        // `_CommunityCard` — sobre todo cuando la comunidad tenía categoría,
        // o con texto del sistema escalado. 260 deja margen real para el
        // contenido máximo que la tarjeta puede mostrar.
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length > 10 ? 10 : items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 220,
              child: _CommunityCard(
                community: items[i],
                accentColor: accentColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(
    BuildContext context,
    AppLocalizations l10n,
    Color accentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.groups_outlined, color: Colors.grey.shade700, size: 72),
            const SizedBox(height: 20),
            Text(
              l10n.communitiesEmptyTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.communitiesEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: accentColor),
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateCommunityScreen(),
                  ),
                );
                if (created == true && context.mounted) {
                  context.read<CommunityController>().loadBackendCommunities();
                }
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.communitiesCreateButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityResponse community;
  final Color accentColor;
  final bool horizontal;

  const _CommunityCard({
    required this.community,
    required this.accentColor,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final cover = Container(
      height: horizontal ? 80 : 92,
      width: horizontal ? 80 : double.infinity,
      decoration: BoxDecoration(
        borderRadius: horizontal
            ? BorderRadius.circular(14)
            : const BorderRadius.vertical(top: Radius.circular(18)),
        gradient: community.bannerUrlAbsolute == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A1B4D), Color(0xFF120F1F)],
              )
            : null,
      ),
      child: Stack(
        children: [
          if (community.bannerUrlAbsolute != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: horizontal
                    ? BorderRadius.circular(14)
                    : const BorderRadius.vertical(top: Radius.circular(18)),
                child: ZentryNetworkImage(
                  imageUrl: community.bannerUrlAbsolute!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ZentryAvatar(
                radius: 16,
                backgroundColor: accentColor.withValues(alpha: .25),
                networkUrl: community.avatarUrlAbsolute,
                icon: Icons.groups_rounded,
                iconColor: accentColor,
              ),
            ),
          ),
        ],
      ),
    );

    final joinButton = SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () => _handleTap(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: community.isJoined ? Colors.green : accentColor,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          community.isJoined
              ? l10n.communitiesMemberLabel
              : l10n.communitiesJoinLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    final info = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            community.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            community.descripcion ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11.5),
          ),
          if ((community.categoria ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              community.categoria!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: accentColor, fontSize: 10.5),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.groups, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                '${community.membersCount}',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
              const Spacer(),
              joinButton,
            ],
          ),
        ],
      ),
    );

    final card = Container(
      decoration: BoxDecoration(
        color: const Color(0xff171725),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: horizontal
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(18),
                  ),
                  child: cover,
                ),
                Expanded(child: info),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [cover, info],
            ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CommunityDetailScreen(identifier: community.identifier),
          ),
        );
      },
      child: card,
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    if (community.isJoined) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CommunityDetailScreen(identifier: community.identifier),
        ),
      );
      return;
    }

    final error = await context.read<CommunityController>().toggleJoinBackend(
      community,
    );
    if (!context.mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}
