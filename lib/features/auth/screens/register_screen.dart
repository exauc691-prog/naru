import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/providers/subscription_providers.dart';
import '../../subscription/widgets/subscription_plan_selector.dart';
import '../providers/mock_auth_provider.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _hasSubmitted = false;
  bool _isLoading = false;
  bool _usePhone = false;
  String _countryCode = '+243';
  final _phoneController = TextEditingController();
  SubscriptionPlan _selectedPlan = SubscriptionPlan.free;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
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
      await ref.read(subscriptionPlanProvider.future);
      await ref
          .read(subscriptionPlanProvider.notifier)
          .selectPlan(_selectedPlan);
      await ref.read(mockAuthProvider).register();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de créer le compte : $error')),
        );
      }
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
              '$provider est préparé pour une future connexion OAuth. '
              'Cette étape est une simulation locale.',
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
                    title: 'Créer votre compte',
                    description:
                        'Bienvenue chez Naru. Commencez à apprendre à votre '
                        'rythme, dès aujourd’hui.',
                  ),
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    'Comment souhaitez-vous créer votre compte ?',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.small),
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
                  AuthTextField(
                    controller: _nameController,
                    label: 'Nom complet',
                    validator: AuthValidators.validateName,
                    prefixIcon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 112,
                          child: DropdownButtonFormField<String>(
                            initialValue: _countryCode,
                            items: const [
                              DropdownMenuItem(value: '+243', child: Text('RDC +243')),
                              DropdownMenuItem(value: '+33', child: Text('FR +33')),
                              DropdownMenuItem(value: '+32', child: Text('BE +32')),
                              DropdownMenuItem(value: '+1', child: Text('CA/US +1')),
                            ],
                            onChanged: _isLoading
                                ? null
                                : (value) => setState(
                                      () => _countryCode = value ?? '+243',
                                    ),
                            decoration: const InputDecoration(
                              labelText: 'Pays',
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: AuthTextField(
                            controller: _phoneController,
                            label: 'Numéro de téléphone',
                            validator: AuthValidators.validatePhone,
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            enabled: !_isLoading,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: AppSpacing.medium),
                  PasswordField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    validator: AuthValidators.validatePassword,
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
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
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  SubscriptionPlanSelector(
                    selectedPlan: _selectedPlan,
                    onSelected: (plan) => setState(() => _selectedPlan = plan),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  FormField<bool>(
                    autovalidateMode: _hasSubmitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    validator: (value) => value == true
                        ? null
                        : 'Veuillez accepter les conditions d’utilisation.',
                    builder: (field) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          value: field.value ?? false,
                          onChanged: _isLoading ? null : field.didChange,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text(
                            'J’accepte les conditions d’utilisation.',
                          ),
                        ),
                        if (field.errorText != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: AppSpacing.medium,
                              bottom: AppSpacing.small,
                            ),
                            child: Text(
                              field.errorText!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  AuthPrimaryButton(
                    label: 'Créer mon compte',
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
                    prompt: 'Vous avez déjà un compte ?',
                    actionLabel: 'Se connecter',
                    onPressed: () => context.go(AppRoutes.login),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    'Inscription simulée : aucune donnée de compte ni aucun '
                    'mot de passe ne sont conservés.',
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
