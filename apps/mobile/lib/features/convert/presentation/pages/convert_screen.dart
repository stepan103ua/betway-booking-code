import 'package:flutter/material.dart';

import '../../../../widgets/slip/empty_state.dart';

/// Convert: take an existing slip, drop dead legs, regenerate a code.
///
/// Placeholder only. The previous version of this screen let you drop dead
/// legs and "generate" a fresh code — but that code was a hardcoded string
/// (`BW5M08QT31`), never a real one, because there is no
/// `features/convert/data/` composing `resolve` → drop → `POST
/// /api/booking-codes/convert` (`docs/backend-api.md` §1) yet. A flow that
/// looks functional but hands back a fake code is worse than none — this
/// says plainly that it isn't built.
///
/// Wiring it for real means giving it the same `data/domain/presentation`
/// skeleton `features/decode/` already has (`docs/mobile.md` §2–§7); this
/// file becomes that feature's `presentation/pages/convert_screen.dart`.
class ConvertScreen extends StatelessWidget {
  const ConvertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: EmptyState(
        icon: 'repeat',
        title: "Convert isn't built yet",
        body:
            'Rebuilding a slip needs its own connection to the API. Decode is '
            'the only feature that talks to it today.',
      ),
    );
  }
}
