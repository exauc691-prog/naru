import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../app/router/app_routes.dart';
import '../../data/onboarding_content.dart';
import '../../widgets/onboarding_indicator.dart';
import '../../widgets/onboarding_navigation.dart';
import '../../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  bool get _isLastPage => _currentIndex == onboardingContent.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: AppSpacing.small,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Text('naru', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  Text(
                    '${_currentIndex + 1} / ${onboardingContent.length}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingContent.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, index) =>
                      OnboardingPage(content: onboardingContent[index]),
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              OnboardingIndicator(
                count: onboardingContent.length,
                currentIndex: _currentIndex,
              ),
              const SizedBox(height: AppSpacing.small),
              OnboardingNavigation(
                isFirstPage: _currentIndex == 0,
                isLastPage: _isLastPage,
                onPrevious: () => _goToPage(_currentIndex - 1),
                onNext: () => _goToPage(_currentIndex + 1),
                onSkip: () => context.push(AppRoutes.register),
                onComplete: () => context.push(AppRoutes.register),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
