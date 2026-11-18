import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../models/assessment_models.dart';

class CompetencyScreen extends StatelessWidget {
  const CompetencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const competencies = [
      CompetencyProgress(
        id: 'dart',
        name: 'Dart',
        category: 'Programmation',
        progress: 80,
      ),
      CompetencyProgress(
        id: 'functions',
        name: 'Fonctions',
        category: 'Programmation',
        progress: 60,
      ),
      CompetencyProgress(
        id: 'oop',
        name: 'Programmation orientée objet',
        category: 'Programmation',
        progress: 40,
      ),
      CompetencyProgress(
        id: 'async',
        name: 'Asynchronisme',
        category: 'Programmation',
        progress: 20,
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Mes compétences')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding:
                  const EdgeInsets.all(AppSpacing.horizontalMargin),
              children: [
                for (final competency in competencies)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.small,
                    ),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  competency.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                              ),
                              Text('${competency.progress} %'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.small),
                          AppProgressBar(
                            value: competency.progress / 100,
                            semanticsLabel:
                                'Progression de ${competency.name}',
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            competency.category,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
