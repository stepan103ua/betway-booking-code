import type { Slip } from '@booking-code/contracts';
import { ChevronRight } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { cn } from '@/lib/cn';
import { convertPreview } from '@/lib/convert-preview';
import { formatOdds, pluralize } from '@/lib/format';

/**
 * The before/after: the loaded code's odds and leg count, then what a Convert would leave.
 * The "after" odds are a preview — the real total is set when `/convert` re-encodes
 * (docs/betway-api.md §3), hence the `≈` and the caveat.
 */
export function DiffSummary({ original, drops }: { original: Slip; drops: Set<string> }) {
  const preview = convertPreview(original.selections, drops);
  const keptCount = preview.kept.length;

  return (
    <Card tone="sunken">
      <div className="flex items-center gap-4">
        <OddsBlock
          label="Now"
          odds={formatOdds(original.totalOdds)}
          legs={original.selections.length}
        />
        <ChevronRight className="size-[18px] shrink-0 text-text-muted" aria-hidden />
        <OddsBlock
          label="After"
          odds={`≈ ${formatOdds(preview.previewOdds)}`}
          legs={keptCount}
          muted={!preview.canConvert}
          replayKey={`${keptCount}:${preview.previewOdds}`}
        />
      </div>
      <p className="type-meta mt-3 leading-[1.5] text-text-muted">
        {preview.droppedCount === 0
          ? 'Nothing dropped yet — converting reissues the same bet.'
          : `${pluralize(preview.droppedCount, 'leg')} dropped. Final odds are set when you convert — live prices differ from these.`}
      </p>
    </Card>
  );
}

function OddsBlock({
  label,
  odds,
  legs,
  muted = false,
  replayKey,
}: {
  label: string;
  odds: string;
  legs: number;
  muted?: boolean;
  replayKey?: string;
}) {
  return (
    <div className="flex flex-col">
      <span className="type-label text-text-muted">{label}</span>
      <span
        key={replayKey}
        className={cn(
          'type-odds mt-1 text-[18px]',
          replayKey && 'animate-rise',
          muted ? 'text-text-disabled' : 'text-odds-text',
        )}
      >
        {odds}
      </span>
      <span className="type-meta mt-0.5 text-text-muted">{pluralize(legs, 'leg')}</span>
    </div>
  );
}
