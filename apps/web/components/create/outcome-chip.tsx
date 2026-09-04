import { Check } from 'lucide-react';
import { cn } from '@/lib/cn';
import { formatOdds } from '@/lib/format';

/**
 * One tappable outcome — a label and its odds — used both in an event tile's inline 1X2 row
 * and in the "more markets" sheet. A selected leg carries the accent border/fill; the odds
 * stay in the mono odds face either way, the same treatment `SelectionRow` gives them.
 */
export function OutcomeChip({
  label,
  odds,
  selected,
  disabled = false,
  block = false,
  onToggle,
}: {
  label: string;
  odds: number;
  selected: boolean;
  disabled?: boolean;
  /** `true` in the inline 1X2 row (equal columns); `false` in the sheet (wrap to content). */
  block?: boolean;
  onToggle: () => void;
}) {
  const off = disabled && !selected;

  return (
    <button
      type="button"
      disabled={off}
      aria-pressed={selected}
      onClick={onToggle}
      className={cn(
        'flex items-center gap-2 rounded-tile border px-2.5 py-2 transition-[background-color,border-color,transform] duration-[120ms] ease-[var(--ease-out)] active:scale-[0.97]',
        block ? 'w-full justify-between' : 'w-auto',
        selected
          ? 'border-accent-solid bg-accent-quiet text-accent-text'
          : 'border-border-strong bg-surface-raised text-text-primary hover:bg-surface-hover',
        off && 'pointer-events-none opacity-40',
      )}
    >
      <span className="type-meta truncate font-semibold">{label}</span>
      <span className="flex items-center gap-1.5">
        <span
          className={cn('type-odds text-[12px]', selected ? 'text-accent-text' : 'text-odds-text')}
        >
          {formatOdds(odds)}
        </span>
        {selected && <Check className="size-3 animate-pop" aria-hidden />}
      </span>
    </button>
  );
}
