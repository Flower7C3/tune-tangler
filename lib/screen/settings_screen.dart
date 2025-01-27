import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:tune_tangler/screen/screen.dart';

import '../config/config.dart';
import '../src/track_wrapper.dart';
import '../src/ui_wrapper.dart';

class SettingsScreen extends StatefulWidget implements ScreenInterface {
  const SettingsScreen({
    super.key,
    required this.settingsGet,
    required this.settingsSet,
  });

  @override
  final Function(dynamic key, {ConfigSpace space, dynamic defaultValue}) settingsGet;

  @override
  final void Function(dynamic key, dynamic value, {ConfigSpace space, bool updateState}) settingsSet;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppLocalizations _trans;
  late UIWrapper _ui;
  late TrackWrapper _trackWrapper;
  late List<String> _allTracksIds;

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        _allTracksIds = args['allTracksIds'];

        _trans = AppLocalizations.of(context)!;
        _ui = UIWrapper(context);
        _trackWrapper = TrackWrapper(context, widget, _trans, _ui, _allTracksIds);

        return Scaffold(
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text(_trans.title_settings),
                centerTitle: true,
                actions: [IconButton(icon: Icon(Icons.settings_rounded), onPressed: null)]),
            body: ListView(children: _body()));
      });

  List<Widget> _body() => [
        _ui.settingsTileTitle(_trans.screen_settings),
        ListTile(
            leading: Icon(Icons.language_rounded),
            title: Text(_trans.language_version),
            trailing: _ui.trailingLabel(widget.settingsGet(GlobalConfigKey.locale).toLanguageTag()),
            onTap: () {
              var options = <Widget>[];
              Config.languages.forEach((String name, Locale locale) {
                var code = locale.toLanguageTag();
                options.add(SimpleDialogOption(
                    onPressed: () {
                      Navigator.of(context).pop(locale);
                      widget.settingsSet(GlobalConfigKey.locale, locale, updateState: true);
                    },
                    child: Text('$name ($code)')));
              });
              _ui.listDialog(Icons.language_rounded, _trans.title_changeLanguage, actions: options.toList());
            }),
        _ui.listTileSwitch(Icons.brightness_4, _trans.screen_theme_mode, Icons.light_mode_rounded, _trans.light_mode, Icons.dark_mode_rounded,
            _trans.dark_mode, widget.settingsGet(GlobalConfigKey.isThemeModeDark), (bool value) {
          widget.settingsSet(GlobalConfigKey.themeMode, value ? ThemeMode.dark : ThemeMode.light, updateState: true);
          return null;
        }),
        ListTile(
            leading: Icon(Icons.palette_rounded),
            title: Text(_trans.screen_theme_color),
            trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.settingsGet(GlobalConfigKey.themeSeedColor),
                  borderRadius: BorderRadius.circular(24),
                )),
            onTap: () {
              _ui.alertDialog(Icons.palette_rounded, _trans.screen_theme_color_title,
                  contentText: _trans.screen_theme_color_info,
                  contentWidget: _ui.gridBuilder(
                      itemCount: Config.userInterfaceColors.length,
                      itemBuilder: (context, index) {
                        Color color = Config.userInterfaceColors.values.elementAt(index);
                        String name = Config.userInterfaceColors.keys.elementAt(index);
                        return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(16),
                            ),
                            onPressed: () {
                              widget.settingsSet(GlobalConfigKey.themeSeedColor, color, updateState: true);
                              Navigator.of(context).pop(color.toString());
                              _ui.toast(_trans.screen_theme_color_success(name), icon: Icons.palette_rounded);
                            },
                            child: null);
                      }));
            }),
        _ui.listTileSwitch(Icons.monitor, _trans.keep_screen_on, Symbols.light_off_rounded, _trans.disabled, Icons.lightbulb_outline_rounded,
            _trans.enabled, widget.settingsGet(GlobalConfigKey.wakelockEnabled), (bool value) {
          widget.settingsSet(GlobalConfigKey.wakelockEnabled, value, updateState: true);
          return value ? _trans.keep_screen_on_is_disabled_success : _trans.keep_screen_on_is_enabled_success;
        }),
        _ui.listTileSlider(
            Icons.table_rows_rounded,
            _trans.grid_rows_amount,
            _trans.grid_rows_amount_title,
            _trans.grid_rows_amount_info,
            double.parse(widget.settingsGet(GlobalConfigKey.gridRowsAmount).toString()),
            Config.gridRows.minValue,
            Config.gridRows.maxValue,
            Config.gridRows.divisions,
            Config.gridRows.valueFormatter,
            _trans.button_cancel,
            _trans.button_save, (double value, String formattedValue) {
          widget.settingsSet(GlobalConfigKey.gridRowsAmount, value.toInt(), updateState: true);
          return _trans.grid_rows_amount_success(formattedValue);
        }),
        _ui.listTileSlider(
            Icons.view_column_rounded,
            _trans.grid_cols_amount,
            _trans.grid_cols_amount_title,
            _trans.grid_cols_amount_info,
            double.parse(widget.settingsGet(GlobalConfigKey.gridColsAmount).toString()),
            Config.gridCols.minValue,
            Config.gridCols.maxValue,
            Config.gridCols.divisions,
            Config.gridCols.valueFormatter,
            _trans.button_cancel,
            _trans.button_save, (double value, String formattedValue) {
          widget.settingsSet(GlobalConfigKey.gridColsAmount, value.toInt(), updateState: true);
          return _trans.grid_cols_amount_success(formattedValue);
        }),
        _ui.settingsTileTitle(_trans.track_settings),
        ListTile(
            leading: Icon(Icons.emoji_emotions_rounded),
            title: Text(_trans.track_title_emojis),
            subtitle: Text(widget.settingsGet(GlobalConfigKey.emojis), style: TextStyle(fontSize: _ui.settingsSubtitleFontSize)),
            onTap: () {
              final TextEditingController textController = TextEditingController(text: widget.settingsGet(GlobalConfigKey.emojis));
              _ui.alertDialog(Icons.emoji_emotions_rounded, _trans.track_title_emojis_title,
                  contentWidget: TextField(
                      controller: textController,
                      maxLines: 4,
                      decoration: InputDecoration(hintText: _trans.track_title_emojis_info, border: OutlineInputBorder())),
                  actions: <Widget>[
                    _ui.simpleButton(_trans.button_cancel, () {
                      Navigator.of(context).pop(_trans.button_cancel);
                    }),
                    _ui.primaryButton(_trans.button_save, () {
                      setState(() {
                        widget.settingsSet(GlobalConfigKey.emojis, textController.text, updateState: true);
                        _ui.toast(_trans.track_title_emojis_success, icon: Icons.emoji_emotions_rounded);
                        Navigator.of(context).pop(_trans.button_save);
                      });
                    }),
                  ]);
            }),
        _ui.listTileReset(Icons.text_fields, _trans.reset_all_tracks_title, _trans.reset_all_tracks_title_title, _trans.reset_all_tracks_title_info,
            _trans.button_no, _trans.button_yes, () {
          _trackWrapper.resetTracksName(_allTracksIds);
          return _trans.reset_all_tracks_title_success;
        }),
        _ui.listTileReset(Icons.keyboard_alt_rounded, _trans.reset_all_tracks_shortcut_key, _trans.reset_all_tracks_shortcut_key_title,
            _trans.reset_all_tracks_shortcut_key_info, _trans.button_no, _trans.button_yes, () {
          _trackWrapper.resetTracksKeyboardKey(_allTracksIds);
          return _trans.reset_all_tracks_shortcut_key_success;
        }),
        ListTile(
            leading: Icon(Icons.repeat_on_rounded),
            title: Text(_trans.set_all_tracks_playback_mode),
            onTap: () {
              var options = <Widget>[];
              options.add(SimpleDialogOption(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.repeat_one_rounded, size: 16), Text(' '), Text(_trans.single_playback_mode)]),
                  onPressed: () {
                    setState(() {
                      _trackWrapper.setTracksPlaybackMode(_allTracksIds, true);
                      _ui.toast(_trans.set_all_tracks_playback_mode_success(_trans.single_playback_mode), icon: Icons.repeat_one_rounded);
                      Navigator.of(context).pop(_trans.single_playback_mode);
                    });
                  }));
              options.add(SimpleDialogOption(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.repeat_rounded, size: 16), Text(' '), Text(_trans.repeat_playback_mode)]),
                  onPressed: () {
                    setState(() {
                      _trackWrapper.setTracksPlaybackMode(_allTracksIds, false);
                      _ui.toast(_trans.set_all_tracks_playback_mode_success(_trans.repeat_playback_mode), icon: Icons.repeat_rounded);
                      Navigator.of(context).pop(_trans.repeat_playback_mode);
                    });
                  }));
              _ui.listDialog(Icons.repeat_on_rounded, _trans.set_all_tracks_playback_mode_title,
                  contentText: _trans.set_all_tracks_playback_mode_info, actions: options.toList());
            }),
        _ui.listTileSlider(
            Icons.volume_up_rounded,
            _trans.set_all_tracks_playback_volume,
            _trans.set_all_tracks_playback_volume_title,
            _trans.set_all_tracks_playback_volume_info,
            Config.trackPlaybackVolumeSliderValues.defaultValue!,
            Config.trackPlaybackVolumeSliderValues.minValue,
            Config.trackPlaybackVolumeSliderValues.maxValue,
            Config.trackPlaybackVolumeSliderValues.divisions,
            Config.trackPlaybackVolumeSliderValues.valueFormatter,
            _trans.button_cancel,
            _trans.button_save, (double value, String formattedValue) {
          _trackWrapper.setTracksPlaybackVolume(_allTracksIds, value);
          return _trans.set_all_tracks_playback_volume_success(formattedValue);
        }, withTrailing: false),
        _ui.listTileSlider(
            Icons.speed_rounded,
            _trans.set_all_tracks_playback_speed,
            _trans.set_all_tracks_playback_speed_title,
            _trans.set_all_tracks_playback_speed_info,
            Config.trackPlaybackSpeedSliderValues.defaultValue!,
            Config.trackPlaybackSpeedSliderValues.minValue,
            Config.trackPlaybackSpeedSliderValues.maxValue,
            Config.trackPlaybackSpeedSliderValues.divisions,
            Config.trackPlaybackSpeedSliderValues.valueFormatter,
            _trans.button_cancel,
            _trans.button_save, (double value, String formattedValue) {
          _trackWrapper.setTracksPlaybackSpeed(_allTracksIds, value);
          return _trans.set_all_tracks_playback_speed_success(formattedValue);
        }, withTrailing: false),
        _ui.settingsTileTitle(_trans.recording_settings),
        _ui.listTileSwitch(Symbols.screen_record, _trans.recording_probing_mode, Icons.sd, _trans.recording_probing_mode_option_low, Icons.hd,
            _trans.recording_probing_mode_option_high, widget.settingsGet(GlobalConfigKey.recordingProbingModeHigh), (bool value) {
          widget.settingsSet(GlobalConfigKey.recordingProbingModeHigh, value, updateState: true);
          return _trans.recording_probing_mode_success(value ? _trans.recording_probing_mode_option_high : _trans.recording_probing_mode_option_low);
        }),
        _ui.listTileSwitch(
            Icons.mic_external_on_rounded,
            _trans.recording_audio_mode,
            Icons.mic_rounded,
            _trans.recording_audio_mode_option_mono,
            Symbols.mic_double_rounded,
            _trans.recording_audio_mode_option_stereo,
            widget.settingsGet(GlobalConfigKey.recordingAudioModeStereo), (bool value) {
          widget.settingsSet(GlobalConfigKey.recordingAudioModeStereo, value, updateState: true);
          return _trans.recording_audio_mode_success(value ? _trans.recording_audio_mode_option_stereo : _trans.recording_audio_mode_option_mono);
        }),
        _ui.settingsTileDivider(),
        _ui.listTileReset(Icons.delete_forever_rounded, _trans.delete_all_tracks_recordings, _trans.delete_all_tracks_recordings_title,
            _trans.delete_all_tracks_recordings_info, _trans.button_no, _trans.button_yes, () {
          _trackWrapper.removeTracksRecordings(_allTracksIds);
          return _trans.delete_all_tracks_recordings_success;
        }),
        _ui.listTileReset(Icons.settings_backup_restore_rounded, _trans.reset_all_settings, _trans.reset_all_settings_title,
            _trans.reset_all_settings_info, _trans.button_no, _trans.button_yes, () {
              Config.settingsFields().forEach((GlobalConfigKeyNameDefaults field) {
            widget.settingsSet(field.key, field.defaultValue, updateState: true);
          });
          _trackWrapper.resetTracksName(_allTracksIds);
          _trackWrapper.resetTracksKeyboardKey(_allTracksIds);
          _trackWrapper.setTracksPlaybackMode(_allTracksIds, true);
          _trackWrapper.setTracksPlaybackSpeed(_allTracksIds, 1);
          _trackWrapper.setTracksPlaybackVolume(_allTracksIds, 100);
          return _trans.reset_all_settings_success;
        }),
      ];
}
