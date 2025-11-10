import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 0)
class UserSettings extends HiveObject {
  @HiveField(0)
  String pinHash; // SHA256 hash of PIN

  @HiveField(1)
  bool isFirstRun;

  @HiveField(2)
  DateTime createdAt;

  UserSettings({
    required this.pinHash,
    this.isFirstRun = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'pinHash': pinHash,
    'isFirstRun': isFirstRun,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    pinHash: json['pinHash'] as String,
    isFirstRun: json['isFirstRun'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
