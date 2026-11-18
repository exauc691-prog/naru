import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';

class AuthProfileSetupScreen extends StatefulWidget {
  const AuthProfileSetupScreen({super.key});

  @override
  State<AuthProfileSetupScreen> createState() =>
      _AuthProfileSetupScreenState();
}

class _AuthProfileSetupScreenState extends State<AuthProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _goals = <String>{};
  final _domains = <String>{};
  String _level = 'Débutant';
  int _minutes = 30;

  static const _goalOptions = [
    'Réussir mes études',
    'Apprendre à programmer',
    'Développer mes compétences',
    'Apprendre l’intelligence artificielle',
    'Lire davantage',
    'Préparer un examen',
    'Développer un projet',
  ];

  static const _domainOptions = [
    'Études',
    'Programmation',
    'Mathématiques',
    'Langues',
    'Intelligence artificielle',
    'Livres',
    'Entrepreneuriat',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Votre profil')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              Text(
                'Personnalisez votre expérience',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.large),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d’affichage',
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              Text('Vos objectifs',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  for (final goal in _goalOptions)
                    FilterChip(
                      label: Text(goal),
                      selected: _goals.contains(goal),
                      onSelected: (value) => setState(() {
                        value ? _goals.add(goal) : _goals.remove(goal);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.large),
              Text('Domaines d’intérêt',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  for (final domain in _domainOptions)
                    FilterChip(
                      label: Text(domain),
                      selected: _domains.contains(domain),
                      onSelected: (value) => setState(() {
                        value ? _domains.add(domain) : _domains.remove(domain);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.large),
              Text('Niveau général',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.small),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Débutant', label: Text('Débutant')),
                  ButtonSegment(
                    value: 'Intermédiaire',
                    label: Text('Intermédiaire'),
                  ),
                  ButtonSegment(value: 'Avancé', label: Text('Avancé')),
                ],
                selected: {_level},
                onSelectionChanged: (values) =>
                    setState(() => _level = values.first),
              ),
              const SizedBox(height: AppSpacing.large),
              Text('Temps d’apprentissage',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.small),
              DropdownButtonFormField<int>(
                initialValue: _minutes,
                items: const [
                  DropdownMenuItem(value: 15, child: Text('15 min/jour')),
                  DropdownMenuItem(value: 30, child: Text('30 min/jour')),
                  DropdownMenuItem(value: 60, child: Text('1 h/jour')),
                  DropdownMenuItem(value: 90, child: Text('Plus d’une heure')),
                ],
                onChanged: (value) =>
                    setState(() => _minutes = value ?? 30),
              ),
              const SizedBox(height: AppSpacing.large),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Commencer'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
