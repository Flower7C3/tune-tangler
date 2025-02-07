import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tune_tangler/adapter/audio_input_device_adapter.dart';

import 'adapter/audio_encoder_adapter.dart';
import 'adapter/locale_adapter.dart';
import 'adapter/release_mode_adapter.dart';
import 'adapter/theme_mode_adapter.dart';
import 'adapter/track_adapter.dart';
import 'screen/main_screen.dart';
import 'screen/splash_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //************************************
  // Set loading screen
  runApp(const SplashScreenApp());

  //************************************
  // Initialize
  await Hive.initFlutter();
  Hive.registerAdapter(LocaleAdapter());
  Hive.registerAdapter(ThemeModeAdapter());
  Hive.registerAdapter(TrackAdapter());
  Hive.registerAdapter(AudioEncoderAdapter());
  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(AudioInputDeviceAdapter());
  Hive.registerAdapter(ReleaseModeAdapter());
  Box globalSettingsBox = await Hive.openBox('settings');
  Box trackSettingsBox = await Hive.openBox('tracks');

  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(settings);

  //************************************
  // Set main screen
  runApp(MainScreenApp(globalSettingsBox: globalSettingsBox, trackSettingsBox: trackSettingsBox));
}
