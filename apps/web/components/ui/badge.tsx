import { type HTMLAttributes } from 'react';
import { type VariantProps, cva } from 'class-variance-authority';
import { cn } from '@/lib/cn';

// design-system.md §4: tones neutral · accent · danger · warn · info · stale; sizes sm/md.
// Only the `quiet` variant is built — the one every current screen uses. `solid` / `outline`
// land here when a screen needs them, not before.
const badge = cva('inline-flex items-center rounded-tile type-label', {
  variants: {
    tone: {
      neutral: 'bg-surface-raised text-text-secondary',
      accent: 'bg-accent-quiet text-accent-text',
      danger: 'bg-danger-quiet text-danger-text',
      warn: 'bg-warn-quiet text-warn-text',
      info: 'bg-info-quiet text-info-text',
      stale: 'bg-surface-hover text-text-muted',
    },
    size: { sm: 'h-5 px-1.5', md: 'h-[26px] px-2' },
    /** Odds pills render in the mono code face (design-system.md §4). */
    mono: { true: 'type-odds', false: '' },
  },
  defaultVariants: { tone: 'neutral', size: 'sm', mono: false },
});

type BadgeProps = HTMLAttributes<HTMLSpanElement> & VariantProps<typeof badge>;

export function Badge({ className, tone, size, mono, ...props }: BadgeProps) {
  return <span className={cn(badge({ tone, size, mono }), className)} {...props} />;
}
