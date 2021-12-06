import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:moneygoals/pages/addgoal.dart';
import 'package:moneygoals/pages/goal.dart';
import 'package:moneygoals/pages/home.dart';

void main() => runApp(MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: [const Locale('ru', 'RU')],
      title: 'Money Goals',
      initialRoute: '/home',
      routes: {
        '/home': (context) => Home(),
        '/addGoal': (context) => addgoal(),
      },
    ));
