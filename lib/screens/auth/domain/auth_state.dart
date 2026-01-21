import 'package:bdcomputing/screens/auth/domain/user_model.dart';

sealed class AuthState {
  const AuthState();

  get user => null;
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}
