/// Parses the raw class labels produced by the TFLite model
/// (e.g. `Tomato__Tomato_YellowLeaf__Curl_Virus`, `Corn_(maize)___healthy`)
/// into something the UI can work with.
///
/// This is the fallback used whenever a label has no entry in
/// `crop_database.json`; the database's `basic_info` wins when present.
class CropLabel {
  static const String notACropLabel = 'not_a_crop';

  final String raw;

  /// Human-readable crop name, e.g. "Tomato", "Maize", "Bell Pepper".
  final String crop;

  /// Human-readable condition, e.g. "Early Blight" or "Healthy".
  final String condition;

  final bool isHealthy;
  final bool isNotACrop;

  const CropLabel._({
    required this.raw,
    required this.crop,
    required this.condition,
    required this.isHealthy,
    required this.isNotACrop,
  });

  static final RegExp _cropPrefix = RegExp(
    r'^(corn_\(maize\)|corn|maize|pepper__bell|pepper_bell|pepper|tomato)_*',
    caseSensitive: false,
  );

  factory CropLabel.parse(String raw) {
    final trimmed = raw.trim();
    final lower = trimmed.toLowerCase();

    if (lower == notACropLabel || lower == 'not a crop') {
      return CropLabel._(
        raw: trimmed,
        crop: 'Not a crop',
        condition: 'Not a crop',
        isHealthy: false,
        isNotACrop: true,
      );
    }

    final crop = _cropName(lower);
    var rest = trimmed.replaceFirst(_cropPrefix, '');
    // Some labels repeat the crop: "Tomato__Tomato_mosaic_virus".
    rest = rest.replaceFirst(_cropPrefix, '');
    final words = rest
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map(_capitalize)
        .toList();
    final condition = words.isEmpty ? 'Unknown' : words.join(' ');
    final isHealthy = condition.toLowerCase() == 'healthy';

    return CropLabel._(
      raw: trimmed,
      crop: crop,
      condition: condition,
      isHealthy: isHealthy,
      isNotACrop: false,
    );
  }

  String get displayName => isNotACrop ? crop : '$crop - $condition';

  static String _cropName(String lowerRaw) {
    if (lowerRaw.startsWith('corn') || lowerRaw.startsWith('maize')) {
      return 'Maize';
    }
    if (lowerRaw.startsWith('pepper')) return 'Bell Pepper';
    if (lowerRaw.startsWith('tomato')) return 'Tomato';
    return 'Unknown crop';
  }

  static String _capitalize(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  /// Normalises a label for loose matching: lower case, with runs of
  /// underscores, spaces and brackets collapsed.
  static String normalize(String label) => label
      .toLowerCase()
      .replaceAll(RegExp(r'[()]'), '')
      .replaceAll(RegExp(r'[_\s]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  @override
  String toString() => 'CropLabel($raw → $displayName)';
}
