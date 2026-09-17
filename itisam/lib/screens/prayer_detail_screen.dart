import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/prayers.dart';
import '../theme.dart';
import '../widgets/itisam_emblem.dart';

class PrayerDetailScreen extends StatefulWidget {
  const PrayerDetailScreen({super.key, required this.prayer});

  final PrayerEntry prayer;

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends State<PrayerDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _ring;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _spin.dispose();
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amiri = GoogleFonts.amiriTextTheme();
    final p = widget.prayer;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [ItisamColors.darkSurface, ItisamColors.deepGreen],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: ItisamColors.goldLight,
                        ),
                      ),
                      Text(
                        'التفاصيل',
                        style: amiri.titleMedium!.copyWith(
                          color: ItisamColors.cream,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _spin,
                          builder: (context, _) => ItisamEmblem(
                            rotation: _spin.value * 2 * 3.14159265,
                            size: 180,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          p.name,
                          style: amiri.headlineLarge!.copyWith(
                            color: ItisamColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'موعد صلاة ${p.name}',
                          style: amiri.titleMedium!.copyWith(
                            color: ItisamColors.faint,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          arabicDigits(p.timeText),
                          style: amiri.displayLarge!.copyWith(
                            color: ItisamColors.cream,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _ringCard(amiri),
                        const SizedBox(height: 20),
                        _actions(amiri),
                      ],
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

  Widget _ringCard(TextTheme amiri) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: ItisamColors.cardSurface.withValues(alpha: 0.85),
        border: Border.all(color: ItisamColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: AnimatedBuilder(
              animation: _ring,
              builder: (context, _) => Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _ring.value,
                    strokeWidth: 7,
                    strokeCap: StrokeCap.round,
                    backgroundColor: ItisamColors.cream.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation(ItisamColors.gold),
                  ),
                  Center(
                    child: Icon(
                      widget.prayer.icon,
                      color: ItisamColors.goldLight,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اقترب وقت الصلاة',
                  style: amiri.titleMedium!.copyWith(color: ItisamColors.cream),
                ),
                const SizedBox(height: 6),
                Text(
                  'جهّز نفسك للوضوء والخشوع، فأنت تصلي مع المسلمين حول العالم في الوقت نفسه.',
                  style: amiri.titleSmall!.copyWith(color: ItisamColors.faint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(TextTheme amiri) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: ItisamColors.goldLight,
              side: BorderSide(
                color: ItisamColors.gold.withValues(alpha: 0.6),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text('تذكير', style: amiri.titleMedium),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: ItisamColors.emerald,
              foregroundColor: ItisamColors.cream,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.share_outlined),
            label: Text('مشاركة', style: amiri.titleMedium),
          ),
        ),
      ],
    );
  }
}