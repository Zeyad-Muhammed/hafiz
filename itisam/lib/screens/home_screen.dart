import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/prayers.dart';
import '../routes/transitions.dart';
import '../theme.dart';
import '../widgets/itisam_emblem.dart';
import 'prayer_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _spin;
  late final AnimationController _pulse;
  Timer? _ticker;
  late PrayerEntry _next;
  late PrayerEntry _prev;
  Duration _remaining = Duration.zero;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _refresh());
    _refresh();
  }

  void _refresh() {
    final now = DateTime.now();
    final next = nextPrayer(now);
    final prev = previousPrayer(now);
    final remaining = untilNext(now, next);
    final window = windowSeconds(prev, next);
    final elapsed = window - remaining.inSeconds;
    setState(() {
      _next = next;
      _prev = prev;
      _remaining = remaining;
      _progress = (elapsed.clamp(0, window)) / window;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulse.dispose();
    _spin.dispose();
    _intro.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child) {
    final t = (0.08 + index * 0.12).clamp(0.0, 0.95);
    final curve = CurvedAnimation(
      parent: _intro,
      curve: Interval(t, (t + 0.16).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
            .animate(curve),
        child: child,
      ),
    );
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    final text = '${h.toString().padLeft(2, '0')} : '
        '${m.toString().padLeft(2, '0')} : '
        '${s.toString().padLeft(2, '0')}';
    return arabicDigits(text);
  }

  @override
  Widget build(BuildContext context) {
    final amiri = GoogleFonts.amiriTextTheme();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _BackgroundDecor(spin: _spin)),
            Column(
              children: [
                _header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _staggered(0, _countdownCard(amiri)),
                        const SizedBox(height: 14),
                        _staggered(1, _dateRow(amiri)),
                        const SizedBox(height: 14),
                        _staggered(2, _prayersCard()),
                        _staggered(3, const SizedBox(height: 12)),
                        _staggered(
                          3,
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              'اضغط على أي موعد لفتح التفاصيل والأنيميشن',
                              textAlign: TextAlign.center,
                              style: amiri.titleSmall!.copyWith(
                                color: ItisamColors.faint,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _spin,
            builder: (context, _) => ItisamEmblem(
              rotation: _spin.value * 2 * 3.14159265,
              size: 54,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الاعتصام',
                  style: GoogleFonts.amiriTextTheme().headlineMedium!.copyWith(
                        color: ItisamColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '﴿وَاعْتَصِمُوا بِحَبْلِ اللَّهِ جَمِيعًا﴾',
                  style: GoogleFonts.amiriTextTheme().titleSmall!.copyWith(
                        color: ItisamColors.faint,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _countdownCard(TextTheme amiri) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ItisamColors.cardSurface, ItisamColors.deepGreen],
        ),
        border: Border.all(color: ItisamColors.gold.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: ItisamColors.gold.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'الصلاة القادمة',
                style: amiri.titleMedium!.copyWith(
                  color: ItisamColors.cream.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              _PulseChip(
                pulse: _pulse,
                label: 'التالية',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _nextPrayerIcon(),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _next.name,
                    style: amiri.headlineLarge!.copyWith(
                      color: ItisamColors.goldLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'موعد الصلاة: ${arabicDigits(_next.timeText)}',
                    style: amiri.titleSmall!.copyWith(
                      color: ItisamColors.faint,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                arabicDigits(_next.timeText),
                style: amiri.displaySmall!.copyWith(
                  color: ItisamColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'متبقي',
                style: amiri.titleMedium!.copyWith(color: ItisamColors.cream),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    _format(_remaining),
                    textAlign: TextAlign.end,
                    style: amiri.displaySmall!.copyWith(
                      color: ItisamColors.cream,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: _progress),
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: ItisamColors.cream.withValues(alpha: 0.08),
                valueColor: const AlwaysStoppedAnimation(ItisamColors.gold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'منذ ${arabicDigits(_prev.timeText)}',
                style: amiri.titleSmall!.copyWith(color: ItisamColors.faint),
              ),
              const Spacer(),
              Text(
                'الفترة الحالية',
                style: amiri.titleSmall!.copyWith(color: ItisamColors.faint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nextPrayerIcon() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ItisamColors.emerald.withValues(alpha: 0.25),
        border: Border.all(color: ItisamColors.gold, width: 1.4),
      ),
      child: Icon(_next.icon, color: ItisamColors.goldLight, size: 28),
    );
  }

  Widget _dateRow(TextTheme amiri) {
    final now = DateTime.now();
    const weekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final weekday = weekdays[now.weekday - 1];
    final gregorian =
        '${arabicDigits('${now.day}/${now.month}/${now.year}')} م';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          weekday,
          style: amiri.titleMedium!.copyWith(color: ItisamColors.cream),
        ),
        Text(
          '$gregorian  •  تقويم هجري قريبًا',
          style: amiri.titleSmall!.copyWith(color: ItisamColors.faint),
        ),
      ],
    );
  }

  Widget _prayersCard() {
    return Container(
      decoration: BoxDecoration(
        color: ItisamColors.darkSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ItisamColors.cream.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < prayerTimesDemo.length; i++)
            _prayerRow(prayerTimesDemo[i], isNext: prayerTimesDemo[i] == _next)
        ],
      ),
    );
  }

  Widget _prayerRow(PrayerEntry p, {required bool isNext}) {
    final isNextStyle = isNext;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            itisamPageRoute(
              page: PrayerDetailScreen(prayer: p),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: isNextStyle
                ? Border.all(color: ItisamColors.gold, width: 1.3)
                : null,
            color: isNextStyle
                ? ItisamColors.emerald.withValues(alpha: 0.16)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isNextStyle ? ItisamColors.gold : ItisamColors.emerald)
                      .withValues(alpha: 0.22),
                ),
                child: Icon(
                  p.icon,
                  color: isNextStyle
                      ? ItisamColors.goldLight
                      : ItisamColors.cream.withValues(alpha: 0.85),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  p.name,
                  style: GoogleFonts.amiriTextTheme().titleLarge!.copyWith(
                        color: ItisamColors.cream,
                        fontWeight: isNextStyle ? FontWeight.bold : FontWeight.w500,
                      ),
                ),
              ),
              if (isNextStyle)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _PulseChip(pulse: _pulse, label: 'التالي'),
                ),
              Text(
                arabicDigits(p.timeText),
                style: GoogleFonts.amiriTextTheme().titleLarge!.copyWith(
                      color: isNextStyle
                          ? ItisamColors.goldLight
                          : ItisamColors.faint,
                    ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_back_ios_new,
                size: 15,
                color: ItisamColors.faint.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundDecor extends StatelessWidget {
  const _BackgroundDecor({required this.spin});

  final Animation<double> spin;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: spin,
      builder: (context, _) => CustomPaint(
        painter: _BackgroundPainter(rotation: spin.value * 2 * 3.14159265),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter({required this.rotation});

  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final ring = Paint()
      ..color = ItisamColors.gold.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round;

    final c1 = Offset(size.width * 0.92, size.height * 0.06);
    final r1 = size.width * 0.28;
    canvas.drawCircle(c1, r1, ring);

    final c2 = Offset(size.width * 0.05, size.height);
    canvas.drawCircle(c2, size.width * 0.4, ring);

    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.16);
    canvas.rotate(rotation);
    final small = Paint()
      ..color = ItisamColors.cream.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(Offset.zero, 40, small);
    canvas.drawCircle(Offset.zero, 26, small);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) =>
      old.rotation != rotation;
}

class _PulseChip extends StatelessWidget {
  const _PulseChip({required this.pulse, required this.label});

  final Animation<double> pulse;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.55, end: 1).animate(
        CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ItisamColors.gold.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: ItisamColors.gold, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ItisamColors.goldLight,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.amiriTextTheme().labelLarge!.copyWith(
                    color: ItisamColors.goldLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}