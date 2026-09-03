'use client';

import { Button } from '@/components/ui/button';

/**
 * Route-level error boundary (docs/frontend.md §6) — catches *render* errors only. Expected
 * API outcomes (an invalid code, an unreachable service) are handled in the Server Action
 * and rendered as UI state; they never reach here.
 */
export default function Error({ reset }: { error: Error; reset: () => void }) {
  return (
    <main className="flex flex-col items-start gap-4">
      <h1 className="type-h1 text-text-primary">Something broke</h1>
      <p className="type-body text-text-secondary">
        The page hit an unexpected error. Reload to try again.
      </p>
      <Button size="lg" onClick={reset}>
        Reload
      </Button>
    </main>
  );
}
