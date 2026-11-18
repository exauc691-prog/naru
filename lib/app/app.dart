import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/theme_provider.dart';
import 'router/app_router.dart';
import 'app_theme.dart';

class NaruApp extends ConsumerWidget {
  const NaruApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(themeModeProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'loading the saved Naru appearance preference',
            ),
          );
        },
      );
    });

    final themeMode = ref
        .watch(themeModeProvider)
        .when(
          data: (mode) => mode,
          loading: () => ThemeMode.system,
          error: (error, stackTrace) => ThemeMode.system,
        );

    final initialHome = home;
    if (initialHome != null) {
      return MaterialApp(
        title: 'Naru',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: initialHome,
      );
    }

    return MaterialApp.router(
      title: 'Naru',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
