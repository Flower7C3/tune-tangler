class ProjectImportError {
  final String message;
  final String? fileName;
  final bool isWarning;

  ProjectImportError({required this.message, this.fileName, this.isWarning = false});
}
