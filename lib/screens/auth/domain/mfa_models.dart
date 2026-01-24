enum MfaMethod {
  email,
  whatsapp,
  totp;

  String get displayName {
    switch (this) {
      case MfaMethod.email:
        return 'Email';
      case MfaMethod.whatsapp:
        return 'WhatsApp';
      case MfaMethod.totp:
        return 'Authenticator App';
    }
  }

  static MfaMethod fromString(String value) {
    switch (value.toUpperCase()) {
      case 'EMAIL':
        return MfaMethod.email;
      case 'WHATSAPP':
        return MfaMethod.whatsapp;
      case 'TOTP':
        return MfaMethod.totp;
      default:
        return MfaMethod.email;
    }
  }
}

sealed class LoginResult {
  const LoginResult();
}

class LoginSuccess extends LoginResult {
  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> user;

  const LoginSuccess({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}

class MfaRequired extends LoginResult {
  final String mfaToken;
  final List<MfaMethod> mfaMethods;

  const MfaRequired({
    required this.mfaToken,
    required this.mfaMethods,
  });
}

class LoginAccepted extends LoginResult {
  final String tempToken;
  final String email;

  const LoginAccepted({
    required this.tempToken,
    required this.email,
  });
}
