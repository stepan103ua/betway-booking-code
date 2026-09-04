'use client';

import { useState } from 'react';
import type { ConvertResult } from '@booking-code/contracts';
import { Check, Copy, ExternalLink, Repeat } from 'lucide-react';
import { SlipCard } from '@/components/slip-card';
import { Alert } from '@/components/ui/alert';
import { Button, buttonVariants } from '@/components/ui/button';
import { BETWAY_URL } from '@/lib/betway';
import { formatOdds, pluralize } from '@/lib/format';

/**
 * The after view: the new code as a `SlipCard`, the before/after diff in its notice slot.
 * The selections and total are the **decoded new code** (docs/backend-api.md §1) —
 * `previousTotalOdds` is the only "before" number, since the new odds are re-encoded and
 * drift from the old slip.
 */
export function ConvertResultView({
  result,
  onConvertAnother,
}: {
  result: ConvertResult;
  onConvertAnother: () => void;
}) {
  const [copied, setCopied] = useState(false);

  function copy() {
    void navigator.clipboard?.writeText(result.bookingCode).catch(() => {});
    setCopied(true);
    setTimeout(() => setCopied(false), 1600);
  }

  return (
    <div className="flex animate-rise flex-col gap-3">
      <p className="type-label text-accent-text">Converted</p>
      <SlipCard
        code={result.bookingCode}
        totalOdds={result.totalOdds}
        selections={result.selections}
        collapsedCount={5}
        onCopy={copy}
        notice={
          <Alert
            tone="success"
            title={
              result.droppedCount === 0
                ? `Reissued ${result.previousBookingCode}`
                : `Dropped ${pluralize(result.droppedCount, 'leg')} from ${result.previousBookingCode}`
            }
          >
            Was {formatOdds(result.previousTotalOdds)} — now {formatOdds(result.totalOdds)} across{' '}
            {pluralize(result.selections.length, 'leg')}. Odds are re-priced on the new code, so
            they differ from the old slip.
          </Alert>
        }
        footer={
          <div className="flex flex-col gap-2">
            <div className="flex gap-2">
              <a
                href={BETWAY_URL}
                target="_blank"
                rel="noopener noreferrer"
                className={buttonVariants({ variant: 'primary', size: 'md', block: true })}
              >
                <ExternalLink className="size-4" aria-hidden />
                Open in Betway
              </a>
              <Button
                variant="secondary"
                onClick={copy}
                icon={
                  copied ? (
                    <Check className="size-4" aria-hidden />
                  ) : (
                    <Copy className="size-4" aria-hidden />
                  )
                }
              >
                {copied ? 'Copied' : 'Copy'}
              </Button>
            </div>
            <Button
              variant="ghost"
              block
              icon={<Repeat className="size-4" aria-hidden />}
              onClick={onConvertAnother}
            >
              Convert another code
            </Button>
          </div>
        }
      />
    </div>
  );
}
