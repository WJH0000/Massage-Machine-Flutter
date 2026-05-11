import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class LoginRequest {
  final String? username;
  final String? password;
  final String? loginPlatform;

  LoginRequest({this.username, this.password, this.loginPlatform});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$PersonFromJson(json);
  Map<String, dynamic> toJson() => _$PersonToJson(this);

  static LoginRequest _$PersonFromJson(Map<String, dynamic> json) =>
      LoginRequest(
        username: json['username'] as String,
        password: json['password'] as String,
        loginPlatform: json['loginPlatform'] as String,
      );

  Map<String, dynamic> _$PersonToJson(LoginRequest instance) =>
      <String, dynamic>{
        'username': instance.username,
        'password': instance.password,
        'loginPlatform': instance.loginPlatform,
      };
}
