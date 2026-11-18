import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../providers/mock_auth_provider.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _hasSubmitted = false;
  bool _isLoading = false;
  bool _requestWasSimulated = false;
  bool _usePhone = false;
  int _step = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading || _requestWasSimulated) return;
    setState(() => _hasSubmitted = true);
    if (!_formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isLoading = true);
    try {
      await ref.read(mockAuthProvider).requestPasswordReset();
      if (mounted) {
        setState(() {
          if (_usePhone) {
            _step = 1;
          } else {
            _requestWasSimulated = true;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  Widget _buildRequestForm(BuildContext context) => Form(
    key: _formKey,
    autovalidateMode: _hasSubmitted
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
          )
        else
          AuthTextField(
            controller: _phoneController,
            label: 'Numéro de téléphone',
            validator: AuthValidators.validatePhone,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
          ),
        const SizedBox(height: AppSpacing.large),
        AuthPrimaryButton(
          label: _usePhone
              ? 'Envoyer le code'
              : 'Envoyer les instructions',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
      ],
    ),
  );

  Widget _buildCodeStep(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Saisie du code',
          style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppSpacing.small),
      TextField(
        controller: _codeController,
        onChanged: (_) => setState(() {}),
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: const InputDecoration(
          labelText: 'Code reçu',
        ),
      ),
      const SizedBox(height: AppSpacing.medium),
      FilledButton(
        onPressed: _codeController.text.trim().length == 6
            ? () => setState(() => _step = 2)
            : null,
        child: const Text('Continuer'),
      ),
    ],
  );

  Widget _buildNewPasswordStep(BuildContext context) => Form(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PasswordField(
          controller: _passwordController,
          label: 'Nouveau mot de passe',
          validator: AuthValidators.validatePassword,
        ),
        const SizedBox(height: AppSpacing.medium),
        PasswordField(
          controller: _confirmationController,
          label: 'Confirmer le mot de passe',
          validator: (value) =>
              AuthValidators.validatePasswordConfirmation(
                value,
                _passwordController.text,
              ),
        ),
        const SizedBox(height: AppSpacing.medium),
        FilledButton(
          onPressed: () {
            if (_passwordController.text != _confirmationController.text ||
                _passwordController.text.length < 8) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Vérifiez la longueur et la confirmation du mot de passe.',
                  ),
                ),
              );
              return;
            }
            setState(() {
              _requestWasSimulated = true;
              _step = 0;
            });
          },
          child: const Text('Réinitialiser le mot de passe'),
        ),
      ],
    ),
  );

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Mot de passe oublié ?',
                  description:
                      'Indiquez l’adresse e-mail associée à votre compte. '
                      'Cette demande sera simulée localement.',
                ),
                const SizedBox(height: AppSpacing.large),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _requestWasSimulated
                      ? const _ResetConfirmation(
                          key: ValueKey('reset-confirmation'),
                        )
                      : _step == 0
                      ? _buildRequestForm(context)
                      : _step == 1
                      ? _buildCodeStep(context)
                      : _buildNewPasswordStep(context),
                ),
                const AuthDivider(),
                AuthFooter(
                  prompt: 'Vous vous souvenez de votre mot de passe ?',
                  actionLabel: 'Retour à la connexion',
                  onPressed: () => context.go(AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ResetConfirmation extends StatelessWidget {
  const _ResetConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      key: key,
      backgroundColor: colorScheme.secondaryContainer,
      showBorder: false,
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: colorScheme.onSecondaryContainer,
            size: 40,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Demande simulée',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: colorScheme.onSecondaryContainer),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Aucun e-mail n’a été envoyé. La récupération de mot de passe '
            'sera disponible avec le backend.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSecondaryContainer),
          ),
        ],
      ),
    );
  }
}
