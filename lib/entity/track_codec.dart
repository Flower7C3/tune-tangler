part of 'track.dart';

class TrackCodec {
  static Future<void> copyOnto(Track dest, Track track) async {
    if (track.id.toString() == track.name.value) {
      dest.setName(dest.id.toString());
    } else {
      dest.setName(track.name.value);
    }
    dest.setPlaybackReleaseMode(track.playbackReleaseMode.value);
    dest.setPlaybackVolume(track.playbackVolume.value);
    dest.setPlaybackBalance(track.playbackBalance.value);
    dest.setPlaybackSpeed(track.playbackSpeed.value);
    dest.setDuration(track.duration.value);

    try {
      if (track.path == null) {
        throw Exception();
      }
      File oldFile = File(track.path!);
      if (!oldFile.existsSync()) {
        throw Exception();
      }
      Directory appDir = await getApplicationDocumentsDirectory();
      String newFileName = path_provider
          .basename(track.path!)
          .replaceFirst(RegExp(r'^[^.]+'), dest.id.toString());
      String newFilePath = "${appDir.path}/$newFileName";
      File newFile = oldFile.renameSync(newFilePath);
      await dest.setPath(
        newFile.path,
        preserveDuration: true,
        preservePlaybackPositions: true,
      );
    } catch (e) {
      dest._path = null;
      dest.setRecorderState(RecorderState.empty);
      dest.updateState();
    }

    dest.setAudioSource(track.audioSource);
    dest.setAudioEncoder(track.audioEncoder);
    dest.setSampleRate(track.sampleRate);
    dest.setBitRate(track.bitRate);

    dest.setPlaybackStartAtPosition(track.playbackStartAtPosition.value);
    dest.setPlaybackEndAtPosition(track.playbackEndAtPosition.value);
    dest.setPosition(track.position.value);
    dest._updateProgress();
  }

  static Track fromMap(Map data) {
    TrackId trackId = data[TrackAdapterKey.trackId];
    Track track = Track(trackId);
    track.setName(data[TrackAdapterKey.name]);
    track.setPlaybackReleaseMode(
      ReleaseMode.values[data[TrackAdapterKey.playbackReleaseMode]],
    );
    track.setPlaybackVolume(
      data[TrackAdapterKey.playbackVolume] ??
          AppGlobalConfig.trackPlaybackVolume.defaultValue,
    );
    track.setPlaybackBalance(
      data[TrackAdapterKey.playbackBalance] ??
          AppGlobalConfig.trackPlaybackBalance.defaultValue,
    );
    track.setPlaybackSpeed(
      data[TrackAdapterKey.playbackSpeed] ??
          AppGlobalConfig.trackPlaybackSpeed.defaultValue,
    );
    track.setKeyboardKey(data[TrackAdapterKey.keyboardKey] ?? '');
    track.setAudioSource(
      data[TrackAdapterKey.audioSource] != null
          ? TrackAudioSource.values[data[TrackAdapterKey.audioSource]]
          : null,
    );
    track.setAudioEncoder(
      data[TrackAdapterKey.audioEncoder] != null
          ? AudioEncoder.values[data[TrackAdapterKey.audioEncoder]]
          : null,
    );
    track.setSampleRate(data[TrackAdapterKey.sampleRate]);
    track.setBitRate(data[TrackAdapterKey.bitRate]);
    track.setPath(
      data[TrackAdapterKey.path],
      playbackStartAtPosition: data[TrackAdapterKey.playbackStartAtPosition],
      playbackEndAtPosition: data[TrackAdapterKey.playbackEndAtPosition],
      clearMetadata: false,
    );
    track.updateState();
    return track;
  }

  static Map<TrackAdapterKey, dynamic> toMap(Track track) => {
    TrackAdapterKey.trackId: track.id,
    TrackAdapterKey.name: track.name.value,
    TrackAdapterKey.path: track.path,
    TrackAdapterKey.playbackReleaseMode: track.playbackReleaseMode.value.index,
    TrackAdapterKey.playbackVolume: track.playbackVolume.value,
    TrackAdapterKey.playbackBalance: track.playbackBalance.value,
    TrackAdapterKey.playbackSpeed: track.playbackSpeed.value,
    TrackAdapterKey.playbackStartAtPosition:
        track.playbackStartAtPosition.value,
    TrackAdapterKey.playbackEndAtPosition: track.playbackEndAtPosition.value,
    TrackAdapterKey.keyboardKey: track.keyboardKey.value,
    TrackAdapterKey.audioSource: track.audioSource?.index,
    TrackAdapterKey.audioEncoder: track.audioEncoder?.index,
    TrackAdapterKey.sampleRate: track.sampleRate,
    TrackAdapterKey.bitRate: track.bitRate,
  };

