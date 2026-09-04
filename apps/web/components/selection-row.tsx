import type { Selection } from '@booking-code/contracts';
import { Ban, X } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { cn } from '@/lib/cn';
import { DEAD_LEG_REASON, formatKickoff, formatOdds } from '@/lib/format';

/**
 * One leg of a slip — three lines, compact enough for ~16 rows on a phone (design-system.md
 * §5). Takes the domain `Selection` directly; formatting a kickoff or the generic dead-leg
 * reason inline here is exactly the display logic a presentational component may own.
 */
export function SelectionRow({
  selection,
  index,
  onRemove,
  className,
}: {
  selection: Selection;
  index?: number;
  onRemove?: () => void;
  className?: string;
}) {
  const dead = !selection.isActive;

  return (
    <li
      className={cn(
        'flex gap-3 border-t border-border-subtle px-[14px] py-3 first:border-t-0 data-[dead=true]:bg-state-stale-surface data-[dead=true]:opacity-70',
        className,
      )}
      data-dead={dead}
    >
      {index !== undefined && (
        <span className="type-code w-[18px] shrink-0 pt-0.5 text-right text-[11px] text-text-disabled">
          {index}
        </span>
      )}

      <div className="min-w-0 flex-1">
        <p
          className={`type-body-strong ${dead ? 'text-state-stale-text line-through' : 'text-text-primary'} line-clamp-2`}
        >
          {selection.eventName}
        </p>

        <div className="mt-1.5 flex flex-wrap items-center gap-1.5">
          <Badge tone={dead ? 'stale' : 'neutral'}>{selection.marketName}</Badge>
          <span
            className={`type-meta truncate font-semibold ${dead ? 'text-state-stale-text' : 'text-text-primary'}`}
          >
            {selection.outcomeName.trim()}
          </span>
        </div>

        <p className="type-meta mt-1.5 truncate text-text-muted">
          {selection.league} &nbsp;·&nbsp; {formatKickoff(selection.kickoffAt)}
        </p>

        {dead && (
          <p className="type-meta mt-1.5 flex items-center gap-1.5 text-danger-text">
            <Ban className="size-3 shrink-0" aria-hidden />
            {DEAD_LEG_REASON}
          </p>
        )}
      </div>

      <div className="flex shrink-0 items-start gap-2 pt-px">
        <span
          className={`type-odds ${dead ? 'text-text-disabled line-through' : 'text-odds-text'}`}
        >
          {formatOdds(selection.odds)}
        </span>
        {onRemove && (
          <button
            type="button"
            onClick={onRemove}
            aria-label={`Remove ${selection.outcomeName.trim()}`}
            className="grid size-6 place-items-center text-text-disabled hover:text-text-primary"
          >
            <X className="size-3.5" aria-hidden />
          </button>
        )}
      </div>
    </li>
  );
}
