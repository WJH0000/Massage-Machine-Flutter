import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class MassageSettingRequest {
  final String? massageSettingId;
  final String? userId;
  final String? massageConfiguration;
  final String? modifiedAt;

  MassageSettingRequest({
    this.massageSettingId,
    this.userId,
    this.massageConfiguration,
    this.modifiedAt,
  });

  factory MassageSettingRequest.fromJson(Map<String, dynamic> json) =>
      _$MassageSettingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MassageSettingRequestToJson(this);

  static MassageSettingRequest _$MassageSettingRequestFromJson(
          Map<String, dynamic> json) =>
      MassageSettingRequest(
        massageSettingId: json['massageSettingId'] as String,
        userId: json['userId'] as String,
        massageConfiguration: json['massageConfiguration'] as String,
        modifiedAt: json['modifiedAt'] as String,
      );

  Map<String, dynamic> _$MassageSettingRequestToJson(
          MassageSettingRequest instance) =>
      <String, dynamic>{
        'massageSettingId': instance.massageSettingId,
        'userId': instance.userId,
        'massageConfiguration': jsonDecode(instance.massageConfiguration!),
        'modifiedAt': instance.modifiedAt,
      };
}
