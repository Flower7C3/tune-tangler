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
    _importService = ProjectImportService(_settings, _trackRepository);
  }

  /// Eksportuje projekt
  Future<void> exportProject() async {
    String? projectName;

    // Dialog z możliwością podania nazwy projektu
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
      // Pokazuj progress
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

      // Eksportuj projekt
      final zipFile = await _exportService.exportProject(projectName);

      // Zamknij progress dialog
      if (progressContext != null && progressContext!.mounted && Navigator.of(progressContext!).canPop()) {
        Navigator.pop(progressContext!);
      }

      // Udostępnij plik
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(zipFile.path)],
          subject: _trans.projectExport,
        ),
      );

      _uiHelper.toast(_trans.projectExportSuccess, icon: AppIcon.projectExport);
    } catch (e) {
      // Zamknij progress dialog jeśli był otwarty
      if (progressContext != null && progressContext!.mounted && Navigator.of(progressContext!).canPop()) {
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

  /// Importuje projekt
  Future<void> importProject() async {
    try {
      // Wybierz plik ZIP
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null || result.files.single.path == null) {
        _uiHelper.toast(
          _trans.projectImportCancel,
          icon: AppIcon.projectImport,
        );
        return;
      }

      final zipPath = result.files.single.path!;

      // Pobierz podgląd projektu
      final preview = await _importService.getProjectPreview(zipPath);

      // Wyświetl podgląd i potwierdzenie
      final confirm = await _showImportPreview(preview);

      if (confirm != true) {
        _uiHelper.toast(
          _trans.projectImportCancel,
          icon: AppIcon.projectImport,
        );
        return;
      }

      // Walidacja przed importem
      BuildContext? validationContext;
      if (!_context.mounted) return;
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

      final validationErrors = await _importService.validateProject(zipPath);

      if (validationContext != null &&
          validationContext!.mounted &&
          Navigator.of(validationContext!).canPop()) {
        Navigator.pop(validationContext!);
      }

      if (validationErrors.isNotEmpty) {
        if (validationContext != null && validationContext!.mounted) {
          _showImportErrors(validationErrors, parentContext: validationContext);
        }
        if (_context.mounted) {
          _uiHelper.toast(
            _trans.projectValidationFailed,
            icon: AppIcon.exception,
            type: ToastType.error,
          );
        }
        return;
      }

      // Pokazuj progress importu
      BuildContext? progressContext;
      try {
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
                  Text(_trans.projectImporting),
                ],
              ),
            );
          },
        );

        // Importuj projekt (tylko po pomyślnej walidacji)
        final errors = await _importService.importProject(zipPath);

        // Zamknij progress dialog
        if (progressContext != null && progressContext!.mounted && Navigator.of(progressContext!).canPop()) {
          Navigator.pop(progressContext!);
        }

        // Wyświetl błędy/ostrzeżenia jeśli są
        if (errors.isNotEmpty) {
          if (progressContext != null && progressContext!.mounted) {
            _showImportErrors(errors, parentContext: progressContext);
          }
        } else {
          if (_context.mounted) {
            _uiHelper.toast(
              _trans.projectImportSuccess,
              icon: AppIcon.projectImport,
            );
          }
        }
      } catch (e) {
        debugPrint('[ProjectExport] errors: ${e.toString()}');
        // Zamknij progress dialog jeśli był otwarty (progressContext może nie być zdefiniowany)
        // Nie ma potrzeby zamykania validationContext bo już został zamknięty
        if (progressContext != null && progressContext!.mounted) {
          _uiHelper.alertDialog(
            AppIcon.exception,
            _trans.projectImportError,
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
        } else if (_context.mounted) {
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
            child: Text(_trans.buttonConfirm),
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

    // Jeśli były tylko ostrzeżenia, pokaż też sukces
    if (errorMessages.isEmpty && warningMessages.isNotEmpty) {
      _uiHelper.toast(_trans.projectImportSuccess, icon: AppIcon.projectImport);
    }
  }
}
