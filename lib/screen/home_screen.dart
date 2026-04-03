import 'dart:math' show max;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tune_tangler/config/app_config_fields.dart';
import 'package:tune_tangler/manager/home_screen_manager.dart';
import 'package:tune_tangler/wrapper/app.dart';
import 'package:tune_tangler/wrapper/hive_settings_provider.dart';

/// Bottom inset for the system navigation bar. Some devices report 0 in
/// [MediaQuery] while still drawing the 3-button bar over the app (OEM / edge-to-edge).
double _navBarBottomReserve(BuildContext context) {
  final mq = MediaQuery.of(context);
  double v = max(mq.viewPadding.bottom, mq.padding.bottom);
  final implicit = WidgetsBinding.instance.platformDispatcher.implicitView;
  if (implicit != null) {
    final fromView = MediaQueryData.fromView(implicit);
    v = max(v, max(fromView.viewPadding.bottom, fromView.padding.bottom));
  }
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && v < 8.0) {
    v = 48.0;
  }
  return v;
}

class HomeScreen extends StatefulWidget {
  final AppWrapper appWrapper;

  const HomeScreen({super.key, required this.appWrapper});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeScreenManager? _homeScreenManager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update context and translations when locale changes
    widget.appWrapper.setContext(context);
    // Recreate HomeScreenManager to get fresh translations when locale changes
    _homeScreenManager = HomeScreenManager(widget.appWrapper);
  }

  /// Listen to locale changes to update AppWrapper.trans without full reload
  @override
  Widget build(BuildContext context) => Selector<HiveSettingsProvider, String>(
    selector: (context, settings) => settings.getConfig(AppConfigFieldKey.locale).toLanguageTag(),
    builder: (context, localeTag, child) {
      // Update context and translations when locale changes
      widget.appWrapper.setContext(context);
      // Recreate HomeScreenManager to get fresh translations when locale changes
      _homeScreenManager = HomeScreenManager(widget.appWrapper);
      return Padding(
        padding: EdgeInsets.only(bottom: _navBarBottomReserve(context)),
        child: Scaffold(
          key: widget.appWrapper.scaffoldKey,
          appBar: _homeScreenManager!.appBar,
          drawer: _homeScreenManager!.drawer,
          body: _homeScreenManager!.body,
          bottomNavigationBar: _homeScreenManager!.bottomNavigationBar,
        ),
      );
    },
  );
}
