import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _name = TextEditingController(text: 'Samira Naru');
  final _email = TextEditingController(text: 'samira@naru.app');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Modifier le profil')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 560),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  children: [
                    const CircleAvatar(
                      radius: 44,
                      child: Icon(Icons.person_rounded, size: 44),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      TextField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Nom d’affichage'),
                          ),
                          const SizedBox(
                            height: AppSpacing.medium),
                            TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Adresse e-mail'),
                                ),
                                const SizedBox(
                                  height: AppSpacing.large),
                                  FilledButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Profil enregistré localement.'),),
                                       );
                                    },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
