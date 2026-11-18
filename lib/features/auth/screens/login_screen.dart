import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/mock_auth_provider.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hasSubmitted = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _usePhone = false;
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    setState(() => _hasSubmitted = true);
    if (!_formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isLoading = true);
    try {
      await ref.read(mockAuthProvider).signIn();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueWith(String provider) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(mockAuthProvider).signIn();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$provider est préparé pour une future connexion OAuth.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Retour',
        onPressed: _goBack,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      scrolledUnderElevation: 0,
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.small,
              AppSpacing.large,
              AppSpacing.large,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: _hasSubmitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Bon retour parmi nous',
                    description:
                        'Connectez-vous pour reprendre votre apprentissage '
                        'là où vous l’avez laissé.',
                  ),
                  const SizedBox(height: AppSpacing.large),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('E-mail')),
                      ButtonSegment(value: true, label: Text('Téléphone')),
                    ],
                    selected: {_usePhone},
                    onSelectionChanged: (values) =>
                        setState(() => _usePhone = values.first),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  if (!_usePhone)
                    AuthTextField(
                      controller: _emailController,
                      label: 'Adresse e-mail',
                      validator: AuthValidators.validateEmail,
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !_isLoading,
                    )
                  else
                    AuthTextField(
                      controller: _phoneController,
                      label: 'Numéro de téléphone',
                      validator: AuthValidators.validatePhone,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      enabled: !_isLoading,
                    ),
                  const SizedBox(height: AppSpacing.medium),
                  PasswordField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    validator: AuthValidators.validateRequiredPassword,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CheckboxListTile(
                        value: _rememberMe,
                        onChanged: _isLoading
                            ? null
                            : (value) =>
                                  setState(() => _rememberMe = value ?? false),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Se souvenir de moi'),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => context.go(AppRoutes.forgotPassword),
                          child: const Text('Mot de passe oublié ?'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  AuthPrimaryButton(
                    label: 'Se connecter',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                  const AuthDivider(),
                  OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _continueWith('Google'),
                    icon: const Icon(Icons.g_mobiledata_rounded),
                    label: const Text('Continuer avec Google'),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _continueWith('Facebook'),
                    icon: const Icon(Icons.facebook_rounded),
                    label: const Text('Continuer avec Facebook'),
                  ),
                  AuthFooter(
                    prompt: 'Nouveau sur Naru ?',
                    actionLabel: 'Créer un compte',
                    onPressed: () => context.go(AppRoutes.register),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    'Connexion simulée : vos identifiants ne sont pas '
                    'conservés.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
