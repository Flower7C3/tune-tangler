import 'dart:io';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tune_tangler/helper/blocking_progress.dart';
import 'package:tune_tangler/helper/ui_helper.dart';

import '../config/app_global_config.dart';
import '../config/app_icon.dart';
import '../entity/track.dart';
import '../src/generated/app_localizations.dart';

const MethodChannel _kAudioExportChannel = MethodChannel('pro.kwiatek.tune_tangler/audio_export');
const MethodChannel _kAudioExportProgressChannel = MethodChannel('pro.kwiatek.tune_tangler/audio_export_progress');

bool _nativeProcessedShareAvailable() =>
    !foundation.kIsWeb && foundation.defaultTargetPlatform == foundation.TargetPlatform.android;

class TrackShare {
  final BuildContext _context;
  final AppLocalizations _trans;
  final UIHelper _uiHelper;

  TrackShare(this._context, this._trans, this._uiHelper);

  Future<void> shareDialog(Track track) async {
    if (track.path == null) {
      _uiHelper.toast(_trans.trackRecordingShareNoFile(track.name.value),
          icon: AppIcon.trackRecordingShare, type: ToastType.error, duration: 4);
      return;
    }
    if (!_trackHasProcessedExportModifications(track)) {
      await _shareRaw(track);
      return;
    }
    _uiHelper.listDialog(
      AppIcon.trackRecordingShare,
      _trans.trackRecordingShare(track.name.value),
      actions: [
        SimpleDialogOption(
          padding: EdgeInsets.zero,
          child: _uiHelper.statusIconTile(
            track.audioSourceIcon ?? AppIcon.trackAudioSourceRecorded,
            _trans.trackRecordingShareRaw(track.duration.value),
          ),
          onPressed: () async {
            Navigator.pop(_context);
            await _shareRaw(track);
          },
        ),
        SimpleDialogOption(
          padding: EdgeInsets.zero,
          child: _uiHelper.statusIconTile(
            AppIcon.trackRecordingShareModified,
            _trans.trackRecordingShareProcessed(_processedShareLabelDuration(track)),
          ),
          onPressed: () {
            Navigator.pop(_context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_context.mounted) return;
              if (_nativeProcessedShareAvailable()) {
                _shareProcessed(track);
              } else {
                _uiHelper.toast(
                  _trans.trackRecordingShareProcessedAndroidOnly,
                  icon: AppIcon.trackRecordingShare,
                  type: ToastType.success,
                  duration: 5,
                );
              }
            });
          },
        ),
      ],
    );
  }

  /// Length label for the processed share: source segment time scaled by [Track.playbackSpeed]
  /// (matches Android Sonic time-stretch, where output is shorter when speed > 1).
  Duration _processedShareLabelDuration(Track track) {
    final span = track.durationAfterCut.value;
    final ms = span.inMilliseconds;
    if (ms <= 0) return span;
    final speed = track.playbackSpeed.value;
    if (speed <= 0 || (speed - 1.0).abs() < 1e-6) return span;
    final outMs = (ms / speed).round();
    return Duration(milliseconds: outMs < 1 ? 1 : outMs);
  }

  /// True when [_shareProcessed] would differ from the raw file (trim or non-default playback params).
  bool _trackHasProcessedExportModifications(Track track) {
    final durationMs = track.duration.value.inMilliseconds;
    final endMs = track.playbackEndAtPosition.value.inMilliseconds;
    if (track.playbackStartAtPosition.value.inMilliseconds > 0) return true;
    if (durationMs > 0 && endMs != durationMs) return true;
    const eps = 1e-6;
    if ((track.playbackVolume.value - AppGlobalConfig.trackPlaybackVolume.defaultValue).abs() > eps) {
      return true;
    }
    if ((track.playbackBalance.value - AppGlobalConfig.trackPlaybackBalance.defaultValue).abs() > eps) {
      return true;
    }
    if ((track.playbackSpeed.value - AppGlobalConfig.trackPlaybackSpeed.defaultValue).abs() > eps) {
      return true;
    }
    return false;
  }

  Future<void> _shareRaw(Track track) async {
    try {
      if (track.path == null || !File(track.path!).existsSync()) {
        throw Exception(_trans.trackRecordingShareNoFile(track.name.value));
      }
      SharePlus.instance.share(ShareParams(files: [XFile(track.path!)]));
    } catch (e) {
      debugPrint('Error exporting raw: $e');
      _uiHelper.toast(_trans.trackRecordingShareFailed(track.name.value), icon: AppIcon.exception, type: ToastType.error);
    }
  }

  Future<void> _shareProcessed(Track track) async {
    if (!_nativeProcessedShareAvailable()) {
      _uiHelper.toast(
        _trans.trackRecordingShareProcessedAndroidOnly,
        icon: AppIcon.trackRecordingShare,
        type: ToastType.success,
        duration: 5,
      );
      return;
    }
    String? outPath;
    BuildContext? progressDialogContext;
    final ValueNotifier<double> exportProgress = ValueNotifier<double>(0.0);

    void closeProgressDialog() {
      final c = progressDialogContext;
      progressDialogContext = null;
      BlockingProgress.close(c);
    }

    try {
      if (track.path == null) {
        throw Exception(_trans.trackRecordingShareNoFile(track.name.value));
      }

      if (!_context.mounted) return;

      // Show immediately — existsSync() can block the UI thread on slow storage; run it after the first paint.
      BlockingProgress.show(
        context: _context,
        onContext: (BuildContext dialogCtx) => progressDialogContext = dialogCtx,
        builder: (BuildContext dialogCtx) => ValueListenableBuilder<double>(
          valueListenable: exportProgress,
          builder: (BuildContext context, double value, _) =>
              BlockingProgress.determinate(
            value: value,
            label: _trans.trackRecordingSharePreparingModified,
            actions: [
              TextButton(
                onPressed: () {
                  _kAudioExportChannel.invokeMethod<void>('cancelExportProcessed');
                },
                child: Text(_trans.buttonCancel),
              ),
            ],
          ),
        ),
      );

      exportProgress.value = 0.0;
      await BlockingProgress.yieldForPaint();

      if (!File(track.path!).existsSync()) {
        throw Exception(_trans.trackRecordingShareNoFile(track.name.value));
      }

      final Directory appDir;
      try {
        appDir = await getApplicationDocumentsDirectory();
      } catch (e, st) {
        foundation.debugPrint('getApplicationDocumentsDirectory failed: $e\n$st');
        if (_context.mounted) {
          _uiHelper.toast(
            _trans.trackRecordingShareFailed(track.name.value),
            icon: AppIcon.exception,
            type: ToastType.error,
          );
        }
        return;
      }
      final ts = DateTime.now().millisecondsSinceEpoch;
      outPath = "${appDir.path}/${track.id.toString()}-$ts-processed.m4a";

      final startMs = track.playbackStartAtPosition.value.inMilliseconds;
      final endMs = track.playbackEndAtPosition.value.inMilliseconds;
      final inPath = track.path!;
      final vol = track.playbackVolume.value;
      final bal = track.playbackBalance.value;
      final speed = track.playbackSpeed.value;

      _kAudioExportProgressChannel.setMethodCallHandler((MethodCall call) async {
        if (call.method == 'setProgress') {
          final v = (call.arguments as num?)?.toDouble() ?? 0.0;
          exportProgress.value = v.clamp(0.0, 1.0);
        }
      });

      await _kAudioExportChannel.invokeMethod<void>('exportProcessed', <String, Object?>{
        'inputPath': inPath,
        'outputPath': outPath,
        'startMs': startMs,
        'endMs': endMs,
        'volume': vol,
        'balance': bal,
        'speed': speed,
      });

      closeProgressDialog();

      if (!_context.mounted) return;
      SharePlus.instance.share(ShareParams(files: [XFile(outPath)]));
    } on PlatformException catch (e, st) {
      foundation.debugPrint('Error exporting processed: $e\n$st');
      if (e.code == 'export_cancelled') {
        try {
          final p = outPath;
          if (p != null) {
            final f = File(p);
            if (f.existsSync()) f.deleteSync();
          }
        } catch (_) {}
        if (_context.mounted) {
          _uiHelper.toast(
            _trans.trackRecordingShareExportCancelled,
            icon: AppIcon.trackRecordingShare,
            type: ToastType.success,
            duration: 2,
          );
        }
        return;
      }
      final msg = e.message;
      if (_context.mounted) {
        if (msg != null && msg.isNotEmpty) {
          _uiHelper.toast(
            '${_trans.trackRecordingShareFailed(track.name.value)}: $msg',
            icon: AppIcon.exception,
            type: ToastType.error,
          );
        } else {
          _uiHelper.toast(_trans.trackRecordingShareFailed(track.name.value), icon: AppIcon.exception, type: ToastType.error);
        }
      }
    } catch (e, st) {
      foundation.debugPrint('Error exporting processed: $e\n$st');
      _uiHelper.toast(_trans.trackRecordingShareFailed(track.name.value), icon: AppIcon.exception, type: ToastType.error);
    } finally {
      closeProgressDialog();
      _kAudioExportProgressChannel.setMethodCallHandler(null);
      exportProgress.dispose();
      final p = outPath;
      if (p != null) {
        Future<void>.delayed(const Duration(seconds: 5), () {
          try {
            final f = File(p);
            if (f.existsSync()) f.deleteSync();
          } catch (_) {}
        });
      }
    }
  }

}
