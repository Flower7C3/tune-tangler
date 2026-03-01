import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../config/app_config_fields.dart';
import '../wrapper/hive_settings_provider.dart';

class ScreenshotService {
  static const _channel = MethodChannel('pro.kwiatek.tune_tangler/screenshot');

  static final Map<String, ExpansibleController> _drawerControllers = {};
  static final Map<String, GlobalKey> _drawerKeys = {};
  static GlobalKey<PopupMenuButtonState<String>>? _popupMenuKey;

  final HiveSettingsProvider _settings;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  ScreenshotService(this._settings, this._scaffoldKey) {
    _channel.setMethodCallHandler(_handle);
  }

  static void registerPopupMenu(GlobalKey<PopupMenuButtonState<String>> key) {
    _popupMenuKey = key;
  }

  static void registerDrawerSection(
    String name,
    ExpansibleController controller,
    GlobalKey key,
  ) {
    _drawerControllers[name] = controller;
    _drawerKeys[name] = key;
  }

  Future<void> _waitForFrame() {
    final completer = Completer<void>();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      completer.complete();
    });
    return completer.future;
  }

  Future<void> _settleAfterRebuild() async {
    await _waitForFrame();
    await Future.delayed(const Duration(milliseconds: 500));
    await _waitForFrame();
  }

  Future<dynamic> _handle(MethodCall call) async {
    try {
      switch (call.method) {
        case 'setLocale':
          final lang = (call.arguments as Map?)?['lang'] as String?;
          if (lang != null) {
            final locale = switch (lang) {
              'pl' => const Locale('pl', 'PL'),
              _ => const Locale('en', 'US'),
            };
            await _settings.setConfig(AppConfigFieldKey.locale, locale);
            await _settleAfterRebuild();
          }
        case 'setThemeMode':
          final mode = (call.arguments as Map?)?['mode'] as String?;
          if (mode != null) {
            final themeMode = switch (mode) {
              'light' => ThemeMode.light,
              'dark' => ThemeMode.dark,
              _ => ThemeMode.system,
            };
            await _settings.setConfig(AppConfigFieldKey.themeMode, themeMode);
            await _settleAfterRebuild();
          }
        case 'openDrawer':
          _scaffoldKey.currentState?.openDrawer();
        case 'closeDrawer':
          _safeCloseDrawer();
        case 'openNavigationMenu':
          _popupMenuKey?.currentState?.showButtonMenu();
        case 'closeNavigationMenu':
          _safeNavigatorPop();
        case 'expandDrawerSection':
          final section = (call.arguments as Map?)?['section'] as String?;
          _collapseAllSections();
          if (section != null && section.isNotEmpty) {
            _expandSection(section);
          }
      }
    } catch (_) {}
  }

  void _safeCloseDrawer() {
    try {
      final state = _scaffoldKey.currentState;
      if (state != null && state.mounted && state.isDrawerOpen) {
        Navigator.of(state.context).pop();
      }
    } catch (_) {}
  }

  void _safeNavigatorPop() {
    try {
      final state = _scaffoldKey.currentState;
      if (state != null && state.mounted) {
        Navigator.of(state.context).pop();
      }
    } catch (_) {}
  }

  void _collapseAllSections() {
    for (final controller in _drawerControllers.values) {
      try {
        if (controller.isExpanded) controller.collapse();
      } catch (_) {}
    }
  }

  void _expandSection(String section) {
    try {
      _drawerControllers[section]?.expand();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        try {
          final key = _drawerKeys[section];
          if (key?.currentContext != null) {
            Scrollable.ensureVisible(
              key!.currentContext!,
              duration: const Duration(milliseconds: 200),
              alignment: 0.0,
            );
          }
        } catch (_) {}
      });
    } catch (_) {}
  }

  void dispose() {
    _channel.setMethodCallHandler(null);
  }
}
