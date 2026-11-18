import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../shared/models/course_model.dart';
import '../../../shared/models/enums/course_format.dart';
import '../../../shared/models/learning_domain_model.dart';
import '../data/course_catalog_filters.dart';
import '../data/learning_categories.dart';
import '../providers/learning_providers.dart';
import '../widgets/category_filter.dart';
import '../widgets/course_card.dart';
import '../widgets/course_filter_sheet.dart';
import '../widgets/course_list_item.dart';
import '../widgets/learning_empty_state.dart';
import '../widgets/learning_header.dart';
import '../widgets/learning_search_bar.dart';

class CourseCatalogScreen extends ConsumerStatefulWidget {
  const CourseCatalogScreen({
    super.key,
    this.initialQuery = '',
    this.initialDomainId,
    this.initialCategoryId,
  });

  final String initialQuery;
  final String? initialDomainId;
  final String? initialCategoryId;

  @override
  ConsumerState<CourseCatalogScreen> createState() =>
      _CourseCatalogScreenState();
}

class _CourseCatalogScreenState extends ConsumerState<CourseCatalogScreen> {
  final _scrollController = ScrollController();
  late String _query;
  String? _selectedDomainId;
  String? _selectedCategoryId;
  CourseCatalogFilters _filters = const CourseCatalogFilters();
  _CourseSortOrder _sortOrder = _CourseSortOrder.popular;
  int _visibleCourseCount = 8;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.trim();
    _selectedDomainId = widget.initialDomainId;
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  void didUpdateWidget(covariant CourseCatalogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery ||
        oldWidget.initialDomainId != widget.initialDomainId ||
        oldWidget.initialCategoryId != widget.initialCategoryId) {
      _query = widget.initialQuery.trim();
      _selectedDomainId = widget.initialDomainId;
      _selectedCategoryId = widget.initialCategoryId;
      _filters = const CourseCatalogFilters();
      _sortOrder = _CourseSortOrder.popular;
      _visibleCourseCount = 8;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim();
    final category = learningCategoryById(_selectedCategoryId);
    final courses = query.isEmpty
        ? ref.watch(coursesProvider)
        : ref.watch(courseSearchProvider(query));
    final domains = ref.watch(learningDomainsProvider);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.horizontalMargin,
                AppSpacing.large,
                AppSpacing.horizontalMargin,
                AppSpacing.veryLarge,
              ),
              children: [
                LearningHeader(
                  title: query.isEmpty ? 'Tous les cours' : 'Recherche',
                  description: query.isEmpty
                      ? 'Développez vos compétences, un cours à la fois.'
                      : 'Résultats pour « $query ».',
                  onBack: () => context.go(AppRoutes.learning),
                ),
                const SizedBox(height: AppSpacing.large),
                LearningSearchBar(
                  initialQuery: _query,
                  onChanged: (value) => setState(() {
                    _query = value;
                    _visibleCourseCount = 8;
                  }),
                  onSubmitted: (value) => setState(() {
                    _query = value;
                    _visibleCourseCount = 8;
                  }),
                ),
                const SizedBox(height: AppSpacing.medium),
                _filterControls(context),
                const SizedBox(height: AppSpacing.section),
                SectionTitle(title: 'Catégories'),
                const SizedBox(height: AppSpacing.small),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: learningCategories.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.small),
                    itemBuilder: (context, index) {
                      final item = learningCategories[index];
                      final isSelected = item.isAll
                          ? _selectedCategoryId == null ||
                                learningCategoryById(_selectedCategoryId)
                                        ?.isAll ==
                                    true
                          : item.id == _selectedCategoryId;
                      return ChoiceChip(
                        label: Text(item.name),
                        selected: isSelected,
                        onSelected: (_) => setState(() {
                          _selectedCategoryId = item.isAll ? null : item.id;
                          _visibleCourseCount = 8;
                        }),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                courses.when(
                  data: (items) => Text(
                    '${items.length} cours disponibles',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                if (_selectedCategoryId != null) ...[
                  const SizedBox(height: AppSpacing.small),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Catégorie : ${category?.name ?? 'inconnue'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _selectedCategoryId = null;
                          _visibleCourseCount = 8;
                        }),
                        child: const Text('Effacer'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                SectionTitle(title: 'Domaines'),
                const SizedBox(height: AppSpacing.small),
                domains.when(
                  loading: () => const _CatalogLoading(
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
                courses.when(
                  loading: () => const _CatalogLoading(
                    label: 'Chargement des cours',
                    height: 180,
                  ),
                  error: (_, _) => AppErrorView(
                    message: 'Les cours ne peuvent pas être chargés.',
                    onRetry: () {
                      if (query.isEmpty) {
                        ref.invalidate(coursesProvider);
                      } else {
                        ref.invalidate(courseSearchProvider(query));
                      }
                    },
                  ),
                  data: (items) => domains.when(
                    loading: () => const _CatalogLoading(
                      label: 'Chargement des domaines',
                      height: 120,
                    ),
                    error: (_, _) => AppErrorView(
                      message:
                          'Les domaines des cours ne peuvent pas être chargés.',
                      onRetry: () => ref.invalidate(learningDomainsProvider),
                    ),
                    data: (domainItems) =>
                        _courseResults(context, items, domainItems),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _courseResults(
    BuildContext context,
    List<CourseModel> items,
    List<LearningDomainModel> domains,
  ) {
    final domainNames = {for (final domain in domains) domain.id: domain.name};
    final selectedCategory = learningCategoryById(_selectedCategoryId);
    final results = items
        .where(
          (course) =>
              (_selectedCategoryId == null ||
                  (selectedCategory != null &&
                      (selectedCategory.isAll ||
                          selectedCategory.domainIds.contains(
                            course.domainId,
                          )))) &&
              (_selectedDomainId == null ||
                  course.domainId == _selectedDomainId) &&
              _filters.matches(course),
        )
        .toList();

    results.sort((first, second) {
      final comparison = switch (_sortOrder) {
        _CourseSortOrder.popular => second.enrolledStudents.compareTo(
          first.enrolledStudents,
        ),
        _CourseSortOrder.recent =>
          (second.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(
                first.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
              ),
        _CourseSortOrder.rating => second.rating.compareTo(first.rating),
        _CourseSortOrder.shortest => first.estimatedDuration.compareTo(
          second.estimatedDuration,
        ),
        _CourseSortOrder.longest => second.estimatedDuration.compareTo(
          first.estimatedDuration,
        ),
      };
      return comparison == 0 ? first.title.compareTo(second.title) : comparison;
    });

    if (results.isEmpty) {
      return LearningEmptyState(
        title: _query.isEmpty ? 'Aucun cours disponible' : 'Aucun résultat',
        description: _query.isEmpty
            ? 'Aucun cours ne correspond aux filtres sélectionnés.'
            : 'Essaie un autre mot-clé ou ajuste les filtres.',
      );
    }

    final showFeatured =
        _query.trim().isEmpty &&
        _selectedDomainId == null &&
        _filters.isEmpty &&
        (selectedCategory == null || selectedCategory.isAll);
    CourseModel? featuredCourse;
    if (showFeatured) {
      for (final course in results) {
        if (course.isRecommended) {
          featuredCourse = course;
          break;
        }
      }
    }
    final catalogCourses = featuredCourse == null
        ? results
        : results.where((course) => course.id != featuredCourse!.id).toList();
    final visibleCourses = catalogCourses.take(_visibleCourseCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.medium),
        SectionTitle(
          title: 'Catalogue',
          trailing: PopupMenuButton<_CourseSortOrder>(
            initialValue: _sortOrder,
            tooltip: 'Tri : ${_sortOrder.label}',
            onSelected: (value) => setState(() {
              _sortOrder = value;
              _visibleCourseCount = 8;
            }),
            itemBuilder: (context) => [
              for (final option in _CourseSortOrder.values)
                PopupMenuItem(value: option, child: Text(option.label)),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.small,
                vertical: AppSpacing.small,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort_rounded, size: 18),
                  const SizedBox(width: AppSpacing.verySmall),
                  Text('Trier', style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          '${results.length} cours',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (featuredCourse != null) ...[
          const SizedBox(height: AppSpacing.section),
          const SectionTitle(
            title: 'Cours recommandé',
            subtitle: 'Une sélection pour commencer.',
          ),
          const SizedBox(height: AppSpacing.small),
          SizedBox(
            height: 236,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CourseCard(
                  course: featuredCourse,
                  domainName:
                      domainNames[featuredCourse.domainId] ??
                      featuredCourse.domainId,
                  width: 280,
                  onTap: () => context.push(
                    AppRoutes.courseDetailsPath(featuredCourse!.id),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.medium),
        for (final course in visibleCourses) ...[
          CourseListItem(
            course: course,
            domainName: domainNames[course.domainId] ?? course.domainId,
            onTap: () => context.push(AppRoutes.courseDetailsPath(course.id)),
          ),
          if (course != visibleCourses.last)
            const SizedBox(height: AppSpacing.medium),
        ],
        if (catalogCourses.length > _visibleCourseCount) ...[
          const SizedBox(height: AppSpacing.medium),
          Center(
            child: TextButton(
              onPressed: () => setState(() {
                _visibleCourseCount += 8;
              }),
              child: const Text('Afficher plus de cours'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _filterControls(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Filtres${_filters.activeCount == 0 ? '' : ' (${_filters.activeCount})'}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          OutlinedButton.icon(
            onPressed: _openFilters,
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: const Text('Filtrer'),
          ),
        ],
      ),
      if (!_filters.isEmpty) ...[
        const SizedBox(height: AppSpacing.small),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final label in _filters.labels)
              InputChip(
                label: Text(label),
                onDeleted: () => _removeFilter(label),
              ),
            TextButton(
              onPressed: () => setState(() {
                _filters = const CourseCatalogFilters();
                _visibleCourseCount = 8;
              }),
              child: const Text('Effacer tout'),
            ),
          ],
        ),
      ],
    ],
  );

  Future<void> _openFilters() async {
    final filters = await showModalBottomSheet<CourseCatalogFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.88,
        child: CourseFilterSheet(initialFilters: _filters),
      ),
    );
    if (filters == null || !mounted) return;
    setState(() {
      _filters = filters;
      _visibleCourseCount = 8;
    });
  }

  void _removeFilter(String label) {
    setState(() {
      _filters = CourseCatalogFilters(
        level:
            label == 'Débutant' || label == 'Intermédiaire' || label == 'Avancé'
            ? null
            : _filters.level,
        duration:
            CourseDurationRange.values.any((range) => range.label == label)
            ? null
            : _filters.duration,
        isPremium: label == 'Premium' || label == 'Gratuit'
            ? null
            : _filters.isPremium,
        format: CourseFormat.values.any((format) => format.label == label)
            ? null
            : _filters.format,
      );
      _visibleCourseCount = 8;
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(learningDomainsProvider);
    final query = _query.trim();
    if (query.isEmpty) {
      ref.invalidate(coursesProvider);
      await Future.wait<Object?>([
        ref.read(coursesProvider.future),
        ref.read(learningDomainsProvider.future),
      ]);
    } else {
      ref.invalidate(courseSearchProvider(query));
      await Future.wait<Object?>([
        ref.read(courseSearchProvider(query).future),
        ref.read(learningDomainsProvider.future),
      ]);
    }
  }
}

enum _CourseSortOrder {
  popular('Les plus populaires'),
  recent('Les plus récents'),
  rating('Les mieux notés'),
  shortest('Durée la plus courte'),
  longest('Durée la plus longue');

  const _CourseSortOrder(this.label);

  final String label;
}

class _CatalogLoading extends StatelessWidget {
  const _CatalogLoading({required this.label, required this.height});

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Center(child: CircularProgressIndicator(semanticsLabel: label)),
  );
}
