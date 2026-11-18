import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DemoAuthStatus {
  signedOut,
  registering,
  signedIn,
  configuring,
  sessionExpired,
}

class DemoAuthState {
  const DemoAuthState(this.status);

  const DemoAuthState.signedOut() : status = DemoAuthStatus.signedOut;

  const DemoAuthState.signedIn() : status = DemoAuthStatus.signedIn;

  const DemoAuthState.registering() : status = DemoAuthStatus.registering;

  const DemoAuthState.configuring() : status = DemoAuthStatus.configuring;

  const DemoAuthState.sessionExpired() : status = DemoAuthStatus.sessionExpired;

  final DemoAuthStatus status;

  bool get isAuthenticated =>
      status == DemoAuthStatus.signedIn ||
      status == DemoAuthStatus.configuring;
}

final authStateProvider = NotifierProvider<DemoAuthController, DemoAuthState>(
  DemoAuthController.new,
);

class DemoAuthController extends Notifier<DemoAuthState> {
  @override
  DemoAuthState build() => const DemoAuthState.signedOut();

  void signInDemo() {
    state = const DemoAuthState.signedIn();
  }

  void registerDemo() {
    state = const DemoAuthState.signedIn();
  }

  void beginRegistration() {
    state = const DemoAuthState.registering();
  }

  void beginProfileConfiguration() {
    state = const DemoAuthState.configuring();
  }

  void signOut() {
    state = const DemoAuthState.signedOut();
  }
}
