import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../widgets/continue_learning_section.dart';
import '../../widgets/daily_goal_section.dart';
import '../../widgets/home_header.dart';
import '../../widgets/home_search_bar.dart';
import '../../widgets/learning_domains_section.dart';
import '../../widgets/recent_activity_section.dart';
import '../../widgets/recommended_courses_section.dart';
import '../../widgets/progress_overview.dart';
import '../../widgets/quick_action_grid.dart';
import '../../widgets/dashboard_action_cards.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.horizontalMargin,
            AppSpacing.large,
            AppSpacing.horizontalMargin,
            AppSpacing.veryLarge,
          ),
          children: [
            HomeHeader(
              onNotifications: () => context.push(AppRoutes.notifications),
              onProfile: () => context.go(AppRoutes.profile),
            ),
            const SizedBox(height: AppSpacing.large),
            HomeSearchBar(
              onSearch: (query) => context.push(
                Uri(
                  path: AppRoutes.searchResults,
                  queryParameters: {'query': query},
                ).toString(),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            AppCard(
              onTap: () => context.push(AppRoutes.library),
              child: const Row(
                children: [
                  Icon(Icons.local_library_outlined),
                  SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bibliothèque numérique'),
                        Text('Livres, guides et ressources pour apprendre.'),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            const DailyGoalSection(),
            const SizedBox(height: AppSpacing.section),
            const AiAccessCard(),
            const SizedBox(height: AppSpacing.section),
            const ContinueLearningSection(),
            const SizedBox(height: AppSpacing.section),
            const RecommendedCoursesSection(),
            const SizedBox(height: AppSpacing.section),
            const ProgressOverview(),
            const SizedBox(height: AppSpacing.section),
            const QuickActionGrid(),
            const SizedBox(height: AppSpacing.section),
            const LearningDomainsSection(),
            const SizedBox(height: AppSpacing.section),
            const RecentActivitySection(),
            const SizedBox(height: AppSpacing.section),
            const RecommendedResourcesSection(),
            const SizedBox(height: AppSpacing.section),
            const SubscriptionStatusCard(),
          ],
        ),
      ),
    ),
  );
}
