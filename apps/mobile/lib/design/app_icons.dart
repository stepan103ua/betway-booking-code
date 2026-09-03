import 'package:flutter/widgets.dart';

/// Resolves a design-system icon name (the kebab-case Lucide names used
/// throughout the `.jsx` components and this port, e.g. `'triangle-alert'`,
/// `'scan-line'`) to the matching glyph in the bundled Lucide font.
///
/// The web side resolves the same name strings at runtime against the Lucide
/// CDN bundle (`components/core/Icon.jsx`) — this is that resolver's Flutter
/// twin, so a screen written against the design system's icon vocabulary
/// (`AppIcon('copy')`) doesn't need a second, Flutter-specific name for
/// every glyph.
///
/// Builds each [IconData] as a literal `const` from the codepoints in
/// `package:lucide_icons` (kept as a dependency for its bundled `Lucide`
/// font asset only — Flutter merges a package's declared fonts into the app
/// regardless of whether any of its Dart code is imported), rather than
/// importing `package:lucide_icons/lucide_icons.dart` and using its
/// `LucideIcons.*` constants directly. That package's
/// `LucideIconData extends IconData` fails to compile on current Flutter —
/// `IconData` became a `final class` after the package was last published,
/// so it can no longer be subclassed. Every entry below is written as a
/// literal `const IconData(0x..., ...)` rather than routed through a helper
/// function that takes the codepoint as a parameter: `flutter build`'s icon
/// tree-shaking needs to see the exact codepoint at each call site to know
/// which glyphs the release binary actually uses, and a wrapper function
/// call defeats that regardless of whether it's still a compile-time
/// constant.
///
/// `lucide_icons` ships an older Lucide snapshot, from before a handful of
/// icons were renamed upstream. Three names in the working set (readme
/// "ICONOGRAPHY") don't exist under their current name in that snapshot and
/// are mapped to their pre-rename codepoint here — same glyph, old name:
/// - `triangle-alert` → `alert-triangle`
/// - `loader-circle` → `loader-2`
/// - `wand-sparkles` → `wand-2`
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    super.key,
    this.size = 16,
    this.color,
    this.semanticLabel,
  });

  final String name;
  final double size;
  final Color? color;
  final String? semanticLabel;

  static const _fontFamily = 'Lucide';
  static const _fontPackage = 'lucide_icons';

  static const Map<String, IconData> _byName = {
    'scan-line': IconData(
      0xf4a4,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'plus': IconData(
      0xf45e,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'repeat': IconData(
      0xf485,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'hash': IconData(
      0xf34a,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'copy': IconData(
      0xf252,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'check': IconData(
      0xf1ee,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'share-2': IconData(
      0xf4bd,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'external-link': IconData(
      0xf29b,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'clock': IconData(
      0xf221,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'users': IconData(
      0xf574,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'user': IconData(
      0xf564,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'list': IconData(
      0xf39b,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'ticket': IconData(
      0xf539,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'ban': IconData(0xf182, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'triangle-alert': IconData(
      0xf10d,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ), // alert-triangle
    'info': IconData(
      0xf36e,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'rotate-ccw': IconData(
      0xf491,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'search': IconData(
      0xf4ad,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'chevron-left': IconData(
      0xf1f9,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'chevron-right': IconData(
      0xf1fb,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'x': IconData(0xf59e, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'wand-sparkles': IconData(
      0xf58d,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ), // wand-2
    'scissors': IconData(
      0xf4a8,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'shield-check': IconData(
      0xf4c1,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'loader-circle': IconData(
      0xf3aa,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ), // loader-2
    'sun': IconData(0xf50f, fontFamily: _fontFamily, fontPackage: _fontPackage),
    'moon': IconData(
      0xf3eb,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'signal': IconData(
      0xf4d0,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'wifi': IconData(
      0xf596,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'battery-full': IconData(
      0xf190,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'history': IconData(
      0xf35d,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'settings': IconData(
      0xf4b9,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'bookmark': IconData(
      0xf1bd,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'message-circle': IconData(
      0xf3cd,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'send': IconData(
      0xf4b2,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
    'clipboard': IconData(
      0xf218,
      fontFamily: _fontFamily,
      fontPackage: _fontPackage,
    ),
  };

  static const IconData _fallback = IconData(
    0xf359,
    fontFamily: _fontFamily,
    fontPackage: _fontPackage,
  ); // help-circle

  @override
  Widget build(BuildContext context) {
    final data = _byName[name];
    assert(
      data != null,
      'AppIcon: no Lucide mapping for "$name" — add it to AppIcon._byName.',
    );
    return Icon(
      data ?? _fallback,
      size: size,
      color: color ?? IconTheme.of(context).color,
      semanticLabel: semanticLabel,
    );
  }
}
