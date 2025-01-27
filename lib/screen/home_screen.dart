import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/menu_item.dart';
import '../entity/track_row.dart';
import '../config/config.dart';
import '../entity/track.dart';
import '../src/track_wrapper.dart';
import '../src/ui_wrapper.dart';
import 'screen.dart';

class HomeScreen extends StatefulWidget implements ScreenInterface {
  const HomeScreen({
    super.key,
    required this.settingsGet,
    required this.settingsSet,
  });

  @override
  final Function(dynamic key, {ConfigSpace space, dynamic defaultValue}) settingsGet;

  @override
  final void Function(dynamic key, dynamic value, {ConfigSpace space, bool updateState}) settingsSet;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppLocalizations _trans;
  late UIWrapper _ui;
  late TrackWrapper _trackWrapper;
  final _allTracksIds = <String>[];

  bool loading = false;

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        _trans = AppLocalizations.of(context)!;
        _ui = UIWrapper(context);
        _trackWrapper = TrackWrapper(context, widget, _trans, _ui, _allTracksIds);

        Widget body;
        if (loading == true) {
          body = Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(strokeWidth: 8)]));
        } else {
          body = Column(children: [Expanded(child: _buildTracksGrid())]);
        }

        return Scaffold(
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text(_trans.homeTitle),
                leading: Icon(Icons.dashboard_customize),
                actions: _buildTopMenu()),
            body: body,
            bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: _buildFooter()));
      });

  /// *************************************************************************
  /// TOP MENU
  List<Widget> _buildTopMenu() {
    var items = <Widget>[];
    items.add(IconButton(
      icon: Icon(Icons.play_arrow_rounded),
      tooltip: _trans.start_playing_all_tracks,
      onPressed: () {
        _trackWrapper.startTracksPlaying(_allTracksIds);
      },
    ));
    items.add(IconButton(
      icon: Icon(Icons.stop_rounded),
      tooltip: _trans.stop_playing_all_tracks,
      onPressed: () {
        _trackWrapper.stopTracksPlaying(_allTracksIds);
      },
    ));
    items.add(PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => _topMenuItems(),
      onSelected: (String selection) {
        _topMenuItemSelected(TopMenuItem.values.byName(selection.replaceAll('TopMenuItem.', '')));
      },
    ));
    return items.toList();
  }

  List<PopupMenuEntry<String>> _topMenuItems() {
    List<PopupMenuEntry<String>> menuItems = [];
    menuItems.add(_ui.topPopupMenuItem(TopMenuItem.changeLanguage, Icons.language_rounded, _trans.menu_translation));
    if (widget.settingsGet(GlobalConfigKey.isThemeModeDark)) {
      menuItems.add(_ui.topPopupMenuItem(TopMenuItem.themeModeLight, Icons.light_mode_rounded, _trans.menu_light_mode));
    } else {
      menuItems.add(_ui.topPopupMenuItem(TopMenuItem.themeModeDark, Icons.dark_mode_rounded, _trans.menu_dark_mode));
    }
    if (widget.settingsGet(GlobalConfigKey.wakelockEnabled)) {
      menuItems
          .add(_ui.topPopupMenuItem(TopMenuItem.keepScreenOnDisable, Icons.lightbulb_outline_rounded, _trans.menu_keep_screen_on, checked: true));
    } else {
      menuItems.add(_ui.topPopupMenuItem(TopMenuItem.keepScreenOnEnable, Icons.lightbulb_rounded, _trans.menu_keep_screen_on, checked: false));
    }
    menuItems.add(_ui.topPopupMenuItem(TopMenuItem.settings, Icons.settings_rounded, _trans.menu_settings));
    menuItems.add(_ui.topPopupMenuItem(TopMenuItem.help, Icons.help_rounded, _trans.menu_help));
    return menuItems;
  }

  void _topMenuItemSelected(TopMenuItem selection) async {
    switch (selection) {
      case TopMenuItem.changeLanguage:
        var options = <Widget>[];
        Config.languages.forEach((String name, Locale locale) {
          var code = locale.toLanguageTag();
          options.add(SimpleDialogOption(
            onPressed: () {
              widget.settingsSet(GlobalConfigKey.locale, locale, updateState: true);
              Navigator.of(context).pop(locale);
            },
            child: Text('$name ($code)'),
          ));
        });
        _ui.listDialog(Icons.language_rounded, _trans.title_changeLanguage, actions: options.toList());
        break;
      case TopMenuItem.keepScreenOnEnable:
        widget.settingsSet(GlobalConfigKey.wakelockEnabled, true, updateState: true);
        break;
      case TopMenuItem.keepScreenOnDisable:
        widget.settingsSet(GlobalConfigKey.wakelockEnabled, false, updateState: true);
        break;
      case TopMenuItem.themeModeLight:
        widget.settingsSet(GlobalConfigKey.themeMode, ThemeMode.light, updateState: true);
        break;
      case TopMenuItem.themeModeDark:
        widget.settingsSet(GlobalConfigKey.themeMode, ThemeMode.dark, updateState: true);
        break;
      case TopMenuItem.settings:
        setState(() {
          loading = true;
        });
        await Navigator.pushNamed(context, '/settings', arguments: {'allTracksIds': _allTracksIds});
        setState(() {
          loading = false;
        });
        break;
      case TopMenuItem.help:
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        _ui.aboutDialog(
            packageInfo,
            [
              _ui.helpSection(_trans.help_screen_message_about_title, [
                Text(_trans.help_screen_message_about_content),
              ]),
              _ui.helpSection(_trans.help_screen_message_usage_title, [
                Text(_trans.help_screen_message_usage_content_1),
                _ui.helpTrackState(TrackState.empty, _trans.help_screen_message_usage_content_1_state_empty),
                _ui.helpTrackState(TrackState.recording, _trans.help_screen_message_usage_content_1_state_recording),
                _ui.helpTrackState(TrackState.stopped, _trans.help_screen_message_usage_content_1_state_stopped),
                _ui.helpTrackState(TrackState.playing, _trans.help_screen_message_usage_content_1_state_playing),
                _ui.helpTrackState(TrackState.paused, _trans.help_screen_message_usage_content_1_state_paused),
                SizedBox(height: 6),
                Text(_trans.help_screen_message_usage_content_2),
                SizedBox(height: 6),
                Text(_trans.help_screen_message_usage_content_3),
              ]),
            ],
            applicationLegalese: _trans.footer_copy);
        break;
    }
  }

  /// *************************************************************************
  /// TRACKS GRID
  dynamic _buildTracksGrid() => ListView.builder(
      itemCount: widget.settingsGet(GlobalConfigKey.gridRowsAmount),
      itemBuilder: (context, rowIndex) {
        return Row(children: [
          _buildRow(rowIndex),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  widget.settingsGet(GlobalConfigKey.gridColsAmount),
                  (columnIndex) {
                    String trackId = Track.buildId(rowIndex, columnIndex);
                    _allTracksIds.add(trackId);
                    Track track = widget.settingsGet(trackId, space: ConfigSpace.track, defaultValue: Track(rowIndex, columnIndex));
                    _trackWrapper.save(track);
                    return Container(
                      margin: EdgeInsets.all(_ui.trackItemMargin),
                      width: _ui.trackItemWidth,
                      child: ElevatedButton(
                        onPressed: () {
                          _trackPressed(track);
                        },
                        onLongPress: () {
                          _trackDetails(track);
                        },
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(_ui.trackPadding),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_ui.trackBorderRadius)),
                            backgroundColor: track.stateBackgroundColor(context),
                            foregroundColor: track.stateForegroundColor(context)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _trackButton(track),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        ]);
      });

  /// *************************************************************************
  /// ROW
  Container _buildRow(rowIndex) {
    var rowName = TrackRow.name(rowIndex);
    List<String> rowTrackIds = [];
    int columns = widget.settingsGet(GlobalConfigKey.gridColsAmount);
    for (int colIndex = 0; colIndex < columns; colIndex++) {
      rowTrackIds.add(Track.buildId(rowIndex, colIndex));
    }

    var buttons = <Widget>[];
    buttons.add(Container(
        margin: EdgeInsets.all(0),
        width: _ui.rowButtonIconSize + _ui.rowContainerPadding * 2,
        height: _ui.rowButtonIconSize + _ui.rowContainerPadding * 2,
        padding: EdgeInsets.all(_ui.rowContainerPadding),
        child: _ui.mediaPlayerButton(Icons.play_arrow_rounded, _trans.start_playing_row_tracks(rowName), () {
          _trackWrapper.startTracksPlaying(rowTrackIds);
        })));
    buttons.add(Container(
        margin: EdgeInsets.all(0),
        width: _ui.rowButtonIconSize + _ui.rowContainerPadding * 2,
        height: _ui.rowButtonIconSize + _ui.rowContainerPadding * 2,
        padding: EdgeInsets.all(_ui.rowContainerPadding),
        child: _ui.mediaPlayerButton(Icons.stop_rounded, _trans.stop_playing_row_tracks(rowName), () {
          _trackWrapper.stopTracksPlaying(rowTrackIds);
        })));
    buttons.add(Container(
        margin: EdgeInsets.all(0),
        width: _ui.rowButtonIconSize + _ui.rowContainerPadding * 2,
        height: _ui.rowButtonIconSize + _ui.rowContainerPadding * 2,
        padding: EdgeInsets.all(_ui.rowContainerPadding),
        child: _rowMenu(rowName, rowTrackIds)));
    return Container(
        width: _ui.gridFirstColumnWidth,
        padding: EdgeInsets.zero,
        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: buttons.toList()));
  }

  PopupMenuButton _rowMenu(String rowName, List<String> tracks) => PopupMenuButton<dynamic>(
        style: _ui.circledButtonStyle(),
        icon: Icon(Icons.more_vert, size: _ui.rowButtonIconSize, color: Theme.of(context).colorScheme.secondary),
        itemBuilder: (BuildContext context) => _rowMenuItems(rowName, tracks),
        onSelected: (dynamic selection) {
          _rowMenuItemSelected(selection, rowName, tracks);
        },
      );

  List<PopupMenuEntry<dynamic>> _rowMenuItems(String rowName, List<String> tracks) => <PopupMenuEntry<dynamic>>[
        _ui.rowMenuButton(RowMenuItem.playbackMode, Icons.repeat_on_rounded, _trans.set_row_tracks_playback_mode, () {
          var items = <PopupMenuItem<dynamic>>[];
          for (var data in Config.trackPlaybackModeValueIcons) {
            items.add(_ui.rowPopupMenuItem(
              data.value,
              data.icon,
              _trans.set_row_tracks_playback_mode_title((data.value == 1) ? _trans.single_playback_mode : _trans.repeat_playback_mode),
            ));
          }
          return items.toList();
        }, (selection) {
          Navigator.pop(context);
          setState(() {
            _trackWrapper.setTracksPlaybackMode(tracks, (selection == 1) ? true : false);
            _ui.toast(
                _trans.set_row_tracks_playback_mode_success(rowName, (selection == 1) ? _trans.single_playback_mode : _trans.repeat_playback_mode),
                icon: Icons.repeat_on_rounded);
          });
        }),
        _ui.rowMenuButton(RowMenuItem.playbackSpeed, Icons.speed_rounded, _trans.set_row_tracks_playback_speed, () {
          var items = <PopupMenuItem<dynamic>>[];
          for (var data in Config.trackPlaybackSpeedValueIcons) {
            items.add(_ui.rowPopupMenuItem(
              data.value,
              data.icon,
              _trans.set_row_tracks_playback_speed_title(Config.trackPlaybackSpeedSliderValues.valueFormatter(data.value)),
            ));
          }
          return items.toList();
        }, (selection) {
          Navigator.pop(context);
          setState(() {
            _trackWrapper.setTracksPlaybackSpeed(tracks, selection);
            _ui.toast(_trans.set_row_tracks_playback_speed_success(rowName, Config.trackPlaybackSpeedSliderValues.valueFormatter(selection)),
                icon: Icons.speed_rounded);
          });
        }),
        _ui.rowMenuButton(RowMenuItem.playbackVolume, Icons.volume_up_rounded, _trans.set_row_tracks_playback_volume, () {
          var items = <PopupMenuItem<dynamic>>[];
          for (var data in Config.trackPlaybackVolumeValueIcons) {
            items.add(_ui.rowPopupMenuItem(
              data.value,
              data.icon,
              _trans.set_row_tracks_playback_volume_title(Config.trackPlaybackVolumeSliderValues.valueFormatter(data.value)),
            ));
          }
          return items.toList();
        }, (selection) {
          Navigator.pop(context);
          setState(() {
            _trackWrapper.setTracksPlaybackVolume(tracks, selection);
            _ui.toast(_trans.set_row_tracks_playback_volume_success(rowName, Config.trackPlaybackVolumeSliderValues.valueFormatter(selection)),
                icon: Icons.speed_rounded);
          });
        }),
        const PopupMenuDivider(),
        _ui.rowPopupMenuItem(RowMenuItem.delete, Icons.delete_forever_outlined, _trans.delete_row_tracks_recordings),
      ];

  void _rowMenuItemSelected(RowMenuItem selection, String rowName, List<String> tracks) {
    if (selection == RowMenuItem.delete) {
      _ui.alertDialog(Icons.delete_forever_outlined, _trans.delete_row_tracks_recordings_title,
          contentText: _trans.delete_row_tracks_recordings_info(rowName),
          actions: <Widget>[
            _ui.simpleButton(_trans.button_no, () {
              Navigator.pop(context, 'No');
            }),
            _ui.errorButton(_trans.button_yes, () {
              _trackWrapper.removeTracksRecordings(tracks);
              Navigator.pop(context, 'Yes');
              _ui.toast(_trans.delete_row_tracks_recordings_success(rowName), icon: Icons.delete_forever_outlined);
            }),
          ]);
    }
  }

  /// *************************************************************************
  /// TRACK PRESSED
  void _trackPressed(Track track) {
    switch (track.state()) {
      case TrackState.empty:
        setState(() {
          _trackWrapper.startRecording(track);
        });
        _recordingDialog(track);
        break;
      case TrackState.stopped:
        setState(() {
          _trackWrapper.startTrackPlaying(track);
        });
        break;
      case TrackState.playing:
        setState(() {
          _trackWrapper.stopTrackPlaying(track);
        });
        break;
      case TrackState.paused:
        setState(() {
          _trackWrapper.resumeTrackPlaying(track);
        });
        break;
      default:
        break;
    }
  }

  List<Widget> _trackButton(Track track) {
    Color foregroundColor = track.stateForegroundColor(context);
    var items = <Widget>[];
    items.add(SizedBox(
        height: _ui.trackItemWidth - _ui.trackPadding,
        child: Stack(fit: StackFit.expand, children: [
          Align(alignment: Alignment.topLeft, child: Icon(track.stateIcon(context), size: _ui.trackButtonIconSize, color: foregroundColor)),
          Align(alignment: Alignment.topRight, child: _trackKeyboardKeyIcon(track, foregroundColor: foregroundColor)),
          Align(
              alignment: Alignment.bottomCenter,
              child: Text(Config.trackPlaybackSpeedSliderValues.valueFormatter(track.playbackSpeed()),
                  style: TextStyle(fontSize: _ui.trackButtonIconSize / 1.7, color: foregroundColor))),
          Align(alignment: Alignment.bottomLeft, child: Icon(track.playbackModeIcon(), size: _ui.trackButtonIconSize, color: foregroundColor)),
          Align(alignment: Alignment.bottomRight, child: Icon(track.volumeIcon(), size: _ui.trackButtonIconSize, color: foregroundColor)),
          Align(
              alignment: Alignment.center,
              child: Text(_trans.cell(track.name()), style: TextStyle(fontSize: _ui.trackButtonFontSize, fontWeight: FontWeight.bold))),
        ])));
    if (track.state() == TrackState.playing) {
      items.add(LinearProgressIndicator(color: foregroundColor, backgroundColor: track.stateProgressColor(context)));
    } else {
      items.add(LinearProgressIndicator(value: 1, color: foregroundColor, backgroundColor: track.stateProgressColor(context)));
    }
    items.add(_ui.trackInfoLine(Icons.timelapse_rounded, '00:00', foregroundColor));
    return items.toList();
  }

  Container _trackKeyboardKeyIcon(Track track, {required Color foregroundColor}) => Container(
      width: _ui.trackButtonRoundSize,
      height: _ui.trackButtonRoundSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: foregroundColor, borderRadius: BorderRadius.all(Radius.circular(_ui.trackButtonRoundRadius)), shape: BoxShape.rectangle),
      child:
          Text(track.keyboardKey(), style: TextStyle(fontSize: _ui.trackButtonRoundSize, height: 1.0, color: track.stateBackgroundColor(context))));

  /// *************************************************************************
  /// INFOS
  List<Widget> _buildFooter() {
    var items = <Widget>[];
    if (widget.settingsGet(GlobalConfigKey.recordingProbingModeHigh)) {
      items.add(_ui.footerInfoLine(Icons.hotel_class, _trans.recording_probing_mode_high_info));
    } else {
      items.add(_ui.footerInfoLine(Icons.star, _trans.recording_probing_mode_low_info));
    }
    if (widget.settingsGet(GlobalConfigKey.recordingAudioModeStereo)) {
      items.add(_ui.footerInfoLine(Symbols.mic_double_rounded, _trans.recording_audio_mode_stereo_info));
    } else {
      items.add(_ui.footerInfoLine(Icons.mic_rounded, _trans.recording_audio_mode_mono_info));
    }
    if (widget.settingsGet(GlobalConfigKey.wakelockEnabled)) {
      items.add(_ui.footerInfoLine(Icons.lightbulb_rounded, _trans.keep_screen_on_enabled));
    } else {
      items.add(_ui.footerInfoLine(Symbols.light_off_rounded, _trans.keep_screen_on_disabled));
    }
    return items.toList();
  }

  /// *************************************************************************
  /// TRACK DETAILS
  void _trackDetails(Track track) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(_ui.trackDetailsPadding),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Icon(track.stateIcon(context)),
                Text(_trans.track_title(track.name()), style: TextStyle(fontSize: _ui.trackDetailsTitleFontSize, fontWeight: FontWeight.bold)),
                _trackKeyboardKeyIcon(track, foregroundColor: track.stateForegroundColor(context)),
              ]),
              const Divider(),
              SizedBox(height: _ui.trackDetailsPadding),
              _trackDetailsLinearProgressIndicator(track, setModalState),
              SizedBox(height: _ui.trackDetailsPadding),
              _ui.trackDetailsLine(_trackDetailsPlaybackSpeedControl(track, setModalState)),
              _ui.trackDetailsLine(_trackDetailsPlaybackVolumeControl(track, setModalState)),
              SizedBox(height: _ui.trackDetailsPadding),
              _ui.trackDetailsLine(_trackDetailsPlayerIcons(track, setModalState)),
            ]),
          ),
        ),
      ),
    );
  }

  /// *************************************************************************
  /// TRACK DETAILS PLAYER ICONS
  Widget _trackDetailsLinearProgressIndicator(Track track, StateSetter setModalState) {
    if (track.state() == TrackState.empty) {
      return _ui.trackDetailsLine(_trackDetailsCurrentStateIndicator(track, setModalState));
    } else if (track.state() == TrackState.playing) {
      return LinearProgressIndicator(color: track.stateForegroundColor(context), backgroundColor: track.stateProgressColor(context));
    } else {
      return LinearProgressIndicator(value: 0.2, color: track.stateForegroundColor(context), backgroundColor: track.stateProgressColor(context));
    }
  }

  List<Widget> _trackDetailsCurrentStateIndicator(Track track, StateSetter setModalState) {
    var items = <Widget>[];

    if (track.state() == TrackState.empty) {
      items.add(_ui.mediaPlayerButton(Icons.radio_button_checked_rounded, _trans.start_recording_track(track.name()), () {
        Navigator.pop(context);
        setState(() {
          _trackWrapper.startRecording(track);
        });
        _recordingDialog(track);
      }));
      items.add(_ui.mediaPlayerButton(Icons.file_open_rounded, _trans.import_file_to_track(track.name()), () {}));
    }
    return items.toList();
  }

  List<Widget> _trackDetailsPlayerIcons(Track track, StateSetter setModalState) {
    var items = <Widget>[];

    items.add(_ui.mediaPlayerButton(
        Icons.share_outlined,
        _trans.share_track_recording(track.name()),
        (track.state() != TrackState.empty && track.state() != TrackState.recording)
            ? () {
                // TODO
              }
            : null));

    items.add(_ui.mediaPlayerButton(track.playbackModeIcon(), _trans.toggle_playback_mode(track.name()), () {
      setModalState(() {
        setState(() {
          track.togglePlaybackMode();
          _trackWrapper.save(track);
        });
      });
    }));

    items.add(_ui.mediaPlayerButton(
        (track.state() == TrackState.paused)
            ? Symbols.play_pause_rounded
            : ((track.state() == TrackState.playing) ? Icons.pause_rounded : Icons.play_arrow_rounded),
        (track.state() == TrackState.paused)
            ? _trans.resume_playing_track(track.name())
            : ((track.state() == TrackState.playing) ? _trans.pause_playing_track(track.name()) : _trans.start_playing_track(track.name())),
        (track.state() == TrackState.paused)
            ? () {
                setModalState(() {
                  setState(() {
                    _trackWrapper.resumeTrackPlaying(track);
                  });
                });
              }
            : ((track.state() == TrackState.playing)
                ? () {
                    setModalState(() {
                      setState(() {
                        _trackWrapper.pauseTrackPlaying(track);
                      });
                    });
                  }
                : ((track.state() == TrackState.stopped)
                    ? () {
                        setModalState(() {
                          setState(() {
                            _trackWrapper.startTrackPlaying(track);
                          });
                        });
                      }
                    : null)),
        iconSize: _ui.mediaPlayerIconSize2x));
    items.add(_ui.mediaPlayerButton(
        Icons.stop_rounded,
        _trans.stop_playing_track(track.name()),
        (track.state() == TrackState.playing || track.state() == TrackState.paused)
            ? () {
                setModalState(() {
                  setState(() {
                    _trackWrapper.stopTrackPlaying(track);
                  });
                });
              }
            : null));
    items.add(PopupMenuButton<TrackMenuItem>(
      style: _ui.circledButtonStyle(),
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => _trackMenuItems(track),
      onSelected: (TrackMenuItem selection) => _trackMenuItemSelected(track, selection, setModalState),
    ));

    return items.toList();
  }

  List<Widget> _trackDetailsPlaybackSpeedControl(Track track, StateSetter setModalState) {
    var items = <Widget>[];
    items.add(_ui.mediaPlayerButton(Icons.speed_outlined, '', () {
      setModalState(() {
        setState(() {
          track.setPlaybackSpeed(1);
          _trackWrapper.save(track);
        });
      });
    }));
    items.add(Slider(
      value: track.playbackSpeed(),
      min: Config.trackPlaybackSpeedSliderValues.minValue,
      max: Config.trackPlaybackSpeedSliderValues.maxValue,
      divisions: Config.trackPlaybackSpeedSliderValues.divisions,
      label: Config.trackPlaybackSpeedSliderValues.valueFormatter(track.playbackSpeed()),
      onChanged: (double value) {
        setModalState(() {
          setState(() {
            track.setPlaybackSpeed(value);
            _trackWrapper.save(track);
          });
        });
      },
    ));
    items.add(_ui.trailingLabel(Config.trackPlaybackSpeedSliderValues.valueFormatter(track.playbackSpeed())));
    return items.toList();
  }

  List<Widget> _trackDetailsPlaybackVolumeControl(Track track, StateSetter setModalState) {
    var items = <Widget>[];
    items.add(_ui.mediaPlayerButton(track.volumeIcon(), '', () {
      setModalState(() {
        setState(() {
          track.setPlaybackVolume((track.playbackVolume() == 0) ? 100 : 0);
          _trackWrapper.save(track);
        });
      });
    }));
    items.add(Slider(
      value: track.playbackVolume(),
      min: Config.trackPlaybackVolumeSliderValues.minValue,
      max: Config.trackPlaybackVolumeSliderValues.maxValue,
      divisions: Config.trackPlaybackVolumeSliderValues.divisions,
      label: track.playbackVolume().toStringAsFixed(0),
      onChanged: (double value) {
        setModalState(() {
          setState(() {
            track.setPlaybackVolume(value);
            _trackWrapper.save(track);
          });
        });
      },
    ));
    items.add(_ui.trailingLabel(track.playbackVolume().toStringAsFixed(0).padLeft(3, '0')));
    return items.toList();
  }

  /// *************************************************************************
  /// TRACK MENU ITEMS
  List<PopupMenuEntry<TrackMenuItem>> _trackMenuItems(Track track) {
    var items = <PopupMenuEntry<TrackMenuItem>>[];
    items.add(_ui.trackMenuItem(TrackMenuItem.changeName, Icons.text_fields, _trans.change_track_name));
    items.add(_ui.trackMenuItem(TrackMenuItem.changeKeyboardKey, Icons.keyboard_alt_rounded, _trans.change_keyboard_key));
    if (track.state() != TrackState.empty && track.state() != TrackState.recording) {
      items.add(_ui.trackMenuItem(TrackMenuItem.delete, Icons.delete_forever_rounded, _trans.delete_track_recording));
    }
    return items.toList();
  }

  /// *************************************************************************
  /// TRACK MENU SELECTED
  void _trackMenuItemSelected(Track track, TrackMenuItem selection, StateSetter setModalState) async {
    switch (selection) {
      case TrackMenuItem.changeName:
        String emojiString = widget.settingsGet(GlobalConfigKey.emojis);
        List<String> emojiList = [track.id()];
        emojiList.addAll(emojiString.characters.toList());
        _ui.alertDialog(Icons.text_fields, _trans.change_track_name_title(track.name()),
            contentText: _trans.change_track_name_info(track.name()),
            contentWidget: _ui.gridBuilder(
                columnsCount: 6,
                itemCount: emojiList.length,
                itemBuilder: (context, index) {
                  String emoji = emojiList[index];
                  ButtonStyle style = OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  );
                  TextStyle textStyle = TextStyle();
                  if (emoji == track.name()) {
                    style = OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    );
                    textStyle = TextStyle(color: Theme.of(context).colorScheme.inversePrimary);
                  }
                  return OutlinedButton(
                      style: style,
                      onPressed: () {
                        setModalState(() {
                          setState(() {
                            Navigator.of(context).pop(emoji);
                            track.setName(emoji);
                            _ui.toast(_trans.change_track_name_success(emoji), icon: Icons.text_fields);
                          });
                        });
                      },
                      child: Text(emoji, style: textStyle));
                }));
        break;
      case TrackMenuItem.changeKeyboardKey:
        _ui.alertDialog(Icons.keyboard_alt_rounded, _trans.change_keyboard_key_title(track.name()),
            contentText: _trans.change_keyboard_key_info(track.name()),
            contentWidget: _ui.gridBuilder(
                columnsCount: 6,
                itemCount: Config.keyboardKeys().length,
                itemBuilder: (context, index) {
                  String key = Config.keyboardKeys().elementAt(index);
                  ButtonStyle buttonStyle = OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  );
                  TextStyle textStyle = TextStyle();
                  if (key == track.keyboardKey()) {
                    buttonStyle = OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    );
                    textStyle = TextStyle(color: Theme.of(context).colorScheme.inversePrimary);
                  }
                  return OutlinedButton(
                      style: buttonStyle,
                      onPressed: () {
                        setModalState(() {
                          setState(() {
                            Navigator.of(context).pop(key);
                            track.setKeyboardKey(key);
                            _ui.toast(_trans.change_keyboard_key_success(key), icon: Icons.keyboard_alt_rounded);
                          });
                        });
                      },
                      child: Text(key, style: textStyle));
                }));
        break;
      case TrackMenuItem.delete:
        _ui.alertDialog(Icons.delete_forever_rounded, _trans.delete_track_recording_title(track.name()),
            contentText: _trans.delete_track_recording_info(track.name()),
            actions: <Widget>[
              _ui.simpleButton(_trans.button_no, () {
                Navigator.of(context).pop(_trans.button_no);
              }),
              _ui.errorButton(_trans.button_yes, () {
                setModalState(() {
                  setState(() {
                    _trackWrapper.removeRecordingAndSave(track);
                    Navigator.of(context).pop(_trans.button_yes);
                    _ui.toast(_trans.delete_track_recording_success(track.name()), icon: Icons.delete_forever_rounded);
                  });
                });
              }),
            ]);
        break;
    }
  }

  void _recordingDialog(Track track) {
    _ui.alertDialog(Icons.graphic_eq, _trans.track_title(track.name()), contentWidget: LinearProgressIndicator(), actions: [
      TextButton(
          onPressed: () {
            Navigator.of(context).pop(_trans.stop_recording_track(track.name()));
            setState(() {
              _trackWrapper.stopRecordingAndSave(track);
            });
          },
          child: Text(_trans.stop_recording_track(track.name())))
    ], thenCallback: (result) {
      setState(() {
        _trackWrapper.stopRecordingAndSave(track);
      });
    });
  }
}
