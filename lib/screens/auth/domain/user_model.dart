import 'package:bdcomputing/models/common/client.dart';
import 'package:bdcomputing/screens/auth/domain/mfa_models.dart';

class User {
  final String id;
  final String email;
  final String name;
  final bool emailVerified;
  final bool magicLogin;
  final String? phone;
  final bool phoneVerified;
  final bool verified;
  final String? customerId;
  final String? clientId;
  final String? profileImage;
  final String? defaultAddress;
  final String? passwordResetCode;
  final bool isActive;
  final bool isPasswordDefault;
  final String? resetPasswordToken;
  final String? roleId;
  final List<NotificationSetting> notifications;
  final DateTime? createdAt;
  final DateTime? lastPasswordChange;
  final String? userId;
  final RoleModel? role;
  final Client? client;
  final String? leadId;
  
  // MFA Fields
  final bool mfaEnabled;
  final List<MfaMethod> mfaMethods;
  final MfaMethod? preferredMfaMethod;
  final bool whatsappVerified;
  final bool googleAuthEnabled;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.emailVerified,
    required this.magicLogin,
    this.phone,
    required this.phoneVerified,
    required this.verified,
    this.customerId,
    this.clientId,
    this.profileImage,
    this.defaultAddress,
    this.passwordResetCode,
    required this.isActive,
    required this.isPasswordDefault,
    this.resetPasswordToken,
    this.roleId,
    required this.notifications,
    this.createdAt,
    this.lastPasswordChange,
    this.userId,
    this.role,
    this.client,
    this.leadId,
    required this.mfaEnabled,
    required this.mfaMethods,
    this.preferredMfaMethod,
    required this.whatsappVerified,
    required this.googleAuthEnabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['_id'] ?? json['id'] ?? json['userId'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      emailVerified: json['emailVerified'] ?? false,
      magicLogin: json['magicLogin'] ?? false,
      phone: json['phone']?.toString(),
      phoneVerified: json['phoneVerified'] ?? false,
      verified: json['verified'] ?? false,
      customerId: json['customerId']?.toString(),
      clientId: json['clientId']?.toString(),
      profileImage: json['profileImage']?.toString(),
      defaultAddress: json['defaultAddress']?.toString(),
      passwordResetCode: json['passwordResetCode']?.toString(),
      isActive: json['isActive'] ?? false,
      isPasswordDefault: json['isPasswordDefault'] ?? false,
      resetPasswordToken: json['resetPasswordToken']?.toString(),
      roleId: json['roleId']?.toString(),
      notifications: (json['notifications'] as List<dynamic>? ?? [])
          .map((n) => NotificationSetting.fromJson(n as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      lastPasswordChange: json['lastPasswordChange'] != null ? DateTime.tryParse(json['lastPasswordChange']) : null,
      userId: json['userId']?.toString(),
      role: json['role'] != null ? RoleModel.fromJson(json['role'] as Map<String, dynamic>) : null,
      client: json['client'] != null
          ? Client.fromJson(json['client'] as Map<String, dynamic>)
          : null,
      leadId: json['leadId']?.toString(),
      mfaEnabled: json['mfaEnabled'] ?? false,
      mfaMethods: (json['mfaMethods'] as List<dynamic>? ?? [])
          .map((m) => MfaMethod.fromString(m.toString()))
          .toList(),
      preferredMfaMethod: json['preferredMfaMethod'] != null 
          ? MfaMethod.fromString(json['preferredMfaMethod'].toString()) 
          : null,
      whatsappVerified: json['whatsappVerified'] ?? false,
      googleAuthEnabled: json['googleAuthEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        '_id': id,
        'email': email,
        'name': name,
        'emailVerified': emailVerified,
        'magicLogin': magicLogin,
        'phone': phone,
        'phoneVerified': phoneVerified,
        'verified': verified,
        'customerId': customerId,
        'clientId': clientId,
        'profileImage': profileImage,
        'defaultAddress': defaultAddress,
        'passwordResetCode': passwordResetCode,
        'isActive': isActive,
        'isPasswordDefault': isPasswordDefault,
        'resetPasswordToken': resetPasswordToken,
        'roleId': roleId,
        'notifications': notifications.map((n) => n.toJson()).toList(),
        'createdAt': createdAt?.toIso8601String(),
        'lastPasswordChange': lastPasswordChange?.toIso8601String(),
        'userId': userId,
        'role': role?.toJson(),
        'client': client?.toJson(),
        'leadId': leadId,
        'mfaEnabled': mfaEnabled,
        'mfaMethods': mfaMethods.map((m) => m.name.toUpperCase()).toList(),
        'preferredMfaMethod': preferredMfaMethod?.name.toUpperCase(),
        'whatsappVerified': whatsappVerified,
        'googleAuthEnabled': googleAuthEnabled,
      };

}

class NotificationSetting {
  final String notification;
  final NotificationChannels channels;

  NotificationSetting({
    required this.notification,
    required this.channels,
  });

  factory NotificationSetting.fromJson(Map<String, dynamic> json) {
    return NotificationSetting(
      notification: json['notification'] ?? '',
      channels: NotificationChannels.fromJson(json['channels'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'notification': notification,
        'channels': channels.toJson(),
      };
}

class NotificationChannels {
  final bool sms;
  final bool email;
  final bool whatsapp;

  NotificationChannels({
    required this.sms,
    required this.email,
    required this.whatsapp,
  });

  factory NotificationChannels.fromJson(Map<String, dynamic> json) {
    return NotificationChannels(
      sms: json['sms'] ?? false,
      email: json['email'] ?? false,
      whatsapp: json['whatsapp'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'sms': sms,
        'email': email,
        'whatsapp': whatsapp,
      };
}

class RoleModel {
  final String id;
  final String role;
  final List<String> permissions;
  final bool isActive;
  final String? createdBy;
  final DateTime? createdAt;
  final int? v;
  final DateTime? updatedAt;

  RoleModel({
    required this.id,
    required this.role,
    required this.permissions,
    required this.isActive,
    this.createdBy,
    this.createdAt,
    this.v,
    this.updatedAt,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      role: json['role'] ?? '',
      permissions: (json['permissions'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      isActive: json['isActive'] ?? false,
      createdBy: json['createdBy']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      v: json['__v'] is int ? json['__v'] : int.tryParse(json['__v']?.toString() ?? ''),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'role': role,
        'permissions': permissions,
        'isActive': isActive,
        'createdBy': createdBy,
        'createdAt': createdAt?.toIso8601String(),
        '__v': v,
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
