import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tune_tangler/config/app_config_fields.dart';
import 'package:tune_tangler/manager/home_screen_manager.dart';
import 'package:tune_tangler/wrapper/app.dart';
import 'package:tune_tangler/wrapper/hive_settings_provider.dart';

/// Extra bottom space so the scaffold (incl. footer) clears the system navigation area.
///
/// Uses [MediaQueryData.viewPadding] only (not [MediaQueryData.padding]): that value
/// tracks the real system UI — **no bar / gesture pill / 3-button bar** — without
/// treating “small or zero inset” as an error (which wrongly forced ~48px on
/// gesture navigation). Merged with the platform [implicitView] when present.
double _navBarBottomReserve(BuildContext context) {
  final mq = MediaQuery.of(context);
  double v = mq.viewPadding.bottom;
  final implicit = WidgetsBinding.instance.platformDispatcher.implicitView;
  if (implicit != null) {
    v = max(v, MediaQueryData.fromView(implicit).viewPadding.bottom);
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
