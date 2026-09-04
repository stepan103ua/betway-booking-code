import Link from 'next/link';
import type { Sport } from '@booking-code/contracts';
import { cn } from '@/lib/cn';

/**
 * Horizontal row of sport chips. Upstream lists only soccer today, so this usually renders a
 * single selected chip — it exists in full so a second sport in `GET /api/sports` needs no
 * change here. Each chip is a link to `/create?sport=<id>`; the page re-renders with that
 * sport's first fixture page.
 */
export function SportSelector({ sports, selectedId }: { sports: Sport[]; selectedId: string }) {
  return (
    <div className="flex flex-col gap-2">
      <span className="type-label text-text-muted">Sport</span>
      <div className="-mx-1 flex gap-2 overflow-x-auto px-1 py-0.5">
        {sports.map((sport) => {
          const active = sport.id === selectedId;
          return (
            <Link
              key={sport.id}
              href={sport.id === sports[0]?.id ? '/create' : `/create?sport=${sport.id}`}
              aria-current={active ? 'true' : undefined}
              className={cn(
                'type-body-strong shrink-0 rounded-pill border px-4 py-2 text-[13px] transition-[background-color,border-color,transform] duration-[120ms] ease-[var(--ease-out)] active:scale-[0.97]',
                active
                  ? 'border-accent-solid bg-accent-solid text-text-on-accent'
                  : 'border-border-strong bg-surface-raised text-text-secondary hover:bg-surface-hover',
              )}
            >
              {sport.name}
            </Link>
          );
        })}
      </div>
    </div>
  );
}
