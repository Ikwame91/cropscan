/// Ghana's regions and the coordinates of each regional capital, used to
/// fetch weather without asking for GPS permission.
class GhanaRegion {
  final String name;
  final String capital;
  final double latitude;
  final double longitude;

  const GhanaRegion(this.name, this.capital, this.latitude, this.longitude);
}

class GhanaRegions {
  /// The 16 regions, as offered in the profile.
  static const List<GhanaRegion> all = [
    GhanaRegion('Ahafo Region', 'Goaso', 6.8036, -2.5172),
    GhanaRegion('Ashanti Region', 'Kumasi', 6.6885, -1.6244),
    GhanaRegion('Bono Region', 'Sunyani', 7.3349, -2.3123),
    GhanaRegion('Bono East Region', 'Techiman', 7.5862, -1.9381),
    GhanaRegion('Central Region', 'Cape Coast', 5.1053, -1.2466),
    GhanaRegion('Eastern Region', 'Koforidua', 6.0941, -0.2591),
    GhanaRegion('Greater Accra Region', 'Accra', 5.6037, -0.1870),
    GhanaRegion('North East Region', 'Nalerigu', 10.5274, -0.3698),
    GhanaRegion('Northern Region', 'Tamale', 9.4008, -0.8393),
    GhanaRegion('Oti Region', 'Dambai', 8.0667, 0.1833),
    GhanaRegion('Savannah Region', 'Damongo', 9.0833, -1.8167),
    GhanaRegion('Upper East Region', 'Bolgatanga', 10.7856, -0.8514),
    GhanaRegion('Upper West Region', 'Wa', 10.0601, -2.5099),
    GhanaRegion('Volta Region', 'Ho', 6.6008, 0.4713),
    GhanaRegion('Western Region', 'Sekondi-Takoradi', 4.9340, -1.7137),
    GhanaRegion('Western North Region', 'Sefwi Wiawso', 6.2056, -2.4859),
  ];

  /// Profiles saved before the 2018 split may still say "Brong-Ahafo".
  static const _legacy = {
    'brong-ahafo region': 'Bono Region',
    'brong ahafo region': 'Bono Region',
  };

  /// Finds a region by name, tolerating case and a missing "Region".
  static GhanaRegion? find(String? name) {
    if (name == null) return null;
    var key = name.trim().toLowerCase();
    if (key.isEmpty) return null;
    if (!key.endsWith(' region')) key = '$key region';
    key = _legacy[key]?.toLowerCase() ?? key;
    for (final region in all) {
      if (region.name.toLowerCase() == key) return region;
    }
    return null;
  }
}
