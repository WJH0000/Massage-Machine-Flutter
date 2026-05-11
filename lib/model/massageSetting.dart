import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

final String massageSettingTable = 'massageSetting';

class MassageSettingFields {
  static final List<String> values = [
    /// Add all fields
    massageSettingId, userId, massageConfiguration, modifiedAt
  ];

  static final String massageSettingId = 'massageSettingId';
  static final String userId = 'userId';
  static final String massageConfiguration = 'massageConfiguration';
  static final String modifiedAt = 'modifiedAt';
}

@JsonSerializable()
class MassageSetting {
  final String? massageSettingId;
  final String? userId;
  final String? massageConfiguration;
  final String? modifiedAt;

  MassageSetting({
    this.massageSettingId,
    this.userId,
    this.massageConfiguration,
    this.modifiedAt,
  });

  MassageSetting copy({
    String? massageSettingId,
    String? userId,
    String? massageConfiguration,
    String? modifiedAt,
  }) =>
      MassageSetting(
        massageSettingId: massageSettingId ?? this.massageSettingId,
        userId: userId ?? this.userId,
        massageConfiguration: massageConfiguration ?? this.massageConfiguration,
        modifiedAt: modifiedAt ?? this.modifiedAt,
      );

  //Convert json to massageSetting object
  factory MassageSetting.fromJson(Map<String, dynamic> json) =>
      _$MassageSettingFromJson(json);

  //Convert massageSetting object to json
  Map<String, dynamic> toJson() => _$MassageSettingToJson(this);

  static MassageSetting _$MassageSettingFromJson(Map<String, dynamic> json) =>
      MassageSetting(
        massageSettingId: json['massageSettingId'] as String?,
        userId: json['userId'] as String?,
        massageConfiguration: json['massageConfiguration'] as String?,
        modifiedAt: json['modifiedAt'] as String?,
      );

  Map<String, dynamic> _$MassageSettingToJson(MassageSetting instance) =>
      <String, dynamic>{
        'massageSettingId': instance.massageSettingId,
        'userId': instance.userId,
        'massageConfiguration': instance.massageConfiguration,
        'modifiedAt': instance.modifiedAt,
      };
}
