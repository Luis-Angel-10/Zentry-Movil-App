import 'package:flutter/material.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final PageController _controller = PageController(viewportFraction: 0.8);

  double currentPage = 1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        currentPage = _controller.page ?? 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final plans = _buildPlans(l10n);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.subscriptionScreenTitle),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          SizedBox(
            height: 420,
            child: PageView.builder(
              controller: _controller,
              itemCount: 3,
              itemBuilder: (context, index) {
                final scale = (1 - (currentPage - index).abs() * 0.2).clamp(
                  0.8,
                  1.0,
                );

                return Transform.scale(
                  scale: scale,
                  child: _planCard(l10n, plans, index),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final isActive = currentPage.round() == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? Colors.purple : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            // NO existe proveedor de pagos real (Stripe/Google Play
            // Billing/App Store) todavía — ver reporte de la fase.
            // Deshabilitado a propósito: nunca simular una compra exitosa
            // de $9.99/$24.99 reales (Fase 7 del reporte).
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                disabledBackgroundColor: Colors.purple.withValues(alpha: .35),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n.subscriptionComingSoon,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildPlans(AppLocalizations l10n) {
    return [
      {
        "title": l10n.subscriptionPlanFreeName,
        "price": l10n.subscriptionPlanFreePrice,
        "desc": l10n.subscriptionPlanFreeDesc,
        "features": [
          l10n.subscriptionPlanFreeFeature1,
          l10n.subscriptionPlanFreeFeature2,
          l10n.subscriptionPlanFreeFeature3,
        ],
        "active": true,
        "popular": false,
      },
      {
        "title": l10n.subscriptionPlanProName,
        "price": l10n.subscriptionPlanProPrice,
        "desc": l10n.subscriptionPlanProDesc,
        "features": [
          l10n.subscriptionPlanProFeature1,
          l10n.subscriptionPlanProFeature2,
          l10n.subscriptionPlanProFeature3,
          l10n.subscriptionPlanProFeature4,
          l10n.subscriptionPlanProFeature5,
        ],
        "active": false,
        "popular": true,
      },
      {
        "title": l10n.subscriptionPlanPremiumName,
        "price": l10n.subscriptionPlanPremiumPrice,
        "desc": l10n.subscriptionPlanPremiumDesc,
        "features": [
          l10n.subscriptionPlanPremiumFeature1,
          l10n.subscriptionPlanPremiumFeature2,
          l10n.subscriptionPlanPremiumFeature3,
          l10n.subscriptionPlanPremiumFeature4,
        ],
        "active": false,
        "popular": false,
      },
    ];
  }

  Widget _planCard(
    AppLocalizations l10n,
    List<Map<String, dynamic>> plans,
    int index,
  ) {
    final plan = plans[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: plan["popular"] as bool
              ? const LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: plan["popular"] as bool ? null : Colors.grey[900],
          boxShadow: (plan["popular"] as bool)
              ? [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.4),
                    blurRadius: 25,
                  ),
                ]
              : [],
        ),

        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan["popular"] as bool)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.subscriptionPopularBadge,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 10),

                Text(
                  plan["title"] as String,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  plan["desc"] as String,
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 20),

                Text(
                  plan["price"] as String,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                Text(
                  l10n.subscriptionPricePerMonth,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  // Ídem al CTA principal: sin proveedor de pagos real, este
                  // botón nunca debe parecer accionable para un plan de pago.
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (plan["active"] as bool)
                        ? Colors.grey
                        : Colors.black,
                    disabledBackgroundColor: (plan["active"] as bool)
                        ? Colors.grey
                        : Colors.black45,
                  ),
                  child: Text(
                    (plan["active"] as bool)
                        ? l10n.subscriptionCurrentPlanButton
                        : l10n.subscriptionComingSoon,
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: (plan["features"] as List<String>)
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  f,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
