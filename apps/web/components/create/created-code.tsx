'use client';

import { useState } from 'react';
import { Check, Copy, ExternalLink, Plus } from 'lucide-react';
import { SlipCard } from '@/components/slip-card';
import { Alert } from '@/components/ui/alert';
import { Button, buttonVariants } from '@/components/ui/button';
import { BETWAY_URL } from '@/lib/betway';
import { type DraftPick, draftToSelection, draftTotalOdds } from '@/lib/draft';

/**
 * Shown once a code exists. Reuses `SlipCard` — the recap is the legs the user picked,
 * rendered exactly as a decoded slip would be. The odds are what we held at pick time, not a
 * re-decode: `POST /api/booking-codes` returns only the string and prices drift between pick
 * and encode (docs/betway-api.md §3), so the notice says so plainly.
 */
export function CreatedCode({
  bookingCode,
  picks,
  onStartOver,
}: {
  bookingCode: string;
  picks: DraftPick[];
  onStartOver: () => void;
}) {
  const [copied, setCopied] = useState(false);

  function copy() {
    void navigator.clipboard?.writeText(bookingCode).catch(() => {});
    setCopied(true);
    setTimeout(() => setCopied(false), 1600);
  }

  return (
    <div className="flex animate-rise flex-col gap-3">
      <p className="type-label text-accent-text">Code created</p>
      <SlipCard
        code={bookingCode}
        totalOdds={draftTotalOdds(picks)}
        selections={picks.map(draftToSelection)}
        collapsedCount={5}
        onCopy={copy}
        notice={
          <Alert tone="info" title="Odds are from when you picked">
            Betway prices move continuously. The code is live — the exact odds may have shifted
            since you built this slip.
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
              icon={<Plus className="size-4" aria-hidden />}
              onClick={onStartOver}
            >
              Build another slip
            </Button>
          </div>
        }
      />
    </div>
  );
}
