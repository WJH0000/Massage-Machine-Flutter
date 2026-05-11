import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class SocialAccountLoginRequest {
  final String? firstName;
  final String? lastName;
  final String? userName;
  final String? email;
  final String? socialAccountToken;
  final String? socialAccountId;
  final String? registerType;
  final String? base64ProfileImage;

  SocialAccountLoginRequest(
      {this.firstName,
      this.lastName,
      this.userName,
      this.email,
      this.socialAccountToken,
      this.socialAccountId,
      this.registerType,
      this.base64ProfileImage});

  factory SocialAccountLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$PersonFromJson(json);
  Map<String, dynamic> toJson() => _$PersonToJson(this);

  static SocialAccountLoginRequest _$PersonFromJson(
          Map<String, dynamic> json) =>
      SocialAccountLoginRequest(
          firstName: json['firstName'] as String,
          lastName: json['lastName'] as String,
          userName: json['userName'] as String,
          email: json['email'] as String,
          socialAccountToken: json['socialAccountToken'] as String,
          socialAccountId: json['socialAccountId'] as String,
          registerType: json['registerType'] as String,
          base64ProfileImage: json['base64ProfileImage'] as String);

  Map<String, dynamic> _$PersonToJson(SocialAccountLoginRequest instance) =>
      <String, dynamic>{
        'firstName': instance.firstName,
        'lastName': instance.lastName,
        'userName': instance.userName,
        'email': instance.email,
        'socialAccountToken': instance.socialAccountToken,
        'socialAccountId': instance.socialAccountId,
        'registerType': instance.registerType,
        'base64ProfileImage': instance.base64ProfileImage
      };
}
