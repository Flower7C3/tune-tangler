import 'package:flutter/material.dart';

import '../config/app_icon.dart';
import '../helper/ui_helper.dart';
import '../service/project_import_error.dart';
import '../src/generated/app_localizations.dart';

class ProjectIoDialogs {
  final BuildContext _context;
  final AppLocalizations _trans;
  final UIHelper _uiHelper;

  ProjectIoDialogs(this._context, this._trans, this._uiHelper);

  Future<String?> askExportName() async {
    final nameController = TextEditingController();
    final nameResult = await showDialog<bool>(
      context: _context,
      builder: (context) => AlertDialog(
        title: _uiHelper.statusIconTile(
          AppIcon.projectExport,
          _trans.projectExport,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _trans.projectExportInfo,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: _trans.projectExportName,
                hintText: _trans.projectExportNameHint,
              ),
              onSubmitted: (_) => Navigator.pop(context, true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.pop(context, false);
              }
            },
            child: Text(_trans.buttonCancel),
          ),
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.pop(context, true);
              }
            },
            child: Text(_trans.buttonExport),
          ),
        ],
      ),
    );

    if (nameResult != true) return null;
    final name = nameController.text.trim();
    return name.isEmpty ? '' : name;
  }

  Future<bool?> showImportPreview(Map<String, dynamic> preview) {
    final gridSize = preview['gridSize'] as Map<String, dynamic>?;
    final statistics = preview['statistics'] as Map<String, dynamic>?;
    final projectName = preview['projectName'] as String?;
    final exportDate = preview['exportDateFormatted'] as String?;

    return showDialog<bool>(
      context: _context,
      builder: (context) => AlertDialog(
        title: _uiHelper.statusIconTile(
          AppIcon.projectPreview,
          _trans.projectPreview,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (projectName != null) ...[
                _uiHelper.valueIconTile(
                  AppIcon.projectName,
                  _trans.projectName,
                  projectName,
                ),
              ],
              if (exportDate != null) ...[
                _uiHelper.valueIconTile(
                  AppIcon.projectExportDate,
                  _trans.projectExportDate,
                  exportDate,
                ),
              ],
              if (gridSize != null) ...[
                _uiHelper.valueIconTile(
                  AppIcon.grid,
                  _trans.projectGridSize,
                  '${gridSize['rows']} x ${gridSize['cols']} (${(gridSize['rows'] as int) * (gridSize['cols'] as int)} ${_trans.projectTotalTracks.toLowerCase()})',
                ),
              ],
              if (statistics != null) ...[
                _uiHelper.valueIconTile(
                  AppIcon.trackRecordingStart,
                  _trans.projectTracksWithRecordings,
                  '${statistics['tracksWithRecordings']}',
                ),
                _uiHelper.valueIconTile(
                  AppIcon.projectRecordingsSize,
                  _trans.projectTotalRecordingsSize,
                  '${statistics['totalRecordingsSizeFormatted']}',
                ),
              ],
              const SizedBox(height: 16),
              Text(
                _trans.projectImportWarning,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.pop(context, false);
              }
            },
            child: Text(_trans.buttonCancel),
          ),
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.pop(context, true);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(_trans.buttonYesImport),
          ),
        ],
      ),
    );
  }

  void showError(String title, String message, {BuildContext? parentContext}) {
    _uiHelper.alertDialog(
      AppIcon.exception,
      title,
      contentText: message,
      parentContext: parentContext,
      actions: [
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_trans.buttonCancel),
          ),
        ),
      ],
    );
  }

  void showImportErrors(List errors, {BuildContext? parentContext}) {
    final errorMessages = <String>[];
    final warningMessages = <String>[];

    for (final error in errors) {
      if (error is ProjectImportError) {
        final message = error.fileName != null
            ? '${error.message} (${error.fileName})'
            : error.message;
        if (error.isWarning) {
          warningMessages.add(message);
        } else {
          errorMessages.add(message);
        }
      } else {
        errorMessages.add(error.toString());
      }
    }

    final allMessages = <String>[];
    if (errorMessages.isNotEmpty) {
      allMessages.add('${_trans.projectImportError}:');
      allMessages.addAll(errorMessages);
    }
    if (warningMessages.isNotEmpty) {
      if (allMessages.isNotEmpty) allMessages.add('');
      allMessages.add('${_trans.projectDurationMismatchTitle}:');
      allMessages.addAll(warningMessages);
    }

    debugPrint('[ProjectExport] errors: ${allMessages.join('\n')}');

    showError(
      _trans.projectImportError,
      allMessages.join('\n'),
      parentContext: parentContext,
    );

    if (errorMessages.isEmpty && warningMessages.isNotEmpty) {
      _uiHelper.toast(_trans.projectImportSuccess, icon: AppIcon.projectImport);
    }
  }
}
