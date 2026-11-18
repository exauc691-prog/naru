import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';

class AuthVerificationScreen extends StatefulWidget {
  const AuthVerificationScreen({super.key, this.byPhone = false});

  final bool byPhone;

  @override
  State<AuthVerificationScreen> createState() =>
      _AuthVerificationScreenState();
}

class _AuthVerificationScreenState extends State<AuthVerificationScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Vérification')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.byPhone
                      ? 'Vérifiez votre numéro'
                      : 'Vérifiez votre adresse e-mail',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.small),
                const Text(
                  'Saisissez le code de démonstration à six chiffres. '
                  'Aucun SMS ni e-mail n’est envoyé.',
                ),
                const SizedBox(height: AppSpacing.large),
                TextField(
                  controller: _codeController,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Code de vérification',
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _codeController.text.trim().length == 6
                      ? () => context.go(AppRoutes.authPlan)
                      : null,
                  child: const Text('Valider'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
