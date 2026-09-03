'use client';

import Link from 'next/link';
import type { Slip } from '@booking-code/contracts';
import { Check, Copy, ExternalLink, Repeat, Share2 } from 'lucide-react';
import { Button, buttonVariants } from '@/components/ui/button';
import { BETWAY_URL } from '@/lib/betway';
import { pluralize } from '@/lib/format';

/**
 * The loaded slip's footer. A fully-live slip gets Load / Copy / Share; a slip with dead legs
 * leads with "Rebuild" — hand the code to Convert to reissue it without the dead legs — and
 * demotes "load as-is" to a ghost link (mirrors apps/mobile's `decode_screen.dart`).
 */
export function SlipFooter({
  slip,
  copied,
  onCopy,
  onShare,
}: {
  slip: Slip;
  copied: boolean;
  onCopy: () => void;
  onShare: () => void;
}) {
  const live = slip.selections.filter((s) => s.isActive).length;
  const dead = slip.selections.length - live;

  if (dead > 0) {
    return (
      <div className="flex flex-col gap-2">
        <Link
          href={`/convert?code=${encodeURIComponent(slip.bookingCode)}`}
          className={buttonVariants({ variant: 'primary', size: 'md', block: true })}
        >
          <Repeat className="size-4" aria-hidden />
          Rebuild with {pluralize(live, 'live leg')}
        </Link>
        <a
          href={BETWAY_URL}
          target="_blank"
          rel="noopener noreferrer"
          className={buttonVariants({ variant: 'ghost', size: 'md', block: true })}
        >
          <ExternalLink className="size-4" aria-hidden />
          Load as-is in Betway
        </a>
      </div>
    );
  }

  return (
    <div className="flex gap-2">
      <a
        href={BETWAY_URL}
        target="_blank"
        rel="noopener noreferrer"
        className={buttonVariants({ variant: 'primary', size: 'md', block: true })}
      >
        <ExternalLink className="size-4" aria-hidden />
        Load in Betway
      </a>
      <Button
        variant="secondary"
        onClick={onCopy}
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
      <Button
        variant="secondary"
        onClick={onShare}
        icon={<Share2 className="size-4" aria-hidden />}
      >
        Share
      </Button>
    </div>
  );
}
