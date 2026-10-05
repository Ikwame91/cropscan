import 'dart:convert';

class UserProfile {
  final String id;
  final String name;
  final String region;
  final String? profileImagePath;
  final DateTime createdAt;
  final DateTime lastUpdated;

  // Optional fields
  final String? phoneNumber;
  final String? farmSize;
  final List<String> primaryCrops;

  const UserProfile({
    required this.id,
    required this.name,
    required this.region,
    this.profileImagePath,
    required this.createdAt,
    required this.lastUpdated,
    this.phoneNumber,
    this.farmSize,
    this.primaryCrops = const [],
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? region,
    String? profileImagePath,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? phoneNumber,
    String? farmSize,
    List<String>? primaryCrops,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      farmSize: farmSize ?? this.farmSize,
      primaryCrops: primaryCrops ?? this.primaryCrops,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'profileImagePath': profileImagePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'phoneNumber': phoneNumber,
      'farmSize': farmSize,
      'primaryCrops': primaryCrops,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Local Farmer',
      region: map['region'] ?? 'Ghana',
      profileImagePath: map['profileImagePath'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] ?? 0),
      phoneNumber: map['phoneNumber'],
      farmSize: map['farmSize'],
      primaryCrops: List<String>.from(map['primaryCrops'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, region: $region, profileImagePath: $profileImagePath, createdAt: $createdAt, lastUpdated: $lastUpdated, phoneNumber: $phoneNumber, farmSize: $farmSize, primaryCrops: $primaryCrops)';
  }
}
