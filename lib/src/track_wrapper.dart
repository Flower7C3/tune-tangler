import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'io.dart';
import 'track.dart';

class TrackWrapper {
  final BuildContext context;
  final AppLocalizations _trans;
  final IO _io;

  final double _trackItemMargin = 4;
  final double _trackItemWidth = 70;
  final double _trackPadding = 4;
  final double _trackBorderRadius = 10;
  final double _trackButtonFontSize = 26.0;
  final double _trackButtonRoundRadius = 3;
  final double _trackButtonRoundSize = 18.0;
  final double _trackButtonIconSize = 20.0;
  final double _trackInfoFontSize = 14.0;
  final double _trackInfoIconSize = 12.0;

  const TrackWrapper(this.context, this._trans, this._io);

  Container build(track) {
    return Container(
        margin: EdgeInsets.all(_trackItemMargin),
        width: _trackItemWidth,
        child: ElevatedButton(
            onPressed: () {
              _trackAction(track);
            },
            onLongPress: () {
              Navigator.pushNamed(context, '/track', arguments: {'track': track});
            },
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(_trackPadding),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_trackBorderRadius)),
                backgroundColor: track.getStateBgColor(),
                foregroundColor: track.getStateFgColor()),
            child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: _buildTrackButton(track))));
  }

  void _trackAction(Track track) {
    switch (track.getState()) {
      case TrackState.empty:
        _io.alertDialog(Icons.graphic_eq, _trans.track_title(track.getName()), contentWidget: LinearProgressIndicator(), actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(_trans.stop_recording_track);
                stopRecording(track);
              },
              child: Text(_trans.stop_recording_track))
        ], thenCallback: (result) {
          stopRecording(track);
        });
        break;
      default:
        // var state = track.getState();
        // _io.toast('$state', color: Theme.of(context).colorScheme.secondary, icon: Icons.add);
        break;
    }
  }

  void stopRecording(Track track) {
    // TODO
    _io.toast(_trans.stop_recording_track_done(track.getName()), icon: Icons.check_circle_rounded);
  }

  List<Widget> _buildTrackButton(Track track) {
    Color foregroundColor = track.getStateFgColor();
    var items = <Widget>[];
    items.add(SizedBox(
        height: _trackItemWidth - _trackPadding,
        child: Stack(fit: StackFit.expand, children: [
          Align(alignment: Alignment.topLeft, child: Icon(track.getStateIcon(), size: _trackButtonIconSize, color: foregroundColor)),
          Align(
            alignment: Alignment.topRight,
            child: Container(
                width: _trackButtonRoundSize,
                height: _trackButtonRoundSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: foregroundColor, borderRadius: BorderRadius.all(Radius.circular(_trackButtonRoundRadius)), shape: BoxShape.rectangle),
                child:
                    Text(track.getKeyboardKey(), style: TextStyle(fontSize: _trackButtonRoundSize, height: 1.0, color: track.getStateBgColor()))),
          ),
          Align(alignment: Alignment.bottomCenter, child: Icon(track.getSpeedIcon(), size: _trackButtonIconSize, color: foregroundColor)),
          Align(alignment: Alignment.bottomLeft, child: Icon(track.playbackModeIcon(), size: _trackButtonIconSize, color: foregroundColor)),
          Align(alignment: Alignment.bottomRight, child: Icon(track.volumeIcon(), size: _trackButtonIconSize, color: foregroundColor)),
          Align(
              alignment: Alignment.center,
              child: Text(_trans.cell(track.getName()), style: TextStyle(fontSize: _trackButtonFontSize, fontWeight: FontWeight.bold))),
        ])));
    items.add(LinearProgressIndicator(value: Random().nextDouble(), color: foregroundColor, backgroundColor: track.getStateProgressColor()));
    items.add(_infoRow(foregroundColor, Icons.timelapse_rounded, '00:00:00'));
    return items.toList();
  }

  Row _infoRow(Color foregroundColor, IconData icon, String text) {
    return Row(children: [Icon(icon, size: _trackInfoIconSize, color: foregroundColor), Text(text, style: TextStyle(fontSize: _trackInfoFontSize))]);
  }
}
