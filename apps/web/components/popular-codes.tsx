'use client';

import { useState, useTransition } from 'react';
import type { PopularPage, Slip } from '@booking-code/contracts';
import { PopularCodeTile } from '@/components/popular-code-tile';
import { Button } from '@/components/ui/button';
import { mergeCodes } from '@/lib/popular';
import { loadPopular } from '@/app/actions';

/**
 * The Decode screen's browse list — live codes from `GET /api/booking-codes/popular`
 * (docs/backend-api.md §1), the one section of the app that was never going to be a
 * hardcoded list. The first page arrives from the server; "Load more" pulls the next through
 * a Server Action and appends.
 *
 * Paging is driven by `hasMore`, never by `codes.length` — the catalogue drops expired codes
 * so a page can come back short or empty while there is still more to fetch. `excludeCode`
 * drops the currently-decoded slip so the list never shows a duplicate of what's above it.
 */
export function PopularCodes({
  firstPage,
  onUse,
  excludeCode,
  heading = 'Popular codes',
}: {
  firstPage: PopularPage | null;
  onUse: (code: string) => void;
  excludeCode?: string;
  heading?: string;
}) {
  const [codes, setCodes] = useState<Slip[]>(firstPage?.codes ?? []);
  const [nextSkip, setNextSkip] = useState((firstPage?.skip ?? 0) + (firstPage?.limit ?? 0));
  const [hasMore, setHasMore] = useState(firstPage?.hasMore ?? false);
  const [failed, setFailed] = useState(firstPage === null);
  const [pending, startTransition] = useTransition();

  const total = firstPage?.total ?? 0;
  const shown = excludeCode ? codes.filter((c) => c.bookingCode !== excludeCode) : codes;

  function loadMore() {
    startTransition(async () => {
      const page = await loadPopular(nextSkip);
      if (!page) {
        setFailed(true);
        return;
      }
      setCodes((prev) => mergeCodes(prev, page.codes));
      setNextSkip(page.skip + page.limit);
      setHasMore(page.hasMore);
    });
  }

  return (
    <section className="flex flex-col gap-2">
      <div className="flex items-baseline justify-between">
        <h2 className="type-label text-text-muted">{heading}</h2>
        {shown.length > 0 && total > 0 && (
          <span className="type-meta text-text-muted">
            {shown.length} of {total}
          </span>
        )}
      </div>

      {shown.length === 0 ? (
        <p className="type-meta text-text-muted">
          {failed
            ? "Couldn't load codes to try right now."
            : 'Nothing else to try right now — paste a code above instead.'}
        </p>
      ) : (
        <ul className="flex flex-col gap-2">
          {shown.map((slip) => (
            <li key={slip.bookingCode} className="animate-rise">
              <PopularCodeTile slip={slip} onUse={onUse} />
            </li>
          ))}
        </ul>
      )}

      {hasMore && !failed && (
        <Button variant="secondary" block loading={pending} onClick={loadMore} className="mt-1">
          Load more codes
        </Button>
      )}
      {failed && shown.length > 0 && (
        <p className="type-meta text-text-muted">Couldn&apos;t load any more just now.</p>
      )}
    </section>
  );
}
