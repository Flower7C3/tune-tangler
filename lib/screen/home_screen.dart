import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tune_tangler/config/app_config_fields.dart';
import 'package:tune_tangler/manager/home_screen_manager.dart';
import 'package:tune_tangler/wrapper/app.dart';
import 'package:tune_tangler/wrapper/hive_settings_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    // Listen to locale changes to update AppWrapper.trans without full reload
    return Selector<HiveSettingsProvider, String>(
      selector: (context, settings) => settings.getConfig(AppConfigFieldKey.locale).toLanguageTag(),
      builder: (context, localeTag, child) {
        // Update context and translations when locale changes
        widget.appWrapper.setContext(context);
        // Recreate HomeScreenManager to get fresh translations when locale changes
        _homeScreenManager = HomeScreenManager(widget.appWrapper);
        return Scaffold(
          key: widget.appWrapper.scaffoldKey,
          appBar: _homeScreenManager!.appBar,
          drawer: _homeScreenManager!.drawer,
          body: _homeScreenManager!.body,
          bottomNavigationBar: _homeScreenManager!.bottomNavigationBar,
        );
      },
    );
  }
}
