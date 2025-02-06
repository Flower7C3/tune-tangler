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
                Icon(Icons.dashboard_customize_rounded, size: Theme.of(context).textTheme.displayMedium?.fontSize),
                Text('Tune Tangler', style: Theme.of(context).textTheme.displayMedium),
              ],
            ),
            CircularProgressIndicator(strokeWidth: 8),
          ]),
        ),
      ),
    );
  }
}
