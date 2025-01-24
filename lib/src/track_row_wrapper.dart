import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'config.dart';
import 'io.dart';

enum RowMenu {
  loopForever,
  loopOne,
  playbackSpeed,
  volume,
  delete,
}

class TrackRowWrapper {
  final BuildContext context;
  final AppLocalizations _trans;
  final IO _io;
  String? _selectedRow;

  final double _iconSize = 24;
  final double _containerPadding = 3;
  final double _firstColumnWidth = 40;
  final double _rowIconSize = 20;
  final double _rowFontSize = 16;

  TrackRowWrapper(this.context, this._trans, this._io);

  static String name(int rowIndex) => Config.rowNames().elementAt(rowIndex);

  ButtonStyle _iconStyle() =>
      IconButton.styleFrom(shape: CircleBorder(), padding: EdgeInsets.zero, backgroundColor: Theme.of(context).colorScheme.primaryContainer);

  build(rowIndex) {
    var rowName = name(rowIndex);
    var buttons = <Widget>[];
    buttons.add(Container(
        margin: EdgeInsets.all(0),
        width: _iconSize + _containerPadding * 2,
        height: _iconSize + _containerPadding * 2,
        padding: EdgeInsets.all(_containerPadding),
        child: _io.mediaPlayerButton(Icons.play_arrow_rounded, _trans.start_playing_row_tracks(rowName), () {
          // TODO
        })));
    buttons.add(Container(
        margin: EdgeInsets.all(0),
        width: _iconSize + _containerPadding * 2,
        height: _iconSize + _containerPadding * 2,
        padding: EdgeInsets.all(_containerPadding),
        child: IconButton(
            onPressed: () {}, // TODO
            style: _iconStyle(),
            icon: Icon(Icons.stop_rounded, size: _iconSize, color: Theme.of(context).colorScheme.primary),
            tooltip: _trans.stop_playing_row_tracks(rowName))));
    buttons.add(Container(
        margin: EdgeInsets.all(0),
        width: _iconSize + _containerPadding * 2,
        height: _iconSize + _containerPadding * 2,
        padding: EdgeInsets.all(_containerPadding),
        child: _popupMenu(rowName)));
    return Container(
        width: _firstColumnWidth,
        padding: EdgeInsets.zero,
        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: buttons.toList()));
  }

  PopupMenuButton _popupMenu(rowName) => PopupMenuButton<RowMenu>(
      style: _iconStyle(),
      onOpened: () {
        _selectedRow = rowName;
      },
      icon: Icon(Icons.more_vert, size: _iconSize, color: Theme.of(context).colorScheme.secondary),
      onSelected: (RowMenu item) {
        switch (item) {
          case RowMenu.loopForever:
            _io.alertDialog(Icons.repeat_outlined, _trans.set_row_tracks_repeat_playback_mode_title,
                contentText: _trans.set_row_tracks_repeat_playback_mode_info(rowName),
                actions: <Widget>[
                  _io.simpleButton(_trans.button_no, () {
                    Navigator.of(context).pop(_trans.button_no);
                  }),
                  _io.errorButton(_trans.button_yes, () {
                    // TODO
                    Navigator.of(context).pop(_trans.button_yes);
                    _io.toast(_trans.set_row_tracks_repeat_playback_mode_done(rowName), icon: Icons.repeat_outlined);
                  }),
                ]);
            break;
          case RowMenu.loopOne:
            _io.alertDialog(Icons.repeat_one_outlined, _trans.set_row_tracks_single_playback_mode_title,
                contentText: _trans.set_row_tracks_single_playback_mode_info(rowName),
                actions: <Widget>[
                  _io.simpleButton(_trans.button_no, () {
                    Navigator.of(context).pop(_trans.button_no);
                  }),
                  _io.errorButton(_trans.button_yes, () {
                    // TODO
                    Navigator.of(context).pop(_trans.button_yes);
                    _io.toast(_trans.set_row_tracks_single_playback_mode_done(rowName), icon: Icons.repeat_one_outlined);
                  }),
                ]);
            break;
          case RowMenu.playbackSpeed:
            var options = <Widget>[];
            Config.playbackSpeeds.forEach((value, icon) {
              options.add(SimpleDialogOption(
                  onPressed: () {
                    // TODO
                    Navigator.of(context).pop(value);
                    _io.toast(
                        _trans.reset_row_tracks_playback_speed_done(
                          rowName,
                          value,
                        ),
                        icon: icon);
                  },
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16)])));
            });
            _io.listDialog(Icons.speed_outlined, _trans.reset_row_tracks_playback_speed_title,
                contentText: _trans.reset_row_tracks_playback_speed_info(rowName), actions: options.toList());
            break;
          case RowMenu.volume:
            var options = <Widget>[];
            Config.playbackVolumes.forEach((value, name) {
              options.add(SimpleDialogOption(
                  onPressed: () {
                    // TODO
                    Navigator.of(context).pop(value);
                    _io.toast(
                        _trans.reset_row_tracks_playback_volume_done(
                          rowName,
                          value,
                        ),
                        icon: Icons.volume_up_outlined);
                  },
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(name)])));
            });
            _io.listDialog(Icons.volume_up_outlined, _trans.reset_row_tracks_playback_volume_title,
                contentText: _trans.reset_row_tracks_playback_volume_info(rowName), actions: options.toList());
            break;
          case RowMenu.delete:
            _io.alertDialog(Icons.delete_forever_outlined, _trans.delete_row_tracks_title,
                contentText: _trans.delete_row_tracks_info(rowName),
                actions: <Widget>[
                  _io.simpleButton(_trans.button_no, () {
                    Navigator.pop(context, 'No');
                  }),
                  _io.errorButton(_trans.button_yes, () {
                    // TODO
                    Navigator.pop(context, 'Yes');
                    _io.toast(_trans.delete_row_tracks_done(rowName), icon: Icons.delete_forever_outlined);
                  }),
                ]);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<RowMenu>>[
            _rowOptionsButtonItem(RowMenu.loopForever, Icons.repeat_outlined, _trans.set_row_tracks_repeat_playback_mode(rowName)),
            _rowOptionsButtonItem(RowMenu.loopOne, Icons.repeat_one_outlined, _trans.set_row_tracks_single_playback_mode(rowName)),
            const PopupMenuDivider(),
            _rowOptionsButtonItem(RowMenu.playbackSpeed, Icons.speed_outlined, _trans.reset_row_tracks_playback_speed(rowName)),
            _rowOptionsButtonItem(RowMenu.volume, Icons.volume_up_outlined, _trans.reset_row_tracks_playback_volume(rowName)),
            const PopupMenuDivider(),
            _rowOptionsButtonItem(RowMenu.delete, Icons.delete_forever_outlined, _trans.delete_row_tracks(rowName)),
          ]);

  PopupMenuItem<RowMenu> _rowOptionsButtonItem(value, IconData icon, String title) => PopupMenuItem<RowMenu>(
      value: value, child: ListTile(leading: Icon(icon, size: _rowIconSize), title: Text(title, style: TextStyle(fontSize: _rowFontSize))));
}
