import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

final String userTable = 'user';

class UserFields {
  static final List<String> values = [
    /// Add all fields
    userId, firstName, lastName, userName, email, role, registerType,
    profileImagePath, profileImageSource, modifiedAt, token
  ];

  static final String userId = 'userId';
  static final String firstName = 'firstName';
  static final String lastName = 'lastName';
  static final String userName = 'userName';
  static final String email = 'email';
  static final String role = 'role';
  static final String registerType = 'registerType';
  static final String profileImagePath = 'profileImagePath';
  static final String profileImageSource = 'profileImageSource';
  static final String modifiedAt = 'modifiedAt';
  static final String token = 'token';
}

@JsonSerializable()
class User {
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? userName;
  final String? email;
  final String? role;
  final String? registerType;
  final String? profileImagePath;
  Uint8List? profileImageSource;
  final String? modifiedAt;
  final String? token;

  User(
      {this.userId,
      this.firstName,
      this.lastName,
      this.userName,
      this.email,
      this.role,
      this.registerType,
      this.profileImagePath,
      this.profileImageSource,
      this.modifiedAt,
      this.token});

  User copy({
    String? userId,
    String? firstName,
    String? lastName,
    String? userName,
    String? email,
    String? role,
    String? registerType,
    String? profileImagePath,
    Uint8List? profileImageSource,
    String? modifiedAt,
    String? token,
  }) =>
      User(
        userId: userId ?? this.userId,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        userName: userName ?? this.userName,
        email: email ?? this.email,
        role: role ?? this.role,
        registerType: registerType ?? this.registerType,
        profileImagePath: profileImagePath ?? this.profileImagePath,
        profileImageSource: profileImageSource ?? this.profileImageSource,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        token: token ?? this.token,
      );

  set setProfileImageSource(Uint8List profileImageSource) {
    this.profileImageSource = profileImageSource;
  }

  //Convert json to user object
  factory User.fromJson(Map<String, dynamic> json, String token) =>
      _$UserFromJson(json, token);
  //Convert user object to json
  Map<String, dynamic> toJson() => _$UserToJson(this);

  static User _$UserFromJson(Map<String, dynamic> json, String token) => User(
      userId: json['userId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      userName: json['userName'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      registerType: json['registerType'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
      profileImageSource: json['profileImageSource'] as Uint8List?,
      modifiedAt: json['modifiedAt'] as String?,
      token: token
      // isActive: json['isActive'] as bool,
      // isDeleted: json['isDeleted'] as bool,
      );

  Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
        'userId': instance.userId,
        'firstName': instance.firstName,
        'lastName': instance.lastName,
        'userName': instance.userName,
        'email': instance.email,
        'role': instance.role,
        'registerType': instance.registerType,
        'profileImagePath': instance.profileImagePath,
        'profileImageSource': instance.profileImageSource,
        'modifiedAt': instance.modifiedAt,
        'token': instance.token
        // 'isActive': instance.isActive,
        // 'isDeleted': instance.isDeleted,
      };
}
