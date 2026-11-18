abstract final class AuthValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Saisissez votre nom complet.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Saisissez votre adresse e-mail.';
    }
    if (!RegExp(
      r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
      caseSensitive: false,
    ).hasMatch(email)) {
      return 'Saisissez une adresse e-mail valide.';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return 'Saisissez votre numéro de téléphone.';
    }
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^[0-9]{7,15}$').hasMatch(digits)) {
      return 'Vérifiez votre numéro de téléphone.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Saisissez un mot de passe.';
    }
    if (value.length < 8) {
      return 'Utilisez au moins 8 caractères.';
    }
    return null;
  }

  static String? validateRequiredPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Saisissez votre mot de passe.';
    }
    return null;
  }

  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirmez votre mot de passe.';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }
}
