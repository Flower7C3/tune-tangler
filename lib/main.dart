import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:tune_tangler/adapter/audio_input_device_adapter.dart';
import 'package:tune_tangler/adapter/duration_adapter.dart';
import 'package:tune_tangler/adapter/settings_profile.dart';
import 'package:tune_tangler/wrapper/hive_settings_provider.dart';

import 'adapter/app_config_field_key.dart';
import 'adapter/audio_encoder_adapter.dart';
import 'adapter/locale_adapter.dart';
import 'adapter/release_mode_adapter.dart';
import 'adapter/theme_mode_adapter.dart';
import 'adapter/track_adapter.dart';
import 'adapter/track_adapter_key.dart';
import 'adapter/track_audio_source.dart';
import 'adapter/track_id.dart';
import 'screen/main_screen.dart';
import 'src/audio_isolate_service.dart';
import 'src/audio_memory_pool.dart';
import 'src/icon_optimization_service.dart';
import 'wrapper/hive_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  //************************************
  // Initialize
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(LocaleAdapter());
  Hive.registerAdapter(ThemeModeAdapter());
  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(ReleaseModeAdapter());
  Hive.registerAdapter(AudioInputDeviceAdapter());
  Hive.registerAdapter(AudioEncoderAdapter());
  Hive.registerAdapter(TrackAdapterKeyAdapter());
  Hive.registerAdapter(TrackAudioSourceAdapter());
  Hive.registerAdapter(TrackIdAdapter());
  Hive.registerAdapter(TrackAdapter());
  Hive.registerAdapter(SettingsProfileAdapter());
  Hive.registerAdapter(AppConfigFieldKeyAdapter());
  await HiveService.init();
  await AudioIsolateService.initialize();

  // Initialize optimization services
  AudioMemoryPool();
  IconOptimizationService();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(settings: settings);

  //************************************
  // Set main screen
  runApp(
    ChangeNotifierProvider(
      create: (context) => HiveSettingsProvider(),
      child: const MainScreenApp(),
    ),
  );

}
