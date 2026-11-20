import 'package:flutter_test/flutter_test.dart';
import 'package:naru/features/auth/validators/auth_validators.dart';

void main() {
  test('name and email validators reject empty or malformed values', () {
    expect(AuthValidators.validateName('  '), isNotNull);
    expect(AuthValidators.validateName('Samira Naru'), isNull);
    expect(AuthValidators.validateEmail(''), isNotNull);
    expect(AuthValidators.validateEmail('not-an-email'), isNotNull);
    expect(AuthValidators.validateEmail('samira@naru.app'), isNull);
  });

  test('password validators enforce the registration rules', () {
    expect(AuthValidators.validatePassword(''), isNotNull);
    expect(AuthValidators.validatePassword('short'), isNotNull);
    expect(AuthValidators.validatePassword('long-enough'), isNull);
    expect(AuthValidators.validateRequiredPassword(''), isNotNull);
    expect(AuthValidators.validateRequiredPassword('x'), isNull);
    expect(
      AuthValidators.validatePasswordConfirmation('different', 'password'),
      isNotNull,
    );
    expect(
      AuthValidators.validatePasswordConfirmation('password', 'password'),
      isNull,
    );
  });
}