  static Future<void> apply(
    Track dest,
    Map<TrackAdapterKey, dynamic> properties,
    String tempSourcePath, {
    bool preserveKeyboardKey = true,
  }) async {
    final originalId = properties[TrackAdapterKey.trackId] as TrackId;

    dest.setName(
      properties[TrackAdapterKey.name] == originalId.toString()
          ? dest.id.toString()
          : properties[TrackAdapterKey.name],
    );

    dest.setAudioSource(
      properties[TrackAdapterKey.audioSource] != null
          ? TrackAudioSource.values[properties[TrackAdapterKey.audioSource]]
          : null,
    );

    dest.setAudioEncoder(
      properties[TrackAdapterKey.audioEncoder] != null
          ? AudioEncoder.values[properties[TrackAdapterKey.audioEncoder]]
          : null,
    );

    dest.setSampleRate(properties[TrackAdapterKey.sampleRate]);
    dest.setBitRate(properties[TrackAdapterKey.bitRate]);
    if (!preserveKeyboardKey) {
      dest.setKeyboardKey(properties[TrackAdapterKey.keyboardKey] ?? '');
    }

    String? newPath;
    if (tempSourcePath.isNotEmpty && File(tempSourcePath).existsSync()) {
      newPath = await _moveAudioFile(
        dest.id,
        tempSourcePath,
      );
    } else if (properties[TrackAdapterKey.path] != null &&
        File(properties[TrackAdapterKey.path]!).existsSync()) {
      newPath = await _moveAudioFile(
        dest.id,
        properties[TrackAdapterKey.path]!,
      );
    }

    dest._path = newPath;

    dest.setDuration(
      properties[TrackAdapterKey.playbackEndAtPosition] ?? Duration(),
    );
    dest.setPosition(
      properties[TrackAdapterKey.playbackStartAtPosition] ?? Duration(),
    );

    dest.playbackStartAtPosition.value =
        properties[TrackAdapterKey.playbackStartAtPosition] ?? Duration();
    dest.playbackEndAtPosition.value =
        properties[TrackAdapterKey.playbackEndAtPosition] ?? Duration();

    dest._updatePositionCut();
    dest._updateDurationCut();

    if (newPath != null && File(newPath).existsSync()) {
      try {
        await dest.player.stop();
        await dest.player.setSourceDeviceFile(newPath);

        final volume =
            properties[TrackAdapterKey.playbackVolume] ??
            AppGlobalConfig.trackPlaybackVolume.defaultValue;
        final balance =
            properties[TrackAdapterKey.playbackBalance] ??
            AppGlobalConfig.trackPlaybackBalance.defaultValue;
        final releaseMode =
            ReleaseMode.values[properties[TrackAdapterKey
                    .playbackReleaseMode] ??
                AppGlobalConfig.trackPlaybackReleaseMode.defaultValue.index];
        final speed =
            properties[TrackAdapterKey.playbackSpeed] ??
            AppGlobalConfig.trackPlaybackSpeed.defaultValue;

        dest.player.setVolume(volume);
        dest.player.setBalance(balance);
        dest.player.setReleaseMode(releaseMode);
        dest.player.setPlaybackRate(speed);

        await dest.player.seek(dest.playbackStartAtPosition.value);
      } catch (e) {
        debugPrint('Error setting player source: $e');
        dest._path = null;
      }
    } else {
      await dest.player.stop();
      dest._path = null;
    }

    dest.setPlaybackVolume(
      properties[TrackAdapterKey.playbackVolume] ??
          AppGlobalConfig.trackPlaybackVolume.defaultValue,
    );
    dest.setPlaybackBalance(
      properties[TrackAdapterKey.playbackBalance] ??
          AppGlobalConfig.trackPlaybackBalance.defaultValue,
    );
    dest.setPlaybackReleaseMode(
      ReleaseMode.values[properties[TrackAdapterKey.playbackReleaseMode] ??
          AppGlobalConfig.trackPlaybackReleaseMode.defaultValue.index],
    );
    dest.setPlaybackSpeed(
      properties[TrackAdapterKey.playbackSpeed] ??
          AppGlobalConfig.trackPlaybackSpeed.defaultValue,
    );

    dest.recorderState.value = (newPath != null && File(newPath).existsSync())
        ? RecorderState.ready
        : RecorderState.empty;

    dest.updateState();
  }

  static Future<String> _moveAudioFile(TrackId id, String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final newFileName = '${id.toString()}${path_provider.extension(sourcePath)}';
    final newPath = '${appDir.path}/$newFileName';
    if (File(newPath).existsSync()) {
      await File(newPath).delete();
    }
    try {
      await File(sourcePath).rename(newPath);
    } catch (_) {
      await File(sourcePath).copy(newPath);
      await File(sourcePath).delete();
    }
    return newPath;
  }
}
