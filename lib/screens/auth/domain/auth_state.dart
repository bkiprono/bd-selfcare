import 'package:bdoneapp/screens/auth/domain/user_model.dart';

sealed class AuthState {
  const AuthState();

  User get user => throw UnimplementedError();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Authenticated extends AuthState {
  @override
  final User user;
  const Authenticated(this.user);
}
