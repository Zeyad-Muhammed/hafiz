import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  runApp(const ItisamApp());
}

class ItisamApp extends StatelessWidget {
  const ItisamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الاعتصام',
      debugShowCheckedModeBanner: false,
      theme: buildItisamTheme(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}