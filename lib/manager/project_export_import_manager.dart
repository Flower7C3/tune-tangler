import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_global_config.dart';
import '../config/app_icon.dart';
import '../helper/ui_helper.dart';
import '../repository/track_repository.dart';
import '../service/project_export_service.dart';
import '../service/project_import_service.dart'
    show ProjectImportService, ProjectImportError;
import '../src/generated/app_localizations.dart';
import '../wrapper/hive_settings_provider.dart';

class ProjectExportImportManager {
  final BuildContext _context;
  final HiveSettingsProvider _settings;
  final TrackRepository _trackRepository;
  final AppLocalizations _trans;
  final UIHelper _uiHelper;

  late final ProjectExportService _exportService;
  late final ProjectImportService _importService;

  ProjectExportImportManager(
    this._context,
    this._settings,
    this._trackRepository,
    this._trans,
    this._uiHelper,
  ) {
    _exportService = ProjectExportService(_settings, _trackRepository);
    _importService = ProjectImportService(_settings, _trackRepository, _trans);
  }

  /// Exports project
  Future<void> exportProject() async {
    String? projectName;

    // Dialog with option to provide project name
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
          children: [
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

    if (nameResult != true) {
      _uiHelper.toast(_trans.projectExportCancel, icon: AppIcon.projectExport);
      return;
    }

    projectName = nameController.text.trim();
    if (projectName.isEmpty) {
      projectName = null;
    }

    BuildContext? progressContext;
    try {
      // Show progress
      if (!_context.mounted) return;
      showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (context) {
          progressContext = context;
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(_trans.projectExporting),
              ],
            ),
          );
        },
      );

      // Export project
      final zipFile = await _exportService.exportProject(projectName);

      // Close progress dialog
      if (progressContext != null &&
          progressContext!.mounted &&
          Navigator.of(progressContext!).canPop()) {
        Navigator.pop(progressContext!);
      }

      // Share file
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(zipFile.path)],
          subject: _trans.projectExport,
        ),
      );

      _uiHelper.toast(_trans.projectExportSuccess, icon: AppIcon.projectExport);
    } catch (e) {
      // Close progress dialog if it was open
      if (progressContext != null &&
          progressContext!.mounted &&
          Navigator.of(progressContext!).canPop()) {
        Navigator.pop(progressContext!);
      }
      if (progressContext != null && progressContext!.mounted) {
        _uiHelper.alertDialog(
          AppIcon.exception,
          _trans.projectExportError,
          contentText: e.toString(),
          parentContext: progressContext,
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
    }
  }

  /// Imports project
  Future<void> importProject() async {
    try {
      // 1. Select ZIP file
      final zipPath = await _selectZipFile();
      if (zipPath == null) return;

      // 2. Validate project
      final validationErrors = await _validateProject(zipPath);
      if (validationErrors.isNotEmpty) {
        _handleValidationErrors(validationErrors);
        return;
      }

      // 3. Show preview and get confirmation
      final confirmed = await _showPreviewAndConfirm(zipPath);
      if (!confirmed) {
        _uiHelper.toast(
          _trans.projectImportCancel,
          icon: AppIcon.projectImport,
        );
        return;
      }

      // 4. Perform import
      await _performImport(zipPath);

      // 5. Refresh settings (notifyListeners) so view updates
      _settings.reload();
    } catch (e) {
      debugPrint('[ProjectImport] Unexpected error: ${e.toString()}');
      if (_context.mounted) {
        _uiHelper.alertDialog(
          AppIcon.exception,
          _trans.projectImportError,
          contentText: e.toString(),
          parentContext: _context,
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
    }
  }

  /// Selects ZIP file for import
  Future<String?> _selectZipFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null || result.files.single.path == null) {
        _uiHelper.toast(
          _trans.projectImportCancel,
          icon: AppIcon.projectImport,
        );
        return null;
      }

      return result.files.single.path!;
    } catch (e) {
      debugPrint('[ProjectImport] Error selecting ZIP file: $e');
      if (_context.mounted) {
        _uiHelper.toast(
          _trans.projectImportError,
          icon: AppIcon.exception,
          type: ToastType.error,
        );
      }
      return null;
    }
  }

  /// Validates project with progress dialog display
  Future<List<ProjectImportError>> _validateProject(String zipPath) async {
    BuildContext? validationContext;

    try {
      if (!_context.mounted) return [];

      // Show validation dialog
      showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (context) {
          validationContext = context;
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(_trans.projectValidating),
              ],
            ),
          );
        },
      );

      // Wait a moment for dialog to open
      await Future.delayed(Duration(milliseconds: 100));

      // Perform validation
      final validationErrors = await _importService.validateProject(zipPath);

      // Close validation dialog (check if still mounted)
      if (validationContext != null && validationContext!.mounted) {
        _closeDialog(validationContext, 'validation');
      }

      return validationErrors;
    } catch (e) {
      if (validationContext != null && validationContext!.mounted) {
        _closeDialog(validationContext, 'validation');
      }
      debugPrint('[ProjectImport] Error during validation: $e');
      return [
        ProjectImportError(
          message: 'Validation failed: ${e.toString()}',
        ),
      ];
    }
  }

  /// Handles validation errors
  void _handleValidationErrors(List<ProjectImportError> errors) {
    if (!_context.mounted) return;

    _showImportErrors(errors, parentContext: _context);
    _uiHelper.toast(
      _trans.projectValidationFailed,
      icon: AppIcon.exception,
      type: ToastType.error,
    );
  }

  /// Shows project preview and gets user confirmation
  Future<bool> _showPreviewAndConfirm(String zipPath) async {
    try {
      // Get project preview
      final preview = await _importService.getProjectPreview(zipPath);

      // Display preview and confirmation
      final confirm = await _showImportPreview(preview);
      return confirm == true;
    } catch (e) {
      debugPrint('[ProjectImport] Error showing preview: $e');
      if (_context.mounted) {
        _uiHelper.toast(
          _trans.projectImportError,
          icon: AppIcon.exception,
          type: ToastType.error,
        );
      }
      return false;
    }
  }

  /// Performs project import with progress dialog display
  Future<void> _performImport(String zipPath) async {
    BuildContext? progressContext;

    try {
      if (!_context.mounted) return;

      // Show import dialog
      showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (context) {
          progressContext = context;
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(_trans.projectImporting),
              ],
            ),
          );
        },
      );

      // Wait a moment for dialog to open
      await Future.delayed(Duration(milliseconds: 100));

      // Perform import
      final errors = await _importService.importProject(zipPath);

      // Close import dialog (check if still mounted)
      if (progressContext != null && progressContext!.mounted) {
        _closeDialog(progressContext, 'import');
      }

      // Handle import results (use progressContext only if still mounted)
      final contextForResult = (progressContext != null && progressContext!.mounted)
          ? progressContext
          : (_context.mounted ? _context : null);
      if (contextForResult != null && contextForResult.mounted) {
        _handleImportResult(errors, contextForResult);
      }
    } catch (e) {
      if (progressContext != null && progressContext!.mounted) {
        _closeDialog(progressContext, 'import');
      }
      debugPrint('[ProjectImport] Error during import: $e');
      final contextForError = (progressContext != null && progressContext!.mounted)
          ? progressContext
          : (_context.mounted ? _context : null);
      if (contextForError != null && contextForError.mounted) {
        _showImportError(e.toString(), contextForError);
      }
    }
  }

  /// Handles import results (errors/warnings or success)
  void _handleImportResult(
    List<ProjectImportError> errors,
    BuildContext parentContext,
  ) {
    if (!parentContext.mounted) return;

    if (errors.isNotEmpty) {
      _showImportErrors(errors, parentContext: parentContext);
    } else {
      if (_context.mounted) {
        _uiHelper.toast(
          _trans.projectImportSuccess,
          icon: AppIcon.projectImport,
        );
      }
    }
  }

  /// Shows import error
  void _showImportError(String errorMessage, BuildContext parentContext) {
    if (!parentContext.mounted) return;

    _uiHelper.alertDialog(
      AppIcon.exception,
      _trans.projectImportError,
      contentText: errorMessage,
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

  /// Closes dialog safely
  void _closeDialog(BuildContext? dialogContext, String dialogType) {
    if (dialogContext == null || !dialogContext.mounted) return;

    try {
      final navigator = Navigator.of(dialogContext, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop();
      }
    } catch (e) {
      debugPrint('[ProjectImport] Could not close $dialogType dialog: $e');
    }
  }


  Future<bool?> _showImportPreview(Map<String, dynamic> preview) async {
    final gridSize = preview['gridSize'] as Map<String, dynamic>?;
    final statistics = preview['statistics'] as Map<String, dynamic>?;
    final projectName = preview['projectName'] as String?;
    final exportDate = preview['exportDateFormatted'] as String?;

    final iconSize =
        Theme.of(_context).textTheme.bodyLarge!.fontSize! *
        UIHelper.iconSizeMultiplier;
    final fontSize = Theme.of(_context).textTheme.bodyLarge!.fontSize!;

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
                _uiHelper.statusIconTile(
                  AppIcon.projectName,
                  _trans.projectName,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  subtitleWidget: Text(
                    projectName,
                    style: TextStyle(fontSize: fontSize),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              if (exportDate != null) ...[
                _uiHelper.statusIconTile(
                  AppIcon.projectExportDate,
                  _trans.projectExportDate,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  subtitleWidget: Text(
                    exportDate,
                    style: TextStyle(fontSize: fontSize),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              if (gridSize != null) ...[
                _uiHelper.statusIconTile(
                  AppIcon.grid,
                  _trans.projectGridSize,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  subtitleWidget: Text(
                    '${gridSize['rows']} x ${gridSize['cols']} (${(gridSize['rows'] as int) * (gridSize['cols'] as int)} ${_trans.projectTotalTracks.toLowerCase()})',
                    style: TextStyle(fontSize: fontSize),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              if (statistics != null) ...[
                _uiHelper.statusIconTile(
                  AppIcon.trackRecordingStart,
                  _trans.projectTracksWithRecordings,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  subtitleWidget: Text(
                    '${statistics['tracksWithRecordings']}',
                    style: TextStyle(fontSize: fontSize),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                _uiHelper.statusIconTile(
                  AppIcon.projectRecordingsSize,
                  _trans.projectTotalRecordingsSize,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  subtitleWidget: Text(
                    '${statistics['totalRecordingsSizeFormatted']}',
                    style: TextStyle(fontSize: fontSize),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              SizedBox(height: 16),
              Text(
                _trans.projectImportWarning,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
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

  void _showImportErrors(List errors, {BuildContext? parentContext}) {
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

    _uiHelper.alertDialog(
      AppIcon.exception,
      _trans.projectImportError,
      contentText: allMessages.join('\n'),
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

    // If there were only warnings, also show success
    if (errorMessages.isEmpty && warningMessages.isNotEmpty) {
      _uiHelper.toast(_trans.projectImportSuccess, icon: AppIcon.projectImport);
    }
  }
}
