class UpdatePasswordModel {
  final String code;
  final String password;
  final String confirmPassword;

  UpdatePasswordModel({
    required this.code,
    required this.password,
    required this.confirmPassword,
  });

  factory UpdatePasswordModel.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordModel(
      code: json['code'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}
