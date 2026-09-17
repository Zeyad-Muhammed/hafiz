import 'package:flutter/material.dart';

class PrayerEntry {
  const PrayerEntry({
    required this.name,
    required this.hour,
    required this.minute,
    required this.icon,
  });

  final String name;
  final int hour;
  final int minute;
  final IconData icon;

  String get timeText => '${_two(hour)}:${_two(minute)}';
  int get secondsSinceMidnight => hour * 3600 + minute * 60;
  int get totalSeconds => hour * 3600 + minute * 60;
}

String _two(int v) => v.toString().padLeft(2, '0');

const prayerTimesDemo = <PrayerEntry>[
  PrayerEntry(name: 'الفجر', hour: 4, minute: 27, icon: Icons.wb_twilight),
  PrayerEntry(name: 'الظهر', hour: 11, minute: 57, icon: Icons.wb_sunny),
  PrayerEntry(name: 'العصر', hour: 15, minute: 22, icon: Icons.light_mode_outlined),
  PrayerEntry(name: 'المغرب', hour: 18, minute: 5, icon: Icons.festival),
  PrayerEntry(name: 'العشاء', hour: 19, minute: 20, icon: Icons.nightlight_round),
];

PrayerEntry nextPrayer(DateTime now) {
  final sec = now.hour * 3600 + now.minute * 60 + now.second;
  for (final p in prayerTimesDemo) {
    if (p.secondsSinceMidnight > sec) return p;
  }
  return prayerTimesDemo.first;
}

PrayerEntry previousPrayer(DateTime now) {
  final sec = now.hour * 3600 + now.minute * 60 + now.second;
  PrayerEntry? last;
  for (final p in prayerTimesDemo) {
    if (p.secondsSinceMidnight <= sec) last = p;
  }
  return last ?? prayerTimesDemo.last;
}

Duration untilNext(DateTime now, PrayerEntry next) {
  final target = DateTime(now.year, now.month, now.day, next.hour, next.minute);
  var diff = target.difference(now);
  if (diff.isNegative) diff += const Duration(days: 1);
  return diff;
}

int windowSeconds(PrayerEntry prev, PrayerEntry next) {
  final raw = next.secondsSinceMidnight - prev.secondsSinceMidnight;
  return raw <= 0 ? raw + 86400 : raw;
}

String arabicDigits(String input) {
  const map = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };
  return input.split('').map((c) => map[c] ?? c).join();
}