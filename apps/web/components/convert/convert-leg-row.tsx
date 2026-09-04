import type { Selection } from '@booking-code/contracts';
import { Ban, Check } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { cn } from '@/lib/cn';
import { DEAD_LEG_REASON, formatKickoff, formatOdds } from '@/lib/format';

/**
 * One leg in the Convert list: a keep/drop toggle, the selection, its odds. Styled to match
 * `SelectionRow` but built fresh — that component's whole model of "struck through" is
 * `!isActive`, and Convert needs a third state: a *live* leg the user chose to drop.
 */
export function ConvertLegRow({
  selection,
  dropped,
  onToggle,
  className,
}: {
  selection: Selection;
  /** Not in the new code — the user unchecked a live leg, or it's dead. */
  dropped: boolean;
  /** `undefined` for dead legs: always dropped, nothing to toggle. */
  onToggle?: () => void;
  className?: string;
}) {
  const dead = !selection.isActive;
  const muted = dropped || dead;

  return (
    <li
      className={cn(
        'flex gap-3 border-t border-border-subtle px-[14px] py-3 first:border-t-0 transition-colors duration-[120ms]',
        muted && 'bg-state-stale-surface',
        className,
      )}
    >
      <DropToggle kept={!dropped} enabled={onToggle != null} onToggle={onToggle} />

      <div
        className={cn('min-w-0 flex-1 transition-opacity duration-[120ms]', muted && 'opacity-70')}
      >
        <p
          className={cn(
            'type-body-strong line-clamp-2',
            muted ? 'text-state-stale-text line-through' : 'text-text-primary',
          )}
        >
          {selection.eventName}
        </p>

        <div className="mt-1.5 flex flex-wrap items-center gap-1.5">
          <Badge tone={muted ? 'stale' : 'neutral'}>{selection.marketName}</Badge>
          <span
            className={cn(
              'type-meta truncate font-semibold',
              muted ? 'text-state-stale-text' : 'text-text-primary',
            )}
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
            {DEAD_LEG_REASON} — dropped automatically
          </p>
        )}
      </div>

      <span
        className={cn(
          'type-odds shrink-0 pt-px transition-colors duration-[120ms]',
          muted ? 'text-text-disabled line-through' : 'text-odds-text',
        )}
      >
        {formatOdds(selection.odds)}
      </span>
    </li>
  );
}

/** A small keep/drop square — accent fill + check when kept, empty outline when dropped. */
function DropToggle({
  kept,
  enabled,
  onToggle,
}: {
  kept: boolean;
  enabled: boolean;
  onToggle?: () => void;
}) {
  return (
    <button
      type="button"
      disabled={!enabled}
      aria-pressed={kept}
      aria-label={kept ? 'Keep this leg' : 'Dropped — click to keep'}
      onClick={onToggle}
      className="grid h-10 w-6 shrink-0 place-items-start pt-px disabled:opacity-45"
    >
      <span
        className={cn(
          'grid size-5 place-items-center rounded-[8px] border transition-[background-color,border-color,transform] duration-[120ms] ease-[var(--ease-out)]',
          enabled && 'active:scale-90',
          kept ? 'border-accent-solid bg-accent-solid text-text-on-accent' : 'border-border-strong',
        )}
      >
        {kept && <Check className="size-3 animate-pop" aria-hidden />}
      </span>
    </button>
  );
}
