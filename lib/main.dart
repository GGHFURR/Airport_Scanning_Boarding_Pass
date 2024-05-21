import 'package:airplane_thoriq/ui/pages/ScanResultPage.dart';
import 'package:airplane_thoriq/ui/pages/get_started_page.dart';
import 'package:airplane_thoriq/ui/pages/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'ui/pages/splash_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => SplashPage(),
        '/sign-up': (context) => SignUpPage(),
        '/get-started': (context) => GetStartedPage(),
        '/scan-result': (context) => ScanResultPage(
              rawpnr: '',
              token: '',
            ),
      },
    );
  }
}
