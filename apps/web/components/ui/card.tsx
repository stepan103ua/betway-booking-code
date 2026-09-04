import { type HTMLAttributes, type Ref } from 'react';
import { type VariantProps, cva } from 'class-variance-authority';
import { cn } from '@/lib/cn';

// design-system.md §4: tones card · raised · sunken · outline; padding none/sm/md/lg.
// 1px border + radius lg. Layers separate by a hairline plus a surface-lightness step —
// never a shadow, never elevation (§1).
const card = cva('rounded-card border', {
  variants: {
    tone: {
      card: 'border-border-subtle bg-surface-card',
      raised: 'border-border-subtle bg-surface-raised',
      sunken: 'border-border-subtle bg-surface-sunken',
      outline: 'border-border-strong bg-transparent',
    },
    padding: { none: 'p-0', sm: 'p-3', md: 'p-4', lg: 'p-5' },
  },
  defaultVariants: { tone: 'card', padding: 'md' },
});

type CardProps = HTMLAttributes<HTMLDivElement> &
  VariantProps<typeof card> & { ref?: Ref<HTMLDivElement> };

export function Card({ className, tone, padding, ref, ...props }: CardProps) {
  return <div ref={ref} className={cn(card({ tone, padding }), className)} {...props} />;
}
