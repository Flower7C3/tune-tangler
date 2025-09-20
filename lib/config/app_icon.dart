import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:tune_tangler/helper/ui_helper.dart';

class SvgColorMapper implements ColorMapper {
  const SvgColorMapper({
    required this.colors,
  });

  final Map<Color, Color?> colors;

  @override
  Color substitute(String? id, String elementName, String attributeName, Color color) {
    if (colors.containsKey(color)) {
      return colors[color] ?? color;
    }

    return color;
  }
}

class AppIcon {
  static Widget appLogo(Color backgroundColor, Color shapeColor, Color detailColor) => SvgPicture(
        SvgAssetLoader(
          'assets/svg/logo-rgb.svg',
          colorMapper: SvgColorMapper(colors: {
            // Colors.white: backgroundColor,
            // Color.fromRGBO(17, 17, 17, 1): shapeColor,
            // Colors.white: detailColor,
            Color.fromRGBO(255, 0, 0, 1): backgroundColor,
            Color.fromRGBO(0, 255, 0, 1): shapeColor,
            Color.fromRGBO(0, 0, 255, 1): detailColor,
          }),
        ),
      );

  static IconData language = Icons.translate_rounded;
  static IconData help = Icons.help_outline_rounded;
  static IconData screenThemeMode = Icons.contrast_rounded;
  static IconData screenSystemThemeMode = Icons.brightness_5_outlined;
  static IconData screenLightThemeMode = Icons.light_mode_rounded;
  static IconData screenDarkThemeMode = Icons.dark_mode_rounded;
  static IconData screenThemeColor = Icons.palette_rounded;
  static IconData keepScreenOn = Icons.monitor;
  static IconData keepScreenOnDisabled = Icons.lightbulb_outline_rounded;
  static IconData keepScreenOnEnabled = Icons.lightbulb_rounded;
  static IconData gridRowsAmount = Icons.table_rows_rounded;
  static IconData gridColsAmount = Icons.view_column_rounded;
  static IconData grid = Icons.grid_4x4_rounded;

  static IconData trackName = Icons.text_fields;
  static IconData trackKeyboardKey = Icons.keyboard_alt_rounded;

  static IconData trackRecordingMove = Icons.shuffle_rounded;

  static Container trackKeyboardKeyBox(
    String keyName, {
    Color? backgroundColor,
    Color? foregroundColor,
    required double size,
  }) =>
      Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.all(Radius.circular(UIHelper.gridGap)), shape: BoxShape.rectangle),
          child: Text(keyName, style: TextStyle(fontSize: size, height: 1.0, color: foregroundColor)));
  static IconData trackPlaybackMode = Icons.replay_rounded;
  static IconData trackSinglePlaybackMode = Icons.repeat_one_rounded;
  static IconData trackRepeatPlaybackMode = Icons.repeat_rounded;
  static IconData trackPlaybackVolume = Icons.volume_up_rounded;
  static IconData trackPlaybackBalance = Icons.headphones_rounded;
  static IconData trackPlaybackBalanceLeft = Icons.join_left_rounded;
  static IconData trackPlaybackBalanceRight = Icons.join_right_rounded;
  static IconData trackPlaybackBalanceCenter = Icons.join_full_rounded;

  static IconData trackPlaybackSpeed = Icons.slow_motion_video_rounded;
  static IconData trackAudioSourceRecorded = Icons.audio_file_outlined;

  static IconData trackAudioSourceImported = Icons.upload_file_outlined;
  static IconData trackTimer = Symbols.acute_rounded;
  static IconData trackPosition = Symbols.timer_play_rounded;

  static IconData trackDuration = Symbols.timer_rounded;
  static IconData trackPlaybackStartAtPosition = Symbols.align_justify_flex_start_rounded;
  static IconData trackPlaybackStartAtPositionReset = Symbols.first_page_rounded;
  static IconData trackPlaybackEndAtPosition = Symbols.align_justify_flex_end_rounded;
  static IconData trackPlaybackEndAtPositionReset = Symbols.last_page_rounded;
  static IconData trackPlaybackPositionSub = Symbols.fast_rewind_rounded;

  static IconData trackPlaybackPositionAdd = Symbols.fast_forward_rounded;
  static IconData recordingInputDevice = Symbols.settings_input_component;
  static IconData recordingAudioEncoder = Icons.integration_instructions_outlined;
  static IconData recordingSampleRate = Icons.av_timer_rounded;
  static IconData recordingBitRate = Icons.network_check_rounded;
  static IconData recordingAudioMode = Icons.mic_external_on_rounded;
  static IconData recordingAudioModeMono = Icons.mic_rounded;
  static IconData recordingAudioModeStereo = Symbols.mic_double_rounded;
  static IconData recordingAutoGain = Symbols.adjust_rounded;
  static IconData recordingEchoCancel = Symbols.record_voice_over;

  static IconData recordingNoiseSuppress = Symbols.noise_aware_rounded;
  static IconData deleteForever = Icons.delete_forever_rounded;

  static IconData resetAllSettings = Icons.settings_backup_restore_rounded;
  static IconData no = Icons.cancel_outlined;
  static IconData yes = Icons.check_circle_outline_outlined;

  static IconData exception = Icons.error_outline_rounded;
  static IconData trackPlayingStart = Icons.play_arrow_rounded;
  static IconData trackPlayingStop = Icons.stop_rounded;
  static IconData trackPlayingPause = Icons.pause_rounded;
  static IconData trackPlayingResume = Symbols.play_pause_rounded;
  static IconData trackRecordingStart = Icons.fiber_manual_record_rounded;
  static IconData trackRecordingStop = Icons.stop_rounded;
  static IconData trackRecordingCancel = Icons.cancel_rounded;
  static IconData trackRecordingImport = Icons.file_open_rounded;

  static IconData trackRecordingShare = Icons.share_outlined;

  static IconData moreMenu = Icons.more_vert;
  static IconData modalMenu = Symbols.menu_open_rounded;
  static IconData settingProfiles = Symbols.manufacturing;
  static IconData screenSettings = Icons.display_settings;
  static IconData trackSettings = Icons.graphic_eq_rounded;
  static IconData recordingSettings = Icons.settings_voice;

  static IconData permissions = Icons.perm_device_info_rounded;

  static IconData dangerZone = Icons.dangerous_outlined;
  static IconData recordingInProgress = Symbols.voicemail_rounded;
  static IconData recordingProgress = Symbols.edit_audio_rounded;
  static IconData recordingControls = Symbols.instant_mix_rounded;

  static IconData recordingInfo = Symbols.info_rounded;
  static IconData recordingProgressSlider = Symbols.start_rounded;

  static IconData recordingClipSlider = Symbols.align_justify_space_even_rounded;

  static IconData create = Icons.add;

  static IconData touchShort = Symbols.touch_app;
  static IconData touchLong = Symbols.touch_long;
}
