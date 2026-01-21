import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:tune_tangler/helper/ui_helper.dart';
import 'package:tune_tangler/repository/track_repository.dart';

import '../config/app_global_config.dart';
import '../config/app_icon.dart';
import '../config/menu_item_enums.dart';
import '../entity/track_row.dart';
import '../src/generated/app_localizations.dart';

class RowMenuManager {
  final BuildContext _context;
  final AppLocalizations _trans;
  final UIHelper _uiHelper;
  final TrackRepository _trackRepository;

  RowMenuManager(
    this._context,
    this._trans,
    this._uiHelper,
    this._trackRepository,
  );

  Widget buildRowButtons(int rowIndex) => RepaintBoundary(
    child: Container(
      width: Theme.of(_context).textTheme.displaySmall!.fontSize,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _uiHelper.mediaPlayerButton(
            AppIcon.trackPlayingStart,
            _trans.rowTracksPlayingStart(TrackRow.name(rowIndex)),
            boxSize: Theme.of(_context).textTheme.displaySmall!.fontSize! * 0.9,
            onPressed: () => _trackRepository.startTracksPlaying(
              _trackRepository.rowTracks(rowIndex),
            ),
          ),
          _uiHelper.mediaPlayerButton(
            AppIcon.trackPlayingStop,
            _trans.rowTracksPlayingStop(TrackRow.name(rowIndex)),
            boxSize: Theme.of(_context).textTheme.displaySmall!.fontSize! * 0.9,
            onPressed: () => _trackRepository.stopTracksPlaying(
              _trackRepository.rowTracks(rowIndex),
            ),
          ),
          _uiHelper.rowButton(_rowMenuActions(rowIndex)),
        ],
      ),
    ),
  );

  PopupMenuButton _rowMenuActions(int rowIndex) => PopupMenuButton<dynamic>(
    style: _uiHelper.circledButtonStyle(),
    icon: Icon(
      AppIcon.moreMenu,
      color: Theme.of(_context).colorScheme.secondary,
    ),
    itemBuilder: (BuildContext context) => _rowMenuItems(rowIndex),
    onSelected: (dynamic selection) =>
        _rowMenuItemSelected(selection, rowIndex),
  );

  List<PopupMenuEntry<dynamic>> _rowMenuItems(
    int rowIndex,
  ) => <PopupMenuEntry<dynamic>>[
    _uiHelper.popupMenuButton(
      RowMenuItem.playbackModeSet,
      AppIcon.trackPlaybackMode,
      _trans.rowTracksPlaybackModeSet,
      itemBuilder: () => [
        ...AppGlobalConfig.trackPlaybackReleaseMode.values<ReleaseMode>().map(
          (ReleaseMode value) => _uiHelper.popupMenuItem(
            value,
            AppGlobalConfig.trackPlaybackReleaseMode.icon(value),
            _trans.rowTracksPlaybackModeSetTitle(
              AppGlobalConfig.trackPlaybackReleaseMode.translate(
                value,
                trans: _trans,
              ),
            ),
          ),
        ),
      ],
      onSelected: (selection) {
        _trackRepository.setTracksPlaybackMode(
          _trackRepository.rowTracks(rowIndex),
          selection,
        );
        _uiHelper.toast(
          _trans.rowTracksPlaybackModeSetSuccess(
            TrackRow.name(rowIndex),
            AppGlobalConfig.trackPlaybackReleaseMode.translate(
              selection,
              trans: _trans,
            ),
          ),
          icon: AppIcon.trackPlaybackMode,
        );
        Navigator.pop(_context);
      },
    ),
    _uiHelper.popupMenuButton(
      RowMenuItem.playbackVolumeSet,
      AppIcon.trackPlaybackVolume,
      _trans.rowTracksPlaybackVolumeSet,
      itemBuilder: () => [
        ...AppGlobalConfig.trackPlaybackVolume.values<double>().map(
          (double value) => _uiHelper.popupMenuItem(
            value,
            AppGlobalConfig.trackPlaybackVolume.icon(value),
            _trans.rowTracksPlaybackVolumeTitleSet(
              AppGlobalConfig.trackPlaybackVolume.format(value),
            ),
          ),
        ),
      ],
      onSelected: (selection) {
        _trackRepository.setTracksPlaybackVolume(
          _trackRepository.rowTracks(rowIndex),
          selection,
        );
        _uiHelper.toast(
          _trans.rowTracksPlaybackVolumeSuccessSet(
            TrackRow.name(rowIndex),
            AppGlobalConfig.trackPlaybackVolume.format(selection),
          ),
          icon: AppIcon.trackPlaybackVolume,
        );
        Navigator.pop(_context);
      },
    ),
    _uiHelper.popupMenuButton(
      RowMenuItem.playbackBalanceSet,
      AppIcon.trackPlaybackBalance,
      _trans.rowTracksPlaybackBalanceSet,
      itemBuilder: () => [
        ...AppGlobalConfig.trackPlaybackBalance.values<double>().map(
          (double value) => _uiHelper.popupMenuItem(
            value,
            AppGlobalConfig.trackPlaybackBalance.icon(value),
            _trans.rowTracksPlaybackBalanceTitleSet(
              AppGlobalConfig.trackPlaybackBalance.translate(
                value,
                trans: _trans,
              ),
            ),
          ),
        ),
      ],
      onSelected: (selection) {
        _trackRepository.setTracksPlaybackBalance(
          _trackRepository.rowTracks(rowIndex),
          selection,
        );
        _uiHelper.toast(
          _trans.rowTracksPlaybackBalanceSuccessSet(
            TrackRow.name(rowIndex),
            AppGlobalConfig.trackPlaybackBalance.translate(
              selection,
              trans: _trans,
            ),
          ),
          icon: AppIcon.trackPlaybackBalance,
        );
        Navigator.pop(_context);
      },
    ),
    _uiHelper.popupMenuButton(
      RowMenuItem.playbackSpeedSet,
      AppIcon.trackPlaybackSpeed,
      _trans.rowTracksPlaybackSpeedSet,
      itemBuilder: () => [
        ...AppGlobalConfig.trackPlaybackSpeed.values<double>().map(
          (double value) => _uiHelper.popupMenuItem(
            value,
            AppGlobalConfig.trackPlaybackSpeed.icon(value),
            _trans.rowTracksPlaybackSpeedTitleSet(
              AppGlobalConfig.trackPlaybackSpeed.format(value),
            ),
          ),
        ),
      ],
      onSelected: (selection) {
        _trackRepository.setTracksPlaybackSpeed(
          _trackRepository.rowTracks(rowIndex),
          selection,
        );
        _uiHelper.toast(
          _trans.rowTracksPlaybackSpeedSuccessSet(
            TrackRow.name(rowIndex),
            AppGlobalConfig.trackPlaybackSpeed.format(selection),
          ),
          icon: AppIcon.trackPlaybackSpeed,
        );
        Navigator.pop(_context);
      },
    ),
    const PopupMenuDivider(),
    _uiHelper.popupMenuItem(
      RowMenuItem.playbackStartAtPositionReset,
      AppIcon.trackPlaybackStartAtPosition,
      _trans.rowTracksPlaybackStartAtPositionReset,
    ),
    _uiHelper.popupMenuItem(
      RowMenuItem.playbackEndAtPositionReset,
      AppIcon.trackPlaybackEndAtPosition,
      _trans.rowTracksPlaybackEndAtPositionReset,
    ),
    const PopupMenuDivider(),
    _uiHelper.popupMenuItem(
      RowMenuItem.recordingsDelete,
      AppIcon.deleteForever,
      _trans.rowTracksRecordingsDelete,
    ),
  ];

  void _rowMenuItemSelected(RowMenuItem selection, int rowIndex) {
    switch (selection) {
      case RowMenuItem.playbackStartAtPositionReset:
        _uiHelper.alertDialogReset(
          AppIcon.trackPlaybackStartAtPosition,
          _trans.rowTracksPlaybackStartAtPositionResetTitle,
          _trans.rowTracksPlaybackStartAtPositionResetInfo(
            TrackRow.name(rowIndex),
          ),
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackRepository.resetTracksPlaybackStartAtPosition(
              _trackRepository.rowTracks(rowIndex),
            );
            return _trans.rowTracksPlaybackStartAtPositionResetSuccess(
              TrackRow.name(rowIndex),
            );
          },
        );
        break;
      case RowMenuItem.playbackEndAtPositionReset:
        _uiHelper.alertDialogReset(
          AppIcon.trackPlaybackEndAtPosition,
          _trans.rowTracksPlaybackEndAtPositionResetTitle,
          _trans.rowTracksPlaybackEndAtPositionResetInfo(
            TrackRow.name(rowIndex),
          ),
          _trans.buttonNo,
          _trans.buttonYes,
          () {
            _trackRepository.resetTracksPlaybackEndAtPosition(
              _trackRepository.rowTracks(rowIndex),
            );
            return _trans.rowTracksPlaybackEndAtPositionResetSuccess(
              TrackRow.name(rowIndex),
            );
          },
        );
        break;
      case RowMenuItem.recordingsDelete:
        _uiHelper.alertDialog(
          AppIcon.deleteForever,
          _trans.rowTracksRecordingsDeleteTitle,
          contentText: _trans.rowTracksRecordingsDeleteInfo(
            TrackRow.name(rowIndex),
          ),
          actions: <Widget>[
            _uiHelper.simpleButton(
              _trans.buttonNo,
              () => Navigator.pop(_context, 'No'),
            ),
            _uiHelper.errorButton(_trans.buttonYes, () {
              _trackRepository.deleteTracksRecordings(
                _trackRepository.rowTracks(rowIndex),
              );
              Navigator.pop(_context, 'Yes');
              _uiHelper.toast(
                _trans.rowTracksRecordingsDeleteSuccess(
                  TrackRow.name(rowIndex),
                ),
                icon: AppIcon.deleteForever,
              );
            }),
          ],
        );
        break;
      default:
    }
  }
}
