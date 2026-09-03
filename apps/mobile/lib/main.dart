import 'package:flutter/material.dart';

import 'core/di.dart';
import 'design/app_theme.dart';
import 'shell/app_shell.dart';

void main() {
  setupDependencies();
  runApp(const MainApp());
}

/// Dark only for v1 — no theme switch in scope, so there is nothing to hold
/// state for. `AppColors.light` / `AppTheme.light()` stay in `lib/design/`
/// regardless: they're the design system's own ported tokens, not UI, and
/// cost nothing sitting unused until a theme switch is actually built.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'booking code',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const AppShell(),
    );
  }
}
