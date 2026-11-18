import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/auth_provider.dart';

final mockAuthProvider = Provider<MockAuthActions>(
  (ref) => MockAuthActions(ref.read(authStateProvider.notifier)),
);

class MockAuthActions {
  const MockAuthActions(this._demoAuthController);

  static const _responseDelay = Duration(milliseconds: 350);

  final DemoAuthController _demoAuthController;

  Future<void> register() async {
    await Future<void>.delayed(_responseDelay);
    _demoAuthController.registerDemo();
  }

  Future<void> signIn() async {
    await Future<void>.delayed(_responseDelay);
    _demoAuthController.signInDemo();
  }

  Future<void> requestPasswordReset() => Future<void>.delayed(_responseDelay);
}
