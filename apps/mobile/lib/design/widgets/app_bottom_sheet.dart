import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';
import 'app_icon_button.dart';

/// The only modal surface on mobile (share, market picker, slip details).
///
/// `Sheet.jsx` hand-rolls this as a fixed-position overlay with a click-away
/// scrim, because the web has no native bottom sheet primitive. Flutter does
/// — [showModalBottomSheet] already gives drag-to-dismiss, the system back
/// button, and route-based focus handling for free — so this wraps that
/// primitive with the design system's chrome (drag handle, title row, close
/// button, footer slot) rather than re-implementing the overlay by hand.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  WidgetBuilder? footerBuilder,
  double? heightFactor,
}) {
  final colors = context.colors;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: colors.overlayScrim,
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      return FractionallySizedBox(
        heightFactor: heightFactor,
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.88),
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            border: Border(top: BorderSide(color: colors.borderStrong)),
            borderRadius: AppShapes.sheetTop,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderStrong,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.h3.copyWith(
                          color: colors.textPrimary,
                          letterSpacing: -0.015 * 16,
                        ),
                      ),
                    ),
                    AppIconButton(
                      icon: 'x',
                      label: 'Close',
                      size: AppIconButtonSize.sm,
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16 + media.viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(child: builder(sheetContext)),
                ),
              ),
              if (footerBuilder != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: colors.borderSubtle)),
                  ),
                  child: footerBuilder(sheetContext),
                ),
            ],
          ),
        ),
      );
    },
  );
}
