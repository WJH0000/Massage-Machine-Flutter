import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

// final String massageSettingTable = 'massageSetting';

// class MassageSettingFields {
//   static final List<String> values = [
//     /// Add all fields
//     massageSettingId, userId, massageConfiguration, modifiedAt
//   ];

//   static final String massageSettingId = 'massageSettingId';
//   static final String userId = 'userId';
//   static final String massageConfiguration = 'massageConfiguration';
//   static final String modifiedAt = 'modifiedAt';
// }

@JsonSerializable()
class DoctorRecommendMassageSetting {
  final String? massageSettingId;
  final String? massageConfiguration;
  final String? description;

  DoctorRecommendMassageSetting({
    this.massageSettingId,
    this.massageConfiguration,
    this.description,
  });

  DoctorRecommendMassageSetting copy({
    String? massageSettingId,
    String? massageConfiguration,
    String? description,
  }) =>
      DoctorRecommendMassageSetting(
        massageSettingId: massageSettingId ?? this.massageSettingId,
        massageConfiguration: massageConfiguration ?? this.massageConfiguration,
        description: description ?? this.description,
      );

  //Convert json to massageSetting object
  factory DoctorRecommendMassageSetting.fromJson(Map<String, dynamic> json) =>
      _$DoctorRecommendMassageSettingFromJson(json);

  //Convert massageSetting object to json
  Map<String, dynamic> toJson() => _$DoctorRecommendMassageSettingToJson(this);

  static DoctorRecommendMassageSetting _$DoctorRecommendMassageSettingFromJson(
          Map<String, dynamic> json) =>
      DoctorRecommendMassageSetting(
        massageSettingId: json['massageSettingId'] as String?,
        massageConfiguration: json['massageConfiguration'] as String?,
        description: json['description'] as String?,
      );

  Map<String, dynamic> _$DoctorRecommendMassageSettingToJson(
          DoctorRecommendMassageSetting instance) =>
      <String, dynamic>{
        'massageSettingId': instance.massageSettingId,
        'massageConfiguration': instance.massageConfiguration,
        'description': instance.description,
      };
}
