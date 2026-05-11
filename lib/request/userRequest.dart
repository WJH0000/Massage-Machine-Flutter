import 'package:json_annotation/json_annotation.dart';

class UserRequestFields {
  static final List<String> values = [
    /// Add all fields
    userId, firstName, lastName, userName, email, previousPassword, password,
    reEnterPassword, role, registerType, profileImage, modifiedAt
  ];

  static final String userId = 'userId';
  static final String firstName = 'firstName';
  static final String lastName = 'lastName';
  static final String userName = 'userName';
  static final String email = 'email';
  static final String previousPassword = 'previousPassword';
  static final String password = 'password';
  static final String reEnterPassword = 'reEnterPassword';
  static final String role = 'role';
  static final String registerType = 'registerType';
  static final String profileImage = 'profileImage';
  static final String modifiedAt = 'modifiedAt';
}

@JsonSerializable()
class UserRequest {
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? userName;
  final String? email;
  final String? previousPassword;
  final String? password;
  final String? reEnterPassword;
  final String? role;
  final String? registerType;
  final String? modifiedAt;

  UserRequest({
    this.userId,
    this.firstName,
    this.lastName,
    this.userName,
    this.email,
    this.previousPassword,
    this.password,
    this.reEnterPassword,
    this.role,
    this.registerType,
    this.modifiedAt,
  });

  factory UserRequest.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  static UserRequest _$UserFromJson(Map<String, dynamic> json) => UserRequest(
        userId: json['userId'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        userName: json['userName'] as String,
        email: json['email'] as String,
        previousPassword: json['previousPassword'] as String,
        password: json['password'] as String,
        reEnterPassword: json['reEnterPassword'] as String,
        role: json['role'] as String,
        registerType: json['registerType'] as String,
        modifiedAt: json['modifiedAt'] as String,
        // isActive: json['isActive'] as bool,
        // isDeleted: json['isDeleted'] as bool,
      );

  Map<String, dynamic> _$UserToJson(UserRequest instance) => <String, dynamic>{
        'userId': instance.userId,
        'firstName': instance.firstName,
        'lastName': instance.lastName,
        'userName': instance.userName,
        'email': instance.email,
        'previousPassword': instance.previousPassword,
        'password': instance.password,
        'reEnterPassword': instance.reEnterPassword,
        'role': instance.role,
        'registerType': instance.registerType,
        'modifiedAt': instance.modifiedAt,
        // 'isActive': instance.isActive,
        // 'isDeleted': instance.isDeleted,
      };
}
