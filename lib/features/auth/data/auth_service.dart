import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/naru_auth_user.dart';

enum AuthProviderKind { emailPassword, phoneCode, google, facebook }

abstract interface class AuthService {
  Future<NaruAuthUser> signIn({
    required AuthProviderKind provider,
    String? email,
    String? phone,
    String? password,
  });

  Future<NaruAuthUser> register({
    required AuthProviderKind provider,
    required String displayName,
    String? email,
    String? phone,
    String? password,
  });

  Future<void> requestPasswordReset({String? email, String? phone});
  Future<void> signOut();
}

class DemoAuthService implements AuthService {
  const DemoAuthService();

  static const _delay = Duration(milliseconds: 350);

  @override
  Future<NaruAuthUser> signIn({
    required AuthProviderKind provider,
    String? email,
    String? phone,
    String? password,
  }) async {
    await Future<void>.delayed(_delay);
    return NaruAuthUser(
      id: 'demo-user',
      displayName: 'Samira',
      email: email,
      phone: phone,
    );
  }

  @override
  Future<NaruAuthUser> register({
    required AuthProviderKind provider,
    required String displayName,
    String? email,
    String? phone,
    String? password,
  }) async {
    await Future<void>.delayed(_delay);
    return NaruAuthUser(
      id: 'demo-user',
      displayName: displayName,
      email: email,
      phone: phone,
    );
  }

  @override
  Future<void> requestPasswordReset({String? email, String? phone}) =>
      Future<void>.delayed(_delay);

  @override
  Future<void> signOut() async {}
}

final authServiceProvider = Provider<AuthService>(
  (ref) => const DemoAuthService(),
);
