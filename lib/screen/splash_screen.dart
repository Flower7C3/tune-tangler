import 'package:flutter/material.dart';

class SplashScreenApp extends StatelessWidget {
  const SplashScreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dashboard_customize_rounded, size: 48),
                Text('Tune Tangler', style: TextStyle(fontSize: 48)),
              ],
            ),
            CircularProgressIndicator(strokeWidth: 8),
          ]),
        ),
      ),
    );
  }
}
