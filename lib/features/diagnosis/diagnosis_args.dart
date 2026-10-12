/// Arguments for the diagnosis results route.
///
/// Scans are saved to history *before* the results screen opens, so the
/// screen only needs the saved record's id.
class DiagnosisArgs {
  final String detectionId;

  /// True when arriving straight from the camera (vs. from history).
  final bool justScanned;

  const DiagnosisArgs({required this.detectionId, this.justScanned = false});
}
