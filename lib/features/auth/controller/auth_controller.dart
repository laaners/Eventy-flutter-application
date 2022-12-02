import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_tutorial/features/auth/repository/auth_repository.dart';

// Provider, so that we don't have to create a new class AuthController every time we want to sign in
final authControllerProvider = Provider(
  (ref) => ref.read(authRepositoryProvider),
);

class AuthController {
  final AuthRepository _authRepository;
  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  void signInWithGoogle() {
    _authRepository.signInWithGoogle();
  }
}
