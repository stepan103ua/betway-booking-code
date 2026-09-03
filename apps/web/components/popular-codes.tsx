import type { Slip } from '@booking-code/contracts';
import { Badge } from '@/components/ui/badge';
import { Card } from '@/components/ui/card';
import { formatOdds } from '@/lib/format';

/**
 * The Decode screen's empty state — codes to try, from `GET /api/booking-codes/popular`,
 * fetched on the server and already in the HTML on first load (docs/frontend.md §2).
 *
 * A basic list for now. Clicking a code to pre-fill the form is a Client Component concern
 * and lands when the form and this list are wired together.
 */
export function PopularCodes({ codes }: { codes: Slip[] }) {
  return (
    <section className="flex flex-col gap-3">
      <h2 className="type-label text-text-muted">Popular codes</h2>
      <ul className="flex flex-col gap-2">
        {codes.map((slip) => (
          <li key={slip.bookingCode}>
            <Card padding="sm" className="flex items-center justify-between px-4">
              <span className="type-odds text-text-primary">{slip.bookingCode}</span>
              <span className="flex items-center gap-2">
                <span className="type-meta text-text-muted">{slip.selections.length} legs</span>
                <Badge mono tone="accent">
                  {formatOdds(slip.totalOdds)}
                </Badge>
              </span>
            </Card>
          </li>
        ))}
      </ul>
    </section>
  );
}
