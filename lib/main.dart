import 'package:aturuang/configuration/navBottom.dart';
import 'package:aturuang/pages/forget_password.dart';
import 'package:aturuang/pages/goal_list.dart';
import 'package:aturuang/pages/goals_detail.dart';
import 'package:aturuang/pages/goals_edit.dart';
import 'package:aturuang/pages/goals_menu.dart';
import 'package:aturuang/pages/profile.dart';
import 'package:aturuang/pages/counting.dart';
import 'package:aturuang/pages/reporting.dart';
import 'package:aturuang/welcoming-pages/Splashscreen.dart';
import 'package:aturuang/pages/login.dart';
import 'package:aturuang/pages/register.dart';
import 'package:aturuang/welcoming-pages/Welcome_pages.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aturuang',
        home: SplashScreen(),
        routes: {
          'welcome': (context) => const WelcomingPage(),
          'login': (context) => const LoginScreen(),
          'register': (context) => const RegistrationScreen(),
          'home': (context) => const NavigationBarDemo(),
          'goalist': (context) => const GoalsList(),
          'goals_menu': (context) => GoalsMenu(),
          'goals_edit': (context) => GoalsEdit(),
          'goals_detail': (context) => GoalsDetail(),
          'profile': (context) => const ProfilePage(),
          'counting': (context) => CountingScreen(),
          'reporting': (context) => ReportingPage(),
          'forget_password': (context) => const ForgetPassword(),
        });
  }
}
