import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:tune_tangler/src/ui_wrapper.dart';

import '../entity/track.dart';

class AppIcon {
  static IconData logoKeepScreenOnEnabled = Icons.dashboard_customize;
  static IconData logoKeepScreenOnDisabled = Icons.dashboard_customize_outlined;
  static IconData language = Icons.translate_rounded;
  static IconData help = Icons.help_outline_rounded;

  static IconData screenThemeMode = Icons.brightness_4;
  static IconData screenLightThemeMode = Icons.light_mode_rounded;
  static IconData screenDarkThemeMode = Icons.dark_mode_rounded;
  static IconData screenThemeColor = Icons.palette_rounded;
  static IconData keepScreenOn = Icons.monitor;
  static IconData keepScreenOnDisabled = Icons.lightbulb_outline_rounded;
  static IconData keepScreenOnEnabled = Icons.lightbulb_rounded;
  static IconData gridRowsAmount = Icons.table_rows_rounded;
  static IconData gridColsAmount = Icons.view_column_rounded;

  static IconData trackTitleEmojis = Icons.emoji_emotions_rounded;
  static IconData trackTitle = Icons.text_fields;
  static IconData recordingFile = Icons.audio_file_outlined;
  static IconData trackKeyboardKey = Icons.keyboard_alt_rounded;

  static Container trackKeyboardKeyBox(
    Track track, {
    required UIWrapper ui,
    required BuildContext context,
    required Color foregroundColor,
    required double size,
  }) =>
      Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: foregroundColor, borderRadius: BorderRadius.all(Radius.circular(ui.gridGap)), shape: BoxShape.rectangle),
          child: Text(track.keyboardKey.value, style: TextStyle(fontSize: size, height: 1.0, color: track.stateBackgroundColor(context))));

  static IconData trackPlaybackMode = Icons.replay_rounded;
  static IconData trackSinglePlaybackMode = Icons.repeat_one_rounded;
  static IconData trackRepeatPlaybackMode = Icons.repeat_rounded;
  static IconData trackPlaybackVolume = Icons.volume_up_rounded;
  static IconData trackPlaybackBalance = Icons.headphones_rounded;
  static IconData trackPlaybackSpeed = Icons.slow_motion_video_rounded;

  static IconData trackTimer = Symbols.acute_rounded;
  static IconData trackPosition = Symbols.timer_play_rounded;
  static IconData trackDuration = Symbols.timer_rounded;

  static IconData trackPlaybackStartAtPosition = Symbols.logout_rounded;
  static IconData trackPlaybackEndAtPosition = Symbols.login_rounded;
  static IconData trackPlaybackPositionSub1000 = Symbols.fast_rewind;
  static IconData trackPlaybackPositionReset = Symbols.cancel_presentation_rounded;
  static IconData trackPlaybackPositionSub100 = Symbols.arrow_back_2_rounded;
  static IconData trackPlaybackPositionAdd100 = Symbols.play_arrow;
  static IconData trackPlaybackPositionAdd1000 = Symbols.fast_forward;

  static IconData recordingInputDevice = Symbols.settings_input_component;
  static IconData recordingAudioEncoder = Icons.integration_instructions_outlined;
  static IconData recordingSampleRate = Icons.av_timer_rounded;
  static IconData recordingBitRate = Icons.network_check_rounded;
  static IconData recordingAudioMode = Icons.mic_external_on_rounded;
  static IconData recordingAudioModeMono = Icons.mic_rounded;
  static IconData recordingAudioModeStereo = Symbols.mic_double_rounded;
  static IconData recordingAudioGain = Symbols.adjust_rounded;
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

  static IconData screenSettings = Icons.display_settings;
  static IconData trackSettings = Icons.graphic_eq_rounded;
  static IconData recordingSettings = Icons.settings_voice;
  static IconData permissions = Icons.shield_outlined;

  static IconData dangerZone = Icons.dangerous_outlined;

  static IconData recordingInProgress = Symbols.voicemail_rounded;
  static IconData recordingProgress = Symbols.edit_audio_rounded;
  static IconData recordingControls = Symbols.instant_mix_rounded;
  static IconData recordingInfo = Symbols.info_rounded;

  static IconData recordingProgressSlider = Symbols.start_rounded;
  static IconData recordingClipSlider = Symbols.expand_rounded;
}
