import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';
import 'package:Zentry/theme/theme_controller.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  final ScrollController scrollController = ScrollController();

  final TextEditingController searchController = TextEditingController();

  bool searching = false;

  bool _optionsInitialized = false;

  late List<Map<String, dynamic>> options;

  late List<Map<String, dynamic>> filteredOptions;

  List<Map<String, dynamic>> _buildOptions(
    AppLocalizations l10n,
    Color accentColor,
  ) {
    return [
      {
        "title": l10n.supportOptionFaqTitle,

        "subtitle": l10n.supportOptionFaqSubtitle,

        "icon": Icons.help_outline,

        "color": accentColor,
      },

      {
        "title": l10n.supportOptionContactTitle,

        "subtitle": l10n.supportOptionContactSubtitle,

        "icon": Icons.support_agent,

        "color": Colors.blue,
      },

      {
        "title": l10n.supportOptionReportBugTitle,

        "subtitle": l10n.supportOptionReportBugSubtitle,

        "icon": Icons.bug_report,

        "color": Colors.red,
      },

      {
        "title": l10n.supportOptionSuggestionTitle,

        "subtitle": l10n.supportOptionSuggestionSubtitle,

        "icon": Icons.lightbulb_outline,

        "color": Colors.amber,
      },

      {
        "title": l10n.supportOptionPrivacyTitle,

        "subtitle": l10n.supportOptionPrivacySubtitle,

        "icon": Icons.privacy_tip_outlined,

        "color": Colors.green,
      },

      {
        "title": l10n.supportOptionTermsTitle,

        "subtitle": l10n.supportOptionTermsSubtitle,

        "icon": Icons.description_outlined,

        "color": Colors.grey,
      },
    ];
  }

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,

      duration: const Duration(milliseconds: 700),
    );

    animationController.forward();

    searchController.addListener(filterOptions);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_optionsInitialized) {
      final l10n = AppLocalizations.of(context)!;
      final accentColor = context.read<ThemeController>().accentColor;
      options = _buildOptions(l10n, accentColor);
      filteredOptions = List.from(options);
      _optionsInitialized = true;
    }
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

    filterOptions();
  }

  void filterOptions() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredOptions = options.where((option) {
        return option["title"].toLowerCase().contains(query) ||
            option["subtitle"].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = context.watch<ThemeController>().accentColor;

    if (_optionsInitialized && options.isNotEmpty) {
      options[0]["color"] = accentColor;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,

        title: Text(
          l10n.supportScreenTitle,

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

          IconButton(onPressed: () {}, icon: const Icon(Icons.support)),
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
                    l10n.supportHeading,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 28,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    l10n.supportSubtitle,

                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.question_answer,

                          accentColor,

                          l10n.supportStatArticlesValue,

                          l10n.supportStatArticlesLabel,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _statCard(
                          Icons.confirmation_number,

                          Colors.orange,

                          l10n.supportStatTicketsValue,

                          l10n.supportStatTicketsLabel,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.schedule,

                          Colors.green,

                          l10n.supportStatResponseValue,

                          l10n.supportStatResponseLabel,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _statCard(
                          Icons.support_agent,

                          Colors.blue,

                          l10n.supportStatSupportValue,

                          l10n.supportStatSupportLabel,
                        ),
                      ),
                    ],
                  ),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),

                    height: searching ? 65 : 0,

                    margin: EdgeInsets.only(top: searching ? 25 : 0),

                    child: TextField(
                      controller: searchController,

                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        filled: true,

                        fillColor: const Color(0xff171725),

                        hintText: l10n.supportSearchHint,

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
                    l10n.commonOptions,

                    style: const TextStyle(
                      color: Colors.white,

                      fontWeight: FontWeight.bold,

                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 15),
                  if (filteredOptions.isEmpty)
                    _emptyState(l10n, accentColor)
                  else
                    ListView.separated(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: filteredOptions.length,

                      separatorBuilder: (_, __) => const SizedBox(height: 15),

                      itemBuilder: (_, index) {
                        final option = filteredOptions[index];

                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 250 + (index * 70)),

                          tween: Tween(begin: .90, end: 1),

                          curve: Curves.easeOutBack,

                          builder: (_, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },

                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),

                            onTap: () {},

                            child: Container(
                              padding: const EdgeInsets.all(18),

                              decoration: BoxDecoration(
                                color: const Color(0xff171725),

                                borderRadius: BorderRadius.circular(22),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.25),

                                    blurRadius: 15,

                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),

                              child: Row(
                                children: [
                                  Container(
                                    width: 58,

                                    height: 58,

                                    decoration: BoxDecoration(
                                      color: option["color"].withOpacity(.15),

                                      borderRadius: BorderRadius.circular(16),
                                    ),

                                    child: Icon(
                                      option["icon"],

                                      color: option["color"],

                                      size: 30,
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          option["title"],

                                          style: const TextStyle(
                                            color: Colors.white,

                                            fontWeight: FontWeight.bold,

                                            fontSize: 17,
                                          ),
                                        ),

                                        const SizedBox(height: 5),

                                        Text(
                                          option["subtitle"],

                                          style: TextStyle(
                                            color: Colors.grey.shade400,

                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Icon(
                                    Icons.arrow_forward_ios,

                                    color: Colors.white54,

                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 30),

                  Text(
                    l10n.supportRecentTicketsTitle,

                    style: const TextStyle(
                      color: Colors.white,

                      fontWeight: FontWeight.bold,

                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: const Color(0xff171725),

                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,

                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withOpacity(.15),

                            child: const Icon(
                              Icons.schedule,

                              color: Colors.orange,
                            ),
                          ),

                          title: const Text(
                            "#ZT-1001",

                            style: TextStyle(
                              color: Colors.white,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            l10n.supportTicketStatusInReview,

                            style: const TextStyle(color: Colors.white60),
                          ),

                          trailing: const Icon(
                            Icons.chevron_right,

                            color: Colors.white54,
                          ),
                        ),

                        const Divider(),

                        ListTile(
                          contentPadding: EdgeInsets.zero,

                          leading: CircleAvatar(
                            backgroundColor: Colors.green.withOpacity(.15),

                            child: const Icon(
                              Icons.check_circle,

                              color: Colors.green,
                            ),
                          ),

                          title: const Text(
                            "#ZT-0988",

                            style: TextStyle(
                              color: Colors.white,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            l10n.supportTicketStatusResolved,

                            style: const TextStyle(color: Colors.white60),
                          ),

                          trailing: const Icon(
                            Icons.chevron_right,

                            color: Colors.white54,
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

          Text(
            title,

            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
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
            Icon(Icons.support_agent, color: Colors.grey.shade700, size: 72),

            const SizedBox(height: 20),

            Text(
              l10n.supportEmptyTitle,

              style: const TextStyle(
                color: Colors.white,

                fontSize: 22,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              l10n.supportEmptySubtitle,

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

                filterOptions();
              },

              icon: const Icon(Icons.refresh),

              label: Text(l10n.commonReset),
            ),
          ],
        ),
      ),
    );
  }
}
