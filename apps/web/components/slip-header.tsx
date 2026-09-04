import type { ReactNode } from 'react';
import { Check, Clock, Copy, List, TriangleAlert, Users } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { IconButton } from '@/components/ui/icon-button';
import { formatExpiry, formatOdds, formatUsage, pluralize } from '@/lib/format';

export type SlipStatus = 'live' | 'partial';

// design-system.md §5: status is `live` or `partial` only. There is deliberately no `expired`
// status — `/resolve` always returns `expiresAt: null`, so the app cannot know it.
const STATUS: Record<SlipStatus, { tone: 'accent' | 'warn'; label: string; Icon: typeof Check }> = {
  live: { tone: 'accent', label: 'Active', Icon: Check },
  partial: { tone: 'warn', label: 'Some legs dead', Icon: TriangleAlert },
};

export function SlipHeader({
  code,
  totalOdds,
  selectionCount,
  status,
  expiresAt,
  usageCount,
  onCopy,
}: {
  code: string;
  totalOdds: number;
  selectionCount: number;
  status: SlipStatus;
  expiresAt?: string | null;
  usageCount?: number | null;
  onCopy?: () => void;
}) {
  const spec = STATUS[status];

  return (
    <div className="flex flex-col gap-3.5 p-[14px] pt-4">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="type-label text-text-muted">Booking code</p>
          <div className="mt-1.5 flex items-center gap-2">
            <span className="type-code-hero truncate text-code-text">{code}</span>
            {onCopy && (
              <IconButton
                label="Copy booking code"
                size="sm"
                icon={<Copy className="size-4" aria-hidden />}
                onClick={onCopy}
              />
            )}
          </div>
        </div>
        <div className="shrink-0 text-right">
          <p className="type-label text-text-muted">Total odds</p>
          <p className="type-odds-hero mt-1 text-odds-text">{formatOdds(totalOdds)}</p>
        </div>
      </div>

      <div className="flex flex-wrap items-center gap-x-2.5 gap-y-2">
        <Badge tone={spec.tone} icon={<spec.Icon className="size-3" aria-hidden />}>
          {spec.label}
        </Badge>
        <Meta icon={<List className="size-3" aria-hidden />}>
          {pluralize(selectionCount, 'selection')}
        </Meta>
        {expiresAt != null && (
          <Meta icon={<Clock className="size-3" aria-hidden />}>{formatExpiry(expiresAt)}</Meta>
        )}
        {usageCount != null && (
          <Meta icon={<Users className="size-3" aria-hidden />}>{formatUsage(usageCount)}</Meta>
        )}
      </div>
    </div>
  );
}

function Meta({ icon, children }: { icon: ReactNode; children: ReactNode }) {
  return (
    <span className="type-meta flex items-center gap-1.5 text-text-muted">
      {icon}
      {children}
    </span>
  );
}
