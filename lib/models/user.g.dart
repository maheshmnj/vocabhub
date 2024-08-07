// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      idToken: json['idToken'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      accessToken: json['accessToken'] as String?,
      token: json['token'] as String? ?? '',
      username: json['username'] as String? ?? '',
      created_at: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      updated_at: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
      isDeleted: json['deleted'] as bool? ?? false,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'email': instance.email,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'isLoggedIn': instance.isLoggedIn,
      'isAdmin': instance.isAdmin,
      'username': instance.username,
      'token': instance.token,
      'deleted': instance.isDeleted,
      'created_at': instance.created_at?.toIso8601String(),
      'updated_at': instance.updated_at?.toIso8601String(),
      'idToken': instance.idToken,
      'accessToken': instance.accessToken,
    };
