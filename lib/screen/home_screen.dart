import 'package:flutter/material.dart';
import 'package:tune_tangler/manager/home_screen_manager.dart';
import 'package:tune_tangler/wrapper/app.dart';

class HomeScreen extends StatelessWidget {
  final AppWrapper appWrapper;

  const HomeScreen({super.key, required this.appWrapper});

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        appWrapper.setContext(context);
        HomeScreenManager homeScreenManager = HomeScreenManager(appWrapper);
        return Scaffold(
          key: appWrapper.scaffoldKey,
          appBar: homeScreenManager.appBar,
          drawer: homeScreenManager.drawer,
          body: homeScreenManager.body,
          bottomNavigationBar: homeScreenManager.bottomNavigationBar,
        );
      });
}
