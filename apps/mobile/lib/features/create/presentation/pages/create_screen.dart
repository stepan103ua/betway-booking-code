import 'package:flutter/material.dart';

import '../../../../widgets/slip/empty_state.dart';

/// Create: build a slip from scratch, generate a code.
///
/// Placeholder only. The previous version of this screen let you pick
/// outcomes and "generate" a code — but that code was a hardcoded string
/// (`BW7K42D190`), never a real one, because there is no
/// `features/create/data/` calling `POST /api/booking-codes`
/// (`docs/backend-api.md` §1) yet. A picker that looks functional but hands
/// back a fake code is worse than no picker — this says plainly that it
/// isn't built.
///
/// Wiring it for real means giving it the same `data/domain/presentation`
/// skeleton `features/decode/` already has (`docs/mobile.md` §2–§7); this
/// file becomes that feature's `presentation/pages/create_screen.dart`.
class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: EmptyState(
        icon: 'plus',
        title: "Create isn't built yet",
        body:
            "Building a slip from scratch needs its own connection to the API. "
            'Decode is the only feature that talks to it today.',
      ),
    );
  }
}
