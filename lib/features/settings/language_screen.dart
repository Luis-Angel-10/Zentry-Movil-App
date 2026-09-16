import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/core/providers/locale_provider.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  bool searching = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    animationController.forward();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  List<Map<String, dynamic>> _buildLanguages(AppLocalizations l10n) {
    return [
      {
        "flag": "🇲🇽",
        "name": l10n.languageScreenSpanishName,
        "native": l10n.languageScreenSpanishNative,
        "locale": const Locale('es', 'MX'),
      },
      {
        "flag": "🇲🇽",
        "name": l10n.languageScreenNahuatlName,
        "native": l10n.languageScreenNahuatlNative,
        "locale": const Locale('nah'),
      },
    ];
  }

  List<Map<String, dynamic>> _filterLanguages(
    List<Map<String, dynamic>> languages,
  ) {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) return languages;
    return languages.where((language) {
      return (language["name"] as String).toLowerCase().contains(query) ||
          (language["native"] as String).toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final accentColor = context.watch<ThemeController>().accentColor;
    final currentLocale = localeProvider.locale;
    final languages = _buildLanguages(l10n);
    final filteredLanguages = _filterLanguages(languages);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          l10n.languageScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                searching = !searching;
              });
            },
            icon: Icon(searching ? Icons.close : Icons.search),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.language)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(18),
          children: [
            FadeTransition(
              opacity: animationController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.languageScreenHeading,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.languageScreenSubtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.language,
                          accentColor,
                          languages.length.toString(),
                          l10n.languageScreenLanguagesStat,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          Icons.public,
                          Colors.blue,
                          l10n.languageScreenCoverageValue,
                          l10n.languageScreenCoverageStat,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: searching ? 65 : 0,
                    margin: EdgeInsets.only(top: searching ? 15 : 0),
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xff171725),
                        hintText: l10n.languageScreenSearchHint,
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  Text(
                    l10n.languageScreenRecommended,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff171725),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Text(
                            "🇲🇽",
                            style: TextStyle(fontSize: 28),
                          ),
                          title: Text(
                            l10n.languageScreenSpanishName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            l10n.languageScreenSpanishNative,
                            style: const TextStyle(color: Colors.white60),
                          ),
                          trailing:
                              currentLocale.languageCode == 'es' &&
                                  currentLocale.countryCode == 'MX'
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : null,
                          onTap: () {
                            localeProvider.setLocale(const Locale('es', 'MX'));
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Text(
                            "🌎",
                            style: TextStyle(fontSize: 28),
                          ),
                          title: Text(
                            l10n.languageScreenNahuatlName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            l10n.languageScreenNahuatlNative,
                            style: const TextStyle(color: Colors.white60),
                          ),
                          trailing: currentLocale.languageCode == 'nah'
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : null,
                          onTap: () {
                            localeProvider.setLocale(const Locale('nah'));
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  Text(
                    l10n.languageScreenAllLanguages,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (filteredLanguages.isEmpty)
                    _emptyState(l10n, accentColor)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredLanguages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final language = filteredLanguages[index];
                        final locale = language["locale"] as Locale;
                        final selected =
                            currentLocale.languageCode == locale.languageCode &&
                            (currentLocale.countryCode == locale.countryCode ||
                                (currentLocale.countryCode == null &&
                                    locale.countryCode == null));

                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 250 + (index * 50)),
                          tween: Tween(begin: .95, end: 1),
                          curve: Curves.easeOutBack,
                          builder: (_, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              localeProvider.setLocale(locale);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selected
                                    ? accentColor.withOpacity(.18)
                                    : const Color(0xff171725),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? accentColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    language["flag"],
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          language["name"],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          language["native"],
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: selected
                                        ? const Icon(
                                            Icons.check_circle,
                                            key: ValueKey(1),
                                            color: Colors.green,
                                            size: 28,
                                          )
                                        : const Icon(
                                            Icons.radio_button_unchecked,
                                            key: ValueKey(2),
                                            color: Colors.white24,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xff171725),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.translate, color: accentColor, size: 32),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.languageScreenCurrent,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                localeProvider.getLocaleName(currentLocale),
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        elevation: 8,
        onPressed: () {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        child: const Icon(Icons.keyboard_arrow_up),
      ),
    );
  }

  Widget _statCard(IconData icon, Color color, String value, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xff171725),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _emptyState(AppLocalizations l10n, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.language, color: Colors.grey.shade700, size: 72),
            const SizedBox(height: 20),
            Text(
              l10n.languageScreenEmptyTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.languageScreenEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 25),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                searchController.clear();
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.languageScreenReset),
            ),
          ],
        ),
      ),
    );
  }
}
