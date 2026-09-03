/// The 4-based spacing scale from `tokens/spacing.css`, plus the slip's fixed
/// rhythm (row padding, page gutter) called out by name in the design system's
/// readme — those are product decisions, not just points on the scale, so they
/// keep their own names rather than being referenced as "space6" everywhere.
abstract final class AppSpacing {
  static const double space0 = 0;
  static const double space1 = 2;
  static const double space2 = 4;
  static const double space3 = 6;
  static const double space4 = 8;
  static const double space5 = 12;
  static const double space6 = 16;
  static const double space7 = 20;
  static const double space8 = 24;
  static const double space9 = 32;
  static const double space10 = 40;
  static const double space11 = 48;
  static const double space12 = 64;

  static const double gutterMobile = 16;
  static const double gutterDesktop = 32;
  static const double pageMax = 1120;

  /// Vertical gap between selection rows — there is none; rows touch and are
  /// separated by a hairline (`SelectionRow`'s own top border), so this token
  /// is the row's internal padding, not a gap between siblings.
  static const double slipRowGap = 12;
  static const double slipRowPadY = 12;
  static const double slipRowPadX = 14;
  static const double cardPad = 16;

  /// Never go below this for anything tappable — §"Layout rules" in the
  /// design system readme, non-negotiable for a thumb on a phone.
  static const double tapMin = 44;
}
