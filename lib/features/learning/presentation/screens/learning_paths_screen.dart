import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../shared/models/learning_domain_model.dart';
import '../../../../shared/models/learning_path_model.dart';
import '../../providers/learning_providers.dart';
import '../../widgets/category_filter.dart';
import '../../widgets/learning_empty_state.dart';
import '../../widgets/learning_header.dart';
import '../../widgets/learning_path_card.dart';

class LearningPathsScreen extends ConsumerStatefulWidget {
  const LearningPathsScreen({super.key});

  @override
  ConsumerState<LearningPathsScreen> createState() =>
      _LearningPathsScreenState();
}

class _LearningPathsScreenState extends ConsumerState<LearningPathsScreen> {
  String? _selectedDomainId;

  @override
  Widget build(BuildContext context) {
    final paths = ref.watch(learningPathsProvider);
    final domains = ref.watch(learningDomainsProvider);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.horizontalMargin,
                AppSpacing.large,
                AppSpacing.horizontalMargin,
                AppSpacing.veryLarge,
              ),
              children: [
                LearningHeader(
                  title: 'Parcours guidés',
                  description: 'Un chemin structuré, des bases aux compétences avancées.',
                  onBack: () => context.go(AppRoutes.learning),
                ),
                const SizedBox(height: AppSpacing.large),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.push(AppRoutes.goalSetup),
                        icon: const Icon(Icons.flag_outlined),
                        label: const Text('Créer un objectif'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    OutlinedButton(
                      onPressed: () => context.push(AppRoutes.studyPlan),
                      child: const Text('Mon plan'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),
                const SectionTitle(title: 'Filtrer par domaine'),
                const SizedBox(height: AppSpacing.small),
                domains.when(
                  loading: () => const _PathsLoading(
                    label: 'Chargement des domaines',
                    height: 52,
                  ),
                  error: (_, _) => AppErrorView(
                    message: 'Les domaines ne peuvent pas être chargés.',
                    onRetry: () => ref.invalidate(learningDomainsProvider),
                  ),
                  data: (items) => CategoryFilter(
                    domains: items,
                    selectedDomainId: _selectedDomainId,
                    onSelected: (domainId) =>
                        setState(() => _selectedDomainId = domainId),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                _pathList(context, ref, paths, domains),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pathList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LearningPathModel>> paths,
    AsyncValue<List<LearningDomainModel>> domains,
  ) => paths.when(
    loading: () =>
        const _PathsLoading(label: 'Chargement des parcours', height: 180),
    error: (_, _) => AppErrorView(
      message: 'Les parcours ne peuvent pas être chargés.',
      onRetry: () => ref.invalidate(learningPathsProvider),
    ),
    data: (items) => domains.when(
      loading: () =>
          const _PathsLoading(label: 'Chargement des domaines', height: 180),
      error: (_, _) => AppErrorView(
        message: 'Les domaines des parcours ne peuvent pas être chargés.',
        onRetry: () => ref.invalidate(learningDomainsProvider),
      ),
      data: (domainItems) {
        final filteredPaths = items
            .where(
              (path) =>
                  _selectedDomainId == null ||
                  path.domainId == _selectedDomainId,
            )
            .toList();
        if (filteredPaths.isEmpty) {
          return LearningEmptyState(
            title: _selectedDomainId == null
                ? 'Aucun parcours disponible'
                : 'Aucun parcours pour ce domaine',
            description: 'Essaie un autre domaine.',
            icon: Icons.route_outlined,
          );
        }

        final domainNames = {
          for (final domain in domainItems) domain.id: domain.name,
        };
        return Column(
          children: [
            for (final path in filteredPaths) ...[
              LearningPathCard(
                path: path,
                domainName: domainNames[path.domainId] ?? path.domainId,
                onTap: () =>
                    context.push(AppRoutes.learningPathDetailsPath(path.id)),
              ),
              if (path != filteredPaths.last)
                const SizedBox(height: AppSpacing.medium),
            ],
          ],
        );
      },
    ),
  );

  Future<void> _refresh() async {
    ref.invalidate(learningPathsProvider);
    ref.invalidate(learningDomainsProvider);
    await Future.wait<Object?>([
      ref.read(learningPathsProvider.future),
      ref.read(learningDomainsProvider.future),
    ]);
  }
}

class _PathsLoading extends StatelessWidget {
  const _PathsLoading({required this.label, required this.height});

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Center(child: CircularProgressIndicator(semanticsLabel: label)),
  );
}
