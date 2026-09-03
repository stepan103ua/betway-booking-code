import { type ButtonHTMLAttributes, type Ref } from 'react';
import { type VariantProps, cva } from 'class-variance-authority';
import { cn } from '@/lib/cn';

// design-system.md §4: primary · secondary · ghost · danger; sm/md/lg. Pill by default, no
// elevation, no ripple — press is a scale + fill swap. One `primary` per screen.
const button = cva(
  'inline-flex items-center justify-center gap-2 rounded-pill type-body-strong whitespace-nowrap transition-transform duration-[120ms] ease-[cubic-bezier(0.2,0.8,0.2,1)] active:scale-[0.985] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus-ring disabled:pointer-events-none disabled:opacity-45',
  {
    variants: {
      variant: {
        primary: 'bg-accent-solid text-text-on-accent hover:bg-accent-hover active:bg-accent-press',
        secondary:
          'border border-border-strong bg-surface-raised text-text-primary hover:bg-surface-hover',
        ghost: 'text-text-secondary hover:bg-surface-hover',
        danger: 'bg-danger-solid text-text-on-accent hover:opacity-90',
      },
      size: { sm: 'h-8 px-4', md: 'h-10 px-5', lg: 'h-12 px-6' },
    },
    defaultVariants: { variant: 'primary', size: 'md' },
  },
);

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> &
  VariantProps<typeof button> & {
    /** Shows a spinner in place of any icon and blocks clicks (design-system.md §4). */
    loading?: boolean;
    ref?: Ref<HTMLButtonElement>;
  };

export function Button({
  className,
  variant,
  size,
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
      className={cn(button({ variant, size }), className)}
      {...props}
    >
      {loading && (
        <span
          aria-hidden
          className="size-4 animate-spin rounded-full border-2 border-current border-t-transparent"
        />
      )}
      {children}
    </button>
  );
}
