import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../src/config.dart';
import '../src/io.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settingsGet,
    required this.settingsSet,
  });

  final Function(dynamic key) settingsGet;
  final void Function(dynamic key, dynamic value) settingsSet;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppLocalizations _trans;
  late IO _io;

  final double _titleFontSize = 20;
  final double _helpIconSize = 12;
  final double _helpFontSize = 12;

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        _trans = AppLocalizations.of(context)!;
        _io = IO(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(_trans.title_settings),
            centerTitle: true,
            actions: [IconButton(icon: Icon(Icons.settings_rounded), onPressed: null)],
          ),
          body: ListView(
            children: [
              _tileTitle(_trans.screen_settings),
              ListTile(
                  leading: Icon(Icons.language_rounded),
                  title: Text(_trans.language_version),
                  trailing: _io.trailingLabel(widget.settingsGet(GlobalConfigKey.locale).toLanguageTag()),
                  onTap: () {
                    var options = <Widget>[];
                    Config.languages.forEach((String name, Locale locale) {
                      var code = locale.toLanguageTag();
                      options.add(SimpleDialogOption(
                          onPressed: () {
                            Navigator.of(context).pop(locale);
                            widget.settingsSet(GlobalConfigKey.locale, locale);
                          },
                          child: Text('$name ($code)')));
                    });
                    _io.listDialog(Icons.language_rounded, _trans.title_changeLanguage, actions: options.toList());
                  }),
              ListTile(
                  leading: Icon(Icons.brightness_4),
                  title: Text(_trans.screen_theme_mode),
                  subtitle: Row(children: [
                    Icon(Icons.light_mode_rounded, size: _helpIconSize),
                    Text(_trans.light_mode, style: TextStyle(fontSize: _helpFontSize)),
                    Text(' '),
                    Icon(Icons.dark_mode_rounded, size: _helpIconSize),
                    Text(_trans.dark_mode, style: TextStyle(fontSize: _helpFontSize)),
                  ]),
                  trailing: _io.primarySwitch(
                      widget.settingsGet(GlobalConfigKey.isThemeModeDark) ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      widget.settingsGet(GlobalConfigKey.isThemeModeDark), onChanged: (bool value) {
                    widget.settingsSet(GlobalConfigKey.themeMode, value ? ThemeMode.dark : ThemeMode.light);
                  })),
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
                    var grid = Flexible(
                        child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                            padding: const EdgeInsets.all(0),
                            itemCount: Config.colors.length,
                            itemBuilder: (context, index) {
                              Color color = Config.colorValues().elementAt(index);
                              String name = Config.colorNames().elementAt(index);
                              return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(16),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop(color.toString());
                                    widget.settingsSet(GlobalConfigKey.themeSeedColor, color);
                                    _io.toast(_trans.screen_theme_color_done(name), icon: Icons.palette_rounded);
                                  },
                                  child: null);
                            }));
                    _io.alertDialog(Icons.palette_rounded, _trans.screen_theme_color_title,
                        contentText: _trans.screen_theme_color_info, contentWidget: grid);
                  }),
              ListTile(
                  leading: Icon(Icons.monitor),
                  title: Text(_trans.keep_screen_on),
                  subtitle: Row(children: [
                    Icon(Symbols.light_off_rounded, size: _helpIconSize),
                    Text(_trans.disabled, style: TextStyle(fontSize: _helpFontSize)),
                    Text(' '),
                    Icon(Icons.lightbulb_outline_rounded, size: _helpIconSize),
                    Text(_trans.enabled, style: TextStyle(fontSize: _helpFontSize)),
                  ]),
                  trailing: _io.primarySwitch(
                      widget.settingsGet(GlobalConfigKey.wakelockEnabled) ? Icons.lightbulb_outline_rounded : Symbols.light_off_rounded,
                      widget.settingsGet(GlobalConfigKey.wakelockEnabled), onChanged: (bool value) {
                    widget.settingsSet(GlobalConfigKey.wakelockEnabled, value);
                    _io.toast(value ? _trans.keep_screen_on_is_enabled_done : _trans.keep_screen_on_is_disabled_done,
                        icon: value ? Icons.lightbulb_outline_rounded : Symbols.light_off_rounded);
                  })),
              ListTile(
                  leading: Icon(Icons.table_rows_rounded),
                  title: Text(_trans.grid_rows_amount),
                  trailing: _io.trailingLabel(widget.settingsGet(GlobalConfigKey.gridRowsAmount).toString()),
                  onTap: () {
                    // double currentValue = widget.settingsGet(GlobalConfigKey.gridRowsAmount).toDouble();
                    _io.alertDialog(Icons.table_rows_rounded, _trans.grid_rows_amount_title,
                        contentWidget: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(_trans.grid_cols_amount_info),
                          // StatefulBuilder(
                          //     builder: (context, state) =>
                          //         Slider(
                          //         value: currentValue,
                          //         min: Config.gridRowsMin,
                          //         max: Config.gridRowsMax,
                          //         divisions: (Config.gridRowsMax - Config.gridRowsMin).toInt(),
                          //         label: currentValue.toString(),
                          //         onChanged: (double newValue) {
                          // state(() {
                          //   currentValue = newValue;
                          // });
                          // })
                          // ),
                        ]),
                        actions: <Widget>[
                          _io.simpleButton(_trans.button_cancel, () {
                            Navigator.of(context).pop(_trans.button_cancel);
                          }),
                          // _io.primaryButton(_trans.button_save, () {
                          //   Navigator.of(context).pop(_trans.button_save');
                          // widget.settingsSet(ConfigSettings.gridRowsAmount, currentValue.toInt());
                          // _io.toast(_trans.grid_rows_amount_done(currentValue.toInt()));
                          // }),
                        ]);
                  }),
              ListTile(
                  leading: Icon(Icons.view_column_rounded),
                  title: Text(_trans.grid_cols_amount),
                  trailing: _io.trailingLabel(widget.settingsGet(GlobalConfigKey.gridColsAmount).toString()),
                  onTap: () {
                    // double currentValue = widget.settingsGet(GlobalConfigKey.gridColsAmount).toDouble();
                    _io.alertDialog(Icons.view_column_rounded, _trans.grid_cols_amount_title,
                        contentWidget: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(_trans.grid_cols_amount_info),
                          //         Slider(
                          //             value: currentValue,
                          //             min: Config.gridColsMin,
                          //             max: Config.gridColsMax,
                          //             divisions: (Config.gridColsMax - Config.gridColsMin).toInt(),
                          //             label: currentValue.toString(),
                          //             onChanged: (double newValue) {
                          //               setState(() {
                          //                 currentValue = newValue;
                          //               });
                          //             }),
                        ]),
                        actions: <Widget>[
                          _io.simpleButton(_trans.button_cancel, () {
                            Navigator.of(context).pop(_trans.button_cancel);
                          }),
                          //         _io.primaryButton(_trans.button_save, () {
                          //           Navigator.of(context).pop(_trans.button_save');
                          //           widget.settingsSet(ConfigSettings.gridColsAmount, currentValue.toInt());
                          //           _io.toast(_trans.grid_cols_amount_done(currentValue.toInt()));
                          //         }),
                        ]);
                  }),
              _tileTitle(_trans.track_settings),
              ListTile(
                  leading: Icon(Icons.emoji_emotions_rounded),
                  title: Text(_trans.track_title_emojis),
                  subtitle: Text(widget.settingsGet(GlobalConfigKey.emojis), style: TextStyle(fontSize: _helpFontSize)),
                  onTap: () {
                    final TextEditingController textController = TextEditingController(text: widget.settingsGet(GlobalConfigKey.emojis));
                    _io.alertDialog(Icons.emoji_emotions_rounded, _trans.track_title_emojis_title,
                        contentWidget: TextField(
                            controller: textController,
                            maxLines: 4,
                            decoration: InputDecoration(hintText: _trans.track_title_emojis_info, border: OutlineInputBorder())),
                        actions: <Widget>[
                          _io.simpleButton(_trans.button_cancel, () {
                            Navigator.of(context).pop(_trans.button_cancel);
                          }),
                          _io.primaryButton(_trans.button_save, () {
                            Navigator.of(context).pop(_trans.button_save);
                            widget.settingsSet(GlobalConfigKey.emojis, textController.text);
                            _io.toast(_trans.track_title_emojis_done, icon: Icons.emoji_emotions_rounded);
                          }),
                        ]);
                  }),
              ListTile(
                  leading: Icon(Icons.graphic_eq_rounded),
                  title: Text(_trans.reset_global_tracks_title),
                  onTap: () {
                    _io.alertDialog(Icons.graphic_eq_rounded, _trans.reset_global_tracks_title_title,
                        contentText: _trans.reset_global_tracks_title_info,
                        actions: <Widget>[
                          _io.simpleButton(_trans.button_no, () {
                            Navigator.of(context).pop(_trans.button_no);
                          }),
                          _io.errorButton(_trans.button_yes, () {
                            // TODO
                            Navigator.of(context).pop(_trans.button_yes);
                            _io.toast(_trans.reset_global_tracks_title_done, icon: Icons.graphic_eq_rounded);
                          }),
                        ]);
                  }),
              ListTile(
                  leading: Icon(Icons.keyboard_alt_rounded),
                  title: Text(_trans.reset_global_tracks_shortcut_key),
                  onTap: () {
                    _io.alertDialog(Icons.keyboard_alt_rounded, _trans.reset_global_tracks_shortcut_key_title,
                        contentText: _trans.reset_global_tracks_shortcut_key_info,
                        actions: <Widget>[
                          _io.simpleButton(_trans.button_no, () {
                            Navigator.of(context).pop(_trans.button_no);
                          }),
                          _io.errorButton(_trans.button_yes, () {
                            // TODO
                            Navigator.of(context).pop(_trans.button_yes);
                            _io.toast(_trans.reset_global_tracks_shortcut_key_done, icon: Icons.keyboard_alt_rounded);
                          }),
                        ]);
                  }),
              ListTile(
                  leading: Icon(Icons.repeat_on_rounded),
                  title: Text(_trans.reset_global_tracks_repeat_mode),
                  onTap: () {
                    var options = <Widget>[];
                    options.add(SimpleDialogOption(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.repeat_one_rounded, size: 16), Text(' '), Text(_trans.single_playback_mode)]),
                        onPressed: () {
                          // TODO
                          Navigator.of(context).pop(_trans.single_playback_mode);
                          _io.toast(_trans.reset_global_tracks_repeat_mode_done(_trans.single_playback_mode), icon: Icons.repeat_one_rounded);
                        }));
                    options.add(SimpleDialogOption(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.repeat_rounded, size: 16), Text(' '), Text(_trans.repeat_playback_mode)]),
                        onPressed: () {
                          // TODO
                          Navigator.of(context).pop(_trans.repeat_playback_mode);
                          _io.toast(_trans.reset_global_tracks_repeat_mode_done(_trans.repeat_playback_mode), icon: Icons.repeat_rounded);
                        }));
                    _io.listDialog(Icons.repeat_on_rounded, _trans.reset_global_tracks_repeat_mode_title,
                        contentText: _trans.reset_global_tracks_repeat_mode_info, actions: options.toList());
                  }),
              ListTile(
                  leading: Icon(Icons.volume_up_rounded),
                  title: Text(_trans.reset_global_tracks_playback_volume),
                  onTap: () {
                    var options = <Widget>[];
                    Config.playbackVolumes.forEach((value, name) {
                      options.add(SimpleDialogOption(
                          onPressed: () {
                            // TODO
                            Navigator.of(context).pop(name);
                            _io.toast(_trans.reset_global_tracks_repeat_mode_done(name), icon: Icons.volume_up_rounded);
                          },
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(name)])));
                    });
                    _io.listDialog(Icons.volume_up_rounded, _trans.reset_global_tracks_playback_volume_title,
                        contentText: _trans.reset_global_tracks_playback_volume_info, actions: options.toList());
                  }),
              ListTile(
                  leading: Icon(Icons.speed_rounded),
                  title: Text(_trans.reset_global_playback_speed),
                  onTap: () {
                    var options = <Widget>[];
                    Config.playbackSpeeds.forEach((value, icon) {
                      options.add(SimpleDialogOption(
                          onPressed: () {
                            // TODO
                            Navigator.of(context).pop(value);
                            _io.toast(_trans.reset_global_playback_speed_done(value), icon: Icons.speed_rounded);
                          },
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16)])));
                    });
                    _io.listDialog(Icons.speed_rounded, _trans.reset_global_playback_speed_title,
                        contentText: _trans.reset_global_playback_speed_info, actions: options.toList());
                  }),
              _tileTitle(_trans.recording_settings),
              ListTile(
                  leading: Icon(Symbols.screen_record),
                  title: Text(_trans.recording_probing_mode),
                  subtitle: Row(children: [
                    Icon(Icons.hd, size: _helpIconSize),
                    Text(_trans.recording_probing_mode_option_low, style: TextStyle(fontSize: _helpFontSize)),
                    Text(' '),
                    Icon(Icons.sd, size: _helpIconSize),
                    Text(_trans.recording_probing_mode_option_high, style: TextStyle(fontSize: _helpFontSize)),
                  ]),
                  trailing: _io.primarySwitch(widget.settingsGet(GlobalConfigKey.recordingProbingModeHigh) ? Icons.hd : Icons.sd,
                      widget.settingsGet(GlobalConfigKey.recordingProbingModeHigh), onChanged: (bool value) {
                    widget.settingsSet(GlobalConfigKey.recordingProbingModeHigh, value);
                    _io.toast(
                        _trans.recording_probing_mode_done(
                            value ? _trans.recording_probing_mode_option_high : _trans.recording_probing_mode_option_low),
                        icon: value ? Icons.hd : Icons.sd);
                  })),
              ListTile(
                  leading: Icon(Icons.mic_external_on_rounded),
                  title: Text(_trans.recording_audio_mode),
                  subtitle: Row(children: [
                    Icon(Icons.mic_rounded, size: _helpIconSize),
                    Text(_trans.recording_audio_mode_option_mono, style: TextStyle(fontSize: _helpFontSize)),
                    Text(' '),
                    Icon(Symbols.mic_double_rounded, size: _helpIconSize),
                    Text(_trans.recording_audio_mode_option_stereo, style: TextStyle(fontSize: _helpFontSize)),
                  ]),
                  trailing: _io.primarySwitch(
                      widget.settingsGet(GlobalConfigKey.recordingAudioModeStereo) ? Symbols.mic_double_rounded : Icons.mic_rounded,
                      widget.settingsGet(GlobalConfigKey.recordingAudioModeStereo), onChanged: (bool value) {
                    widget.settingsSet(GlobalConfigKey.recordingAudioModeStereo, value);
                    _io.toast(
                        _trans.recording_audio_mode_done(value ? _trans.recording_audio_mode_option_stereo : _trans.recording_audio_mode_option_mono),
                        icon: value ? Symbols.mic_double_rounded : Icons.mic_rounded);
                  })),
              ListTile(
                  leading: Icon(Icons.delete_forever_rounded),
                  title: Text(_trans.delete_all_recordings),
                  onTap: () {
                    _io.alertDialog(Icons.delete_forever_rounded, _trans.delete_all_recordings_title,
                        contentText: _trans.delete_all_recordings_info,
                        actions: <Widget>[
                          _io.simpleButton(_trans.button_no, () {
                            Navigator.of(context).pop(_trans.button_no);
                          }),
                          _io.errorButton(_trans.button_yes, () {
                            // TODO
                            Navigator.of(context).pop(_trans.button_yes);
                            _io.toast(_trans.delete_all_recordings_done, icon: Icons.delete_forever_rounded);
                          }),
                        ]);
                  }),
              _tileDivider(),
              ListTile(
                  leading: Icon(Icons.settings_backup_restore_rounded),
                  title: Text(_trans.reset_all_settings),
                  onTap: () {
                    _io.alertDialog(Icons.settings_backup_restore_rounded, _trans.reset_all_settings_title,
                        contentText: _trans.reset_all_settings_info,
                        actions: <Widget>[
                          _io.simpleButton(_trans.button_no, () {
                            Navigator.of(context).pop(_trans.button_no);
                          }),
                          _io.errorButton(_trans.button_yes, () {
                            // TODO
                            Navigator.of(context).pop(_trans.button_yes);
                            _io.toast(_trans.reset_all_settings_done, icon: Icons.settings_backup_restore_rounded);
                          }),
                        ]);
                  }),
            ],
          ),
        );
      });

  Divider _tileDivider() => Divider(height: 0, thickness: 1, indent: 20, endIndent: 20, color: Colors.black);

  ListTile _tileTitle(title) => ListTile(title: Center(child: Text(title, style: TextStyle(fontSize: _titleFontSize))));
}
