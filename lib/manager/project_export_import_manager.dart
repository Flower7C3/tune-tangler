import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_global_config.dart';
import '../config/app_icon.dart';
import '../helper/blocking_progress.dart';
import '../helper/ui_helper.dart';
import '../repository/track_repository.dart';
import '../service/project_export_service.dart';
import '../service/project_import_service.dart';
import '../src/generated/app_localizations.dart';
import '../wrapper/hive_settings_provider.dart';
import 'project_io_dialogs.dart';

class ProjectExportImportManager {
  final BuildContext _context;
  final HiveSettingsProvider _settings;
  final TrackRepository _trackRepository;
  final AppLocalizations _trans;
  final UIHelper _uiHelper;

  late final ProjectExportService _exportService;
  late final ProjectImportService _importService;
  late final ProjectIoDialogs _dialogs;

  ProjectExportImportManager(
    this._context,
    this._settings,
    this._trackRepository,
    this._trans,
    this._uiHelper,
  ) {
    _exportService = ProjectExportService(_settings, _trackRepository);
    _importService = ProjectImportService(_settings, _trackRepository, _trans);
    _dialogs = ProjectIoDialogs(_context, _trans, _uiHelper);
  }

  Future<void> exportProject() async {
    final name = await _dialogs.askExportName();
    if (name == null) {
      _uiHelper.toast(_trans.projectExportCancel, icon: AppIcon.projectExport);
      return;
    }
    final projectName = name.isEmpty ? null : name;

    BuildContext? progressContext;
    final exportProgress = ValueNotifier<double>(0.0);

    void closeProgress() {
      final c = progressContext;
      progressContext = null;
      BlockingProgress.close(c, logTag: 'ProjectExport');
    }

    try {
      if (!_context.mounted) return;

      BlockingProgress.show(
        context: _context,
        onContext: (BuildContext ctx) => progressContext = ctx,
        builder: (BuildContext ctx) => ValueListenableBuilder<double>(
          valueListenable: exportProgress,
          builder: (BuildContext _, double value, _) =>
              BlockingProgress.determinate(
            value: value,
            label: _trans.projectExporting,
          ),
        ),
      );

      exportProgress.value = 0.0;
      await BlockingProgress.yieldForPaint();

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
        _dialogs.showError(_trans.projectExportError, e.toString());
      }
    } finally {
      closeProgress();
      exportProgress.dispose();
    }
  }

  Future<void> importProject() async {
    try {
      final zipPath = await _selectZipFile();
      if (zipPath == null) return;

      final validationErrors = await _validateProject(zipPath);
      if (validationErrors.isNotEmpty) {
        if (_context.mounted) {
          _dialogs.showImportErrors(validationErrors, parentContext: _context);
          _uiHelper.toast(
            _trans.projectValidationFailed,
            icon: AppIcon.exception,
            type: ToastType.error,
          );
        }
        return;
      }

      final confirmed = await _showPreviewAndConfirm(zipPath);
      if (!confirmed) {
        _uiHelper.toast(
          _trans.projectImportCancel,
          icon: AppIcon.projectImport,
        );
        return;
      }

      await Future<void>.delayed(Duration.zero);
      await WidgetsBinding.instance.endOfFrame;

      await _performImport(zipPath);
      _settings.reload();
    } catch (e) {
      debugPrint('[ProjectImport] Unexpected error: ${e.toString()}');
      if (_context.mounted) {
        _dialogs.showError(_trans.projectImportError, e.toString());
      }
    }
  }

  Future<String?> _selectZipFile() async {
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (picked == null || picked.path == null) {
        _uiHelper.toast(
          _trans.projectImportCancel,
          icon: AppIcon.projectImport,
        );
        return null;
      }

      return picked.path!;
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

  Future<List<ProjectImportError>> _validateProject(String zipPath) async {
    BuildContext? validationContext;

    try {
      if (!_context.mounted) return [];

      BlockingProgress.show(
        context: _context,
        onContext: (BuildContext ctx) => validationContext = ctx,
        builder: (BuildContext _) =>
            BlockingProgress.indeterminate(label: _trans.projectValidating),
      );

      await BlockingProgress.yieldForPaint();

      final validationErrors = await _importService.validateProject(zipPath);
      if (validationContext != null && validationContext!.mounted) {
        BlockingProgress.close(validationContext, logTag: 'ProjectImport');
      }
      return validationErrors;
    } catch (e) {
      if (validationContext != null && validationContext!.mounted) {
        BlockingProgress.close(validationContext, logTag: 'ProjectImport');
      }
      debugPrint('[ProjectImport] Error during validation: $e');
      return [
        ProjectImportError(message: 'Validation failed: ${e.toString()}'),
      ];
    }
  }

  Future<bool> _showPreviewAndConfirm(String zipPath) async {
    try {
      final preview = await _importService.getProjectPreview(zipPath);
      final confirm = await _dialogs.showImportPreview(preview);
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

  Future<void> _performImport(String zipPath) async {
    BuildContext? progressContext;
    final importProgress = ValueNotifier<double>(0.0);

    void closeProgress() {
      final c = progressContext;
      progressContext = null;
      BlockingProgress.close(c, logTag: 'ProjectImport');
    }

    try {
      if (!_context.mounted) return;

      BlockingProgress.show(
        context: _context,
        onContext: (BuildContext ctx) => progressContext = ctx,
        builder: (BuildContext ctx) => ValueListenableBuilder<double>(
          valueListenable: importProgress,
          builder: (BuildContext _, double value, _) =>
              BlockingProgress.determinate(
            value: value,
            label: _trans.projectImporting,
          ),
        ),
      );

      importProgress.value = 0.0;
      await BlockingProgress.yieldForPaint();

      final errors = await _importService.importProject(
        zipPath,
        onProgress: (double p) {
          importProgress.value = p;
        },
      );

      closeProgress();

      if (!_context.mounted) return;
      if (errors.isNotEmpty) {
        _dialogs.showImportErrors(errors, parentContext: _context);
      } else {
        _uiHelper.toast(
          _trans.projectImportSuccess,
          icon: AppIcon.projectImport,
        );
      }
    } catch (e) {
      closeProgress();
      debugPrint('[ProjectImport] Error during import: $e');
      if (_context.mounted) {
        _dialogs.showError(
          _trans.projectImportError,
          e.toString(),
          parentContext: _context,
        );
      }
    } finally {
      closeProgress();
      importProgress.dispose();
    }
  }
}
