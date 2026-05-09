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

    if (nameResult != true) {
      _uiHelper.toast(_trans.projectExportCancel, icon: AppIcon.projectExport);
      return;
    }

    projectName = nameController.text.trim();
    if (projectName.isEmpty) {
      projectName = null;
    }

    BuildContext? progressContext;
    final exportProgress = ValueNotifier<double>(0.0);

    void closeProgress() {
      final c = progressContext;
      progressContext = null;
      if (c != null && c.mounted) {
        try {
          final nav = Navigator.of(c, rootNavigator: true);
          if (nav.canPop()) nav.pop();
        } catch (e) {
          debugPrint('[ProjectExport] Could not close progress dialog: $e');
        }
      }
    }

    try {
      if (!_context.mounted) return;

      showDialog<void>(
        context: _context,
        useRootNavigator: true,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (BuildContext context) {
          progressContext = context;
          return ValueListenableBuilder<double>(
            valueListenable: exportProgress,
            builder: (BuildContext ctx, double value, _) {
              final v = value.clamp(0.0, 1.0);
              final pct = (v * 100).round().clamp(0, 100);
              final theme = Theme.of(ctx);
              final trackColor = theme.colorScheme.primary;
              final trackBg = theme.colorScheme.surfaceContainerHighest;
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(color: trackBg),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: v <= 0 ? 0.04 : v,
                              child: ColoredBox(color: trackColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$pct%',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _trans.projectExporting,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

      exportProgress.value = 0.0;

      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 32));

      final zipFile = await _exportService.exportProject(
        projectName,
        onProgress: (double p) => exportProgress.value = p,
      );

      closeProgress();

      if (!_context.mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(zipFile.path)],
          subject: _trans.projectExport,
        ),
      );
    } catch (e) {
      closeProgress();
      debugPrint('[ProjectExport] Error during export: $e');
      if (_context.mounted) {
        _uiHelper.alertDialog(
          AppIcon.exception,
          _trans.projectExportError,
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
    } finally {
      closeProgress();
      exportProgress.dispose();
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

      // Preview route just closed — yield so the progress dialog can paint (same pattern as track share).
      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;

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
      final result = await FilePicker.pickFiles(
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
      showDialog<void>(
        context: _context,
        useRootNavigator: true,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (BuildContext context) {
          validationContext = context;
          final theme = Theme.of(context);
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _trans.projectValidating,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          );
        },
      );

      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 32));

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
    final importProgress = ValueNotifier<double>(0.0);

    void closeProgress() {
      final c = progressContext;
      progressContext = null;
      if (c != null && c.mounted) {
        try {
          final nav = Navigator.of(c, rootNavigator: true);
          if (nav.canPop()) nav.pop();
        } catch (e) {
          debugPrint('[ProjectImport] Could not close import dialog: $e');
        }
      }
    }

    try {
      if (!_context.mounted) return;

      showDialog<void>(
        context: _context,
        useRootNavigator: true,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (BuildContext context) {
          progressContext = context;
          return ValueListenableBuilder<double>(
            valueListenable: importProgress,
            builder: (BuildContext ctx, double value, _) {
              final v = value.clamp(0.0, 1.0);
              final pct = (v * 100).round().clamp(0, 100);
              final theme = Theme.of(ctx);
              final trackColor = theme.colorScheme.primary;
              final trackBg = theme.colorScheme.surfaceContainerHighest;
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(color: trackBg),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: v <= 0 ? 0.04 : v,
                              child: ColoredBox(color: trackColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$pct%',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _trans.projectImporting,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

      importProgress.value = 0.0;

      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 32));

      final errors = await _importService.importProject(
        zipPath,
        onProgress: (double p) {
          importProgress.value = p;
        },
      );

      closeProgress();

      // Handle import results (use progressContext only if still mounted)
      final contextForResult = _context.mounted ? _context : null;
      if (contextForResult != null && contextForResult.mounted) {
        _handleImportResult(errors, contextForResult);
      }
    } catch (e) {
      closeProgress();
      debugPrint('[ProjectImport] Error during import: $e');
      final contextForError = _context.mounted ? _context : null;
      if (contextForError != null && contextForError.mounted) {
        _showImportError(e.toString(), contextForError);
      }
    } finally {
      closeProgress();
      importProgress.dispose();
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
              SizedBox(height: 16),
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
