import { type ButtonHTMLAttributes, type ReactNode, type Ref } from 'react';
import { type VariantProps, cva } from 'class-variance-authority';
import { LoaderCircle } from 'lucide-react';
import { cn } from '@/lib/cn';

// design-system.md §4: primary · secondary · ghost · danger; sm/md/lg. Pill by default, no
// elevation, no ripple — press is a scale + fill swap. One `primary` per screen.
export const buttonVariants = cva(
  'inline-flex items-center justify-center gap-2 rounded-pill type-body-strong whitespace-nowrap transition-transform duration-[120ms] ease-[cubic-bezier(0.2,0.8,0.2,1)] active:scale-[0.985] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus-ring disabled:pointer-events-none disabled:opacity-45 aria-disabled:pointer-events-none aria-disabled:opacity-45',
  {
    variants: {
      variant: {
        primary: 'bg-accent-solid text-text-on-accent hover:bg-accent-hover active:bg-accent-press',
        secondary:
          'border border-border-strong bg-surface-raised text-text-primary hover:bg-surface-hover',
        ghost: 'text-text-secondary hover:bg-surface-hover',
        danger:
          'border border-danger-solid bg-danger-quiet text-danger-text hover:bg-danger-solid/15',
      },
      size: { sm: 'h-8 gap-1.5 px-3 text-[13px]', md: 'h-10 px-4', lg: 'h-12 px-5' },
      block: { true: 'w-full', false: '' },
    },
    defaultVariants: { variant: 'primary', size: 'md', block: false },
  },
);

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> &
  VariantProps<typeof buttonVariants> & {
    /** Leading glyph, hidden while `loading` (design-system.md §4). */
    icon?: ReactNode;
    iconRight?: ReactNode;
    /** Spinner in place of the leading icon; also blocks clicks. */
    loading?: boolean;
    ref?: Ref<HTMLButtonElement>;
  };

export function Button({
  className,
  variant,
  size,
  block,
  icon,
  iconRight,
  loading = false,
  disabled,
  children,
  type = 'button',
  ref,
  ...props
}: ButtonProps) {
  return (
    <button
      ref={ref}
      type={type}
      disabled={disabled ?? loading}
      aria-busy={loading || undefined}
      className={cn(buttonVariants({ variant, size, block }), className)}
      {...props}
    >
      {loading ? <LoaderCircle className="size-[1.1em] animate-spin" aria-hidden /> : icon}
      {children}
      {iconRight}
    </button>
  );
}
