import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Zentry/core/models/store_color.dart';
import 'package:Zentry/core/providers/engagement_controller.dart';
import 'package:Zentry/features/store/store_screen.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

import '../../../theme/theme_controller.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  final ScrollController scrollController = ScrollController();

  final List<Color> accentColors = [
    Colors.deepPurple,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.pink,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final engagement = context.watch<EngagementController>();
    final l10n = AppLocalizations.of(context)!;
    final ownedStoreColors = kStoreColors
        .where((item) => engagement.ownedColors.contains(item.id))
        .map((item) => item.color);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appearanceScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreScreen()),
              );
            },
            icon: const Icon(Icons.palette_outlined),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: controller.accentColor,

        onPressed: () {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },

        child: const Icon(Icons.keyboard_arrow_up),
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
                    l10n.appearanceHeading,

                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(l10n.appearanceSubtitle),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          Icons.palette,
                          controller.accentColor,
                          "8",
                          l10n.appearanceColorsStat,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _statCard(
                          Icons.auto_awesome,
                          Colors.orange,
                          "4",
                          l10n.appearanceEffectsStat,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            l10n.appearanceThemeCardTitle,

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 15),

                          RadioListTile<ThemeMode>(
                            value: ThemeMode.light,

                            groupValue: controller.themeMode,

                            activeColor: controller.accentColor,

                            onChanged: (value) {
                              controller.setTheme(ThemeMode.light);
                            },

                            title: Text(l10n.appearanceThemeLight),
                          ),

                          RadioListTile<ThemeMode>(
                            value: ThemeMode.dark,

                            groupValue: controller.themeMode,

                            activeColor: controller.accentColor,

                            onChanged: (value) {
                              controller.setTheme(ThemeMode.dark);
                            },

                            title: Text(l10n.appearanceThemeDark),
                          ),

                          RadioListTile<ThemeMode>(
                            value: ThemeMode.system,

                            groupValue: controller.themeMode,

                            activeColor: controller.accentColor,

                            onChanged: (value) {
                              controller.setTheme(ThemeMode.system);
                            },

                            title: Text(l10n.appearanceThemeSystem),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            l10n.appearanceAccentColorCardTitle,

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Wrap(
                            spacing: 14,
                            runSpacing: 14,

                            children: [...accentColors, ...ownedStoreColors]
                                .map((color) {
                                  final selected =
                                      controller.accentColor.value ==
                                      color.value;

                                  return GestureDetector(
                                    onTap: () {
                                      controller.setAccent(color);
                                    },

                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),

                                      width: 48,
                                      height: 48,

                                      decoration: BoxDecoration(
                                        color: color,

                                        shape: BoxShape.circle,

                                        border: selected
                                            ? Border.all(
                                                color: Colors.white,
                                                width: 3,
                                              )
                                            : null,

                                        boxShadow: selected
                                            ? [
                                                BoxShadow(
                                                  color: color.withOpacity(.45),
                                                  blurRadius: 18,
                                                ),
                                              ]
                                            : [],
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),

                          const SizedBox(height: 14),

                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StoreScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.storefront),
                            label: Text(l10n.appearanceGoToStore),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            l10n.appearancePreviewCardTitle,

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 18),

                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),

                            padding: const EdgeInsets.all(18),

                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,

                              borderRadius: BorderRadius.circular(
                                controller.rounded ? 22 : 4,
                              ),
                            ),

                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,

                                  backgroundColor: controller.accentColor,

                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        l10n.appearancePreviewName,

                                        style: TextStyle(
                                          fontSize: 18 * controller.textScale,

                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        l10n.appearancePreviewSubtitle,

                                        style: TextStyle(
                                          fontSize: 14 * controller.textScale,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Icon(
                                  Icons.palette,

                                  color: controller.accentColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            l10n.appearanceAccessibilityCardTitle,

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            l10n.appearanceTextSizeLabel,

                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16 * controller.textScale,
                            ),
                          ),

                          Slider(
                            value: controller.textScale,

                            min: 0.8,

                            max: 1.5,

                            divisions: 7,

                            activeColor: controller.accentColor,

                            label: controller.textScale.toStringAsFixed(1),

                            onChanged: (value) {
                              controller.setTextScale(value);
                            },
                          ),

                          const SizedBox(height: 10),

                          _settingTile(
                            title: l10n.appearanceAnimationsTitle,

                            subtitle: l10n.appearanceAnimationsSubtitle,

                            icon: Icons.animation,

                            value: controller.animations,

                            onChanged: (v) {
                              controller.setAnimations(v);
                            },
                          ),

                          const Divider(),

                          _settingTile(
                            title: l10n.appearanceBlurTitle,

                            subtitle: l10n.appearanceBlurSubtitle,

                            icon: Icons.blur_on,

                            value: controller.blur,

                            onChanged: (v) {
                              controller.setBlur(v);
                            },
                          ),

                          const Divider(),

                          _settingTile(
                            title: l10n.appearanceRoundedCornersTitle,

                            subtitle: l10n.appearanceRoundedCornersSubtitle,

                            icon: Icons.rounded_corner,

                            value: controller.rounded,

                            onChanged: (v) {
                              controller.setRounded(v);
                            },
                          ),

                          const Divider(),

                          _settingTile(
                            title: l10n.appearanceHeroAnimationsTitle,

                            subtitle: l10n.appearanceHeroAnimationsSubtitle,

                            icon: Icons.auto_awesome,

                            value: controller.heroAnimations,

                            onChanged: (v) {
                              controller.setHero(v);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            l10n.appearanceInfoCardTitle,

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          ListTile(
                            leading: Icon(
                              Icons.palette,
                              color: controller.accentColor,
                            ),

                            title: Text(l10n.appearanceCurrentThemeLabel),

                            subtitle: Text(
                              controller.themeMode == ThemeMode.light
                                  ? l10n.appearanceThemeLight
                                  : controller.themeMode == ThemeMode.dark
                                  ? l10n.appearanceThemeDark
                                  : l10n.appearanceThemeSystem,
                            ),
                          ),

                          const Divider(),

                          ListTile(
                            leading: Icon(
                              Icons.color_lens,
                              color: controller.accentColor,
                            ),

                            title: Text(l10n.appearanceColorLabel),

                            subtitle: Text(
                              "#${controller.accentColor.value.toRadixString(16).substring(2).toUpperCase()}",
                            ),
                          ),

                          const Divider(),

                          ListTile(
                            leading: Icon(
                              Icons.text_fields,
                              color: controller.accentColor,
                            ),

                            title: Text(l10n.appearanceScaleLabel),

                            subtitle: Text(
                              controller.textScale.toStringAsFixed(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, Color color, String value, String label) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
        child: Column(
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _settingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
    );
  }
}
