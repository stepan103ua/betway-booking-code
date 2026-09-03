'use client';

import { useState } from 'react';
import { Check, Copy, ExternalLink } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button, buttonVariants } from '@/components/ui/button';
import { DashedBorder } from '@/components/ui/dashed-border';
import { Modal } from '@/components/ui/modal';
import { BETWAY_URL, shareText } from '@/lib/betway';
import { formatOdds } from '@/lib/format';

/** Share this code, in the one modal surface (design-system.md §4). */
export function ShareDialog({
  open,
  onClose,
  code,
  totalOdds,
}: {
  open: boolean;
  onClose: () => void;
  code: string;
  totalOdds: number;
}) {
  const [copied, setCopied] = useState(false);

  function copy() {
    void navigator.clipboard?.writeText(shareText(code, totalOdds)).catch(() => {});
    setCopied(true);
    setTimeout(() => setCopied(false), 1600);
  }

  return (
    <Modal
      open={open}
      onClose={onClose}
      title="Share this code"
      footer={
        <a
          href={BETWAY_URL}
          target="_blank"
          rel="noopener noreferrer"
          className={buttonVariants({ variant: 'primary', size: 'md', block: true })}
        >
          <ExternalLink className="size-4" aria-hidden />
          Open in Betway
        </a>
      }
    >
      <div className="flex flex-col gap-2.5">
        <DashedBorder className="flex items-center justify-between gap-3 rounded-control bg-surface-sunken px-3.5 py-3">
          <span className="type-code text-text-primary">{code}</span>
          <Badge mono tone="accent">
            {formatOdds(totalOdds)}
          </Badge>
        </DashedBorder>

        <Button
          variant="secondary"
          block
          icon={
            copied ? (
              <Check className="size-4" aria-hidden />
            ) : (
              <Copy className="size-4" aria-hidden />
            )
          }
          onClick={copy}
        >
          {copied ? 'Copied' : 'Copy code and odds'}
        </Button>
      </div>
    </Modal>
  );
}
