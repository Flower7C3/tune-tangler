import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../src/io.dart';
import '../src/track.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({
    super.key,
    required this.settingsGet,
    required this.settingsSet,
  });

  final Function(dynamic key) settingsGet;
  final void Function(dynamic key, dynamic value) settingsSet;

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  late AppLocalizations _trans;
  late IO _io;

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        Track track = args['track'];

        _trans = AppLocalizations.of(context)!;
        _io = IO(context);

        Color foregroundColor = track.getStateFgColor();

        return Scaffold(
            appBar: AppBar(
              title: Text(_trans.track_title(track.getName())),
              centerTitle: true,
              actions: [IconButton(icon: Icon(Icons.graphic_eq_rounded), onPressed: null)],
            ),
            body: Container(
                padding: EdgeInsets.all(16),
                child: ListView(children: [
                  LinearProgressIndicator(value: Random().nextDouble(), color: foregroundColor, backgroundColor: track.getStateProgressColor()),
                  SizedBox(height: 32),
                  SizedBox(
                      width: 100,
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: _buildPlayerIcons(track))),
                  SizedBox(height: 32),
                  SizedBox(
                      width: 100,
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: _buildVolumeIcons(track))),
                  SizedBox(height: 32),
                  SizedBox(
                      width: 100,
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: _buildFooterIcons(track))),
                ])));
      });

  List<Widget> _buildPlayerIcons(Track track) {
    var items = <Widget>[];

    items.add(_io.mediaPlayerButton(Icons.radio_button_checked_rounded, '', () {}));
    items.add(_io.mediaPlayerButton(Icons.file_open_rounded, '', () {}));
    items.add(_io.mediaPlayerButton(Icons.play_arrow_rounded, '', () {}));
    items.add(_io.mediaPlayerButton(Icons.pause_rounded, '', () {}));
    items.add(_io.mediaPlayerButton(Icons.stop_rounded, '', () {}));
    items.add(_io.mediaPlayerButton(track.playbackModeIcon(), '', () {
      setState(() {
        track.togglePlaybackMode();
      });
    }));

    return items.toList();
  }

  List<Widget> _buildVolumeIcons(Track track) {
    var items = <Widget>[];
    items.add(_io.mediaPlayerButton(track.volumeIcon(), '', () {
      setState(() {
        track.setPlaybackVolume((track.playbackVolume() == 0) ? 100 : 0);
      });
    }));
    items.add(Slider(
      value: track.playbackVolume(),
      min: 0,
      max: 100,
      divisions: 20,
      label: track.playbackVolume().round().toString(),
      onChanged: (double value) {
        setState(() {
          track.setPlaybackVolume(value);
        });
      },
    ));
    items.add(_io.trailingLabel(track.playbackVolume().round().toString().padLeft(3, '0')));
    return items.toList();
  }

  List<Widget> _buildFooterIcons(Track track) {
    var items = <Widget>[];
    items.add(_io.mediaPlayerTextButton(Icons.keyboard, track.getKeyboardKey(), () {}));
    items.add(_io.mediaPlayerButton(Icons.text_fields, '', () {}));
    items.add(_io.mediaPlayerButton(Icons.share_outlined, '', () {}));
    items.add(_io.mediaPlayerButton(Icons.delete_forever_rounded, '', () {}));
    return items.toList();
  }
}
