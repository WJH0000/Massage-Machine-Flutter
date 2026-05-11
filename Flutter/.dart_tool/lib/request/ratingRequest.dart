//import 'dart:ffi';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class RatingRequest {
  final String? massageSettingId;
  final String? userId;
  final double rating;
  final String? massageConfiguration;
  final String? modifiedAt;

  RatingRequest(
      {this.massageSettingId,
      this.userId,
      required this.rating,
      this.massageConfiguration,
      this.modifiedAt});

  factory RatingRequest.fromJson(Map<String, dynamic> json) =>
      _$RatingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RatingRequestToJson(this);

  static RatingRequest _$RatingRequestFromJson(Map<String, dynamic> json) =>
      RatingRequest(
        massageSettingId: json['massageSettingId'] as String,
        userId: json['userId'] as String,
        rating: json['rating'] as double,
        massageConfiguration: json['massageConfiguration'] as String,
        modifiedAt: json['modifiedAt'] as String,
      );

  Map<String, dynamic> _$RatingRequestToJson(RatingRequest instance) =>
      <String, dynamic>{
        'massageSettingId': instance.massageSettingId,
        'userId': instance.userId,
        'rating': instance.rating,
        'massageConfiguration': instance.massageConfiguration,
        'modifiedAt': instance.modifiedAt,
      };
}
