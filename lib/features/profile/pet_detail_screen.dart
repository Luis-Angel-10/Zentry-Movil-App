import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Zentry/core/models/virtual_pet.dart';
import 'package:Zentry/core/providers/virtual_pet_controller.dart';
import 'package:Zentry/l10n/generated/app_localizations.dart';

Color moodColor(PetMood mood) {
  switch (mood) {
    case PetMood.ecstatic:
      return const Color(0xFF4ADE80);
    case PetMood.happy:
      return const Color(0xFF7DD3FC);
    case PetMood.neutral:
      return const Color(0xFFFBBF24);
    case PetMood.sad:
      return const Color(0xFFFB923C);
    case PetMood.critical:
      return const Color(0xFFF87171);
  }
}

String moodLabel(AppLocalizations l10n, PetMood mood) {
  switch (mood) {
    case PetMood.ecstatic:
      return l10n.petMoodEcstatic;
    case PetMood.happy:
      return l10n.petMoodHappy;
    case PetMood.neutral:
      return l10n.petMoodNeutral;
    case PetMood.sad:
      return l10n.petMoodSad;
    case PetMood.critical:
      return l10n.petMoodCritical;
  }
}

String stageLabel(AppLocalizations l10n, PetStage stage) {
  switch (stage) {
    case PetStage.baby:
      return l10n.petStageBaby;
    case PetStage.young:
      return l10n.petStageYoung;
    case PetStage.adult:
      return l10n.petStageAdult;
  }
}

Color statColor(int value) {
  if (value >= 60) return const Color(0xFF4ADE80);
  if (value >= 30) return const Color(0xFFFBBF24);
  return const Color(0xFFF87171);
}

class _Particle {
  _Particle(this.id, this.emoji, this.dx);
  final int id;
  final String emoji;
  final double dx;
}

class PetDetailScreen extends StatefulWidget {
  const PetDetailScreen({super.key});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final Animation<double> _idleFloat;
  late final Animation<double> _idleScale;

  late final AnimationController _bounceController;
  late final Animation<double> _bounceScale;

  final List<_Particle> _particles = [];
  int _particleSeq = 0;
  final _rand = Random();

  int? _lastLevel;

  @override
  void initState() {
    super.initState();

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _idleFloat = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
    _idleScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.22,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.22,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_bounceController);

    final pet = context.read<VirtualPetController>().pet;
    _lastLevel = pet?.level;
  }

  @override
  void dispose() {
    _idleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _spawnParticle(String emoji) {
    final id = _particleSeq++;
    setState(() {
      _particles.add(_Particle(id, emoji, _rand.nextDouble() * 60 - 30));
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() => _particles.removeWhere((p) => p.id == id));
    });
  }

  void _checkLevelUp(AppLocalizations l10n, VirtualPet pet) {
    final last = _lastLevel;
    if (last != null && pet.level > last) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.petLevelUpMessage(pet.name, pet.level)),
              backgroundColor: Colors.amber.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
      });
    }
    _lastLevel = pet.level;
  }

  Future<void> _confirmRemove(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF171725),
        title: Text(
          l10n.petRemoveConfirmTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.petRemoveConfirmMessage,
          style: TextStyle(color: Colors.grey.shade400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.commonDelete,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<VirtualPetController>().remove();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pet = context.watch<VirtualPetController>().pet;

    if (pet == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    _checkLevelUp(l10n, pet);
    final color = moodColor(pet.mood);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.petDetailScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmRemove(l10n),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.22), const Color(0xFF0F0F1A)],
            stops: const [0, 0.55],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 90, 20, 30),
            child: Column(
              children: [
                _stage(pet, color),
                const SizedBox(height: 8),
                Text(
                  l10n.petTapHint,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 18),
                _identity(l10n, pet, color),
                const SizedBox(height: 24),
                _xpBar(l10n, pet, color),
                const SizedBox(height: 18),
                _statBar(Icons.restaurant, l10n.petHungerLabel, pet.hunger),
                const SizedBox(height: 12),
                _statBar(Icons.favorite, l10n.petHappinessLabel, pet.happiness),
                const SizedBox(height: 28),
                _actions(l10n, pet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stage(VirtualPet pet, Color color) {
    return SizedBox(
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _idleController,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _idleFloat.value),
              child: Transform.scale(scale: _idleScale.value, child: child),
            ),
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withOpacity(0.45), color.withOpacity(0.0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 50,
                    spreadRadius: 6,
                  ),
                ],
              ),
            ),
          ),

          ..._particles.map(
            (p) => TweenAnimationBuilder<double>(
              key: ValueKey(p.id),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOut,
              builder: (_, t, __) => Positioned(
                bottom: 130 + 90 * t,
                child: Opacity(
                  opacity: 1 - t,
                  child: Transform.translate(
                    offset: Offset(p.dx * t, 0),
                    child: Text(
                      p.emoji,
                      style: TextStyle(fontSize: 22 + 10 * t),
                    ),
                  ),
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              _bounceController.forward(from: 0);
              _spawnParticle('💗');
              context.read<VirtualPetController>().cuddle();
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([_idleController, _bounceController]),
              builder: (_, child) => Transform.translate(
                offset: Offset(0, _idleFloat.value),
                child: Transform.scale(
                  scale: _idleScale.value * _bounceScale.value,
                  child: child,
                ),
              ),
              child: Text(pet.emoji, style: const TextStyle(fontSize: 96)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _identity(AppLocalizations l10n, VirtualPet pet, Color color) {
    return Column(
      children: [
        Text(
          pet.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _chip(l10n.petLevelLabel(pet.level), Colors.amber),
            _chip(stageLabel(l10n, pet.stage), Colors.blueAccent),
            _chip(moodLabel(l10n, pet.mood), color),
          ],
        ),
      ],
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _xpBar(AppLocalizations l10n, VirtualPet pet, Color color) {
    final xpIntoLevel = pet.xp % 50;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171725),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'XP',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                l10n.petXpToNextLabel(50 - xpIntoLevel),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pet.levelProgress),
              duration: const Duration(milliseconds: 500),
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.white10,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBar(IconData icon, String label, int value) {
    final color = statColor(value);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171725),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$value%',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: value / 100),
                    duration: const Duration(milliseconds: 500),
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      minHeight: 8,
                      backgroundColor: Colors.white10,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(AppLocalizations l10n, VirtualPet pet) {
    final controller = context.read<VirtualPetController>();
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.restaurant,
            label: l10n.petFeedButton,
            color: const Color(0xFFFB923C),
            onTap: () {
              _bounceController.forward(from: 0);
              _spawnParticle('🍖');
              controller.feed();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionButton(
            icon: Icons.sports_esports,
            label: l10n.petPlayButton,
            color: const Color(0xFF60A5FA),
            onTap: () {
              _bounceController.forward(from: 0);
              _spawnParticle('⭐');
              controller.play();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionButton(
            icon: Icons.volunteer_activism,
            label: l10n.petCuddleButton,
            color: const Color(0xFFF472B6),
            onTap: () {
              _bounceController.forward(from: 0);
              _spawnParticle('💗');
              controller.cuddle();
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
