import { type ButtonHTMLAttributes, type ReactNode, type Ref } from 'react';
import { type VariantProps, cva } from 'class-variance-authority';
import { cn } from '@/lib/cn';

// design-system.md §4: circular, icon-only. `label` is REQUIRED — it is the accessible name.
// Sizes sm (32) · md (40) · lg (44); variants ghost · solid · accent.
const iconButton = cva(
  'inline-flex shrink-0 items-center justify-center rounded-pill transition-colors duration-[120ms] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-focus-ring disabled:pointer-events-none disabled:opacity-45',
  {
    variants: {
      variant: {
        ghost:
          'bg-surface-hover text-text-secondary hover:bg-surface-raised hover:text-text-primary',
        solid:
          'border border-border-strong bg-surface-raised text-text-primary hover:bg-surface-hover',
        accent: 'bg-accent-solid text-text-on-accent hover:bg-accent-hover',
      },
      size: { sm: 'size-8', md: 'size-10', lg: 'size-11' },
    },
    defaultVariants: { variant: 'ghost', size: 'md' },
  },
);

type IconButtonProps = Omit<ButtonHTMLAttributes<HTMLButtonElement>, 'aria-label'> &
  VariantProps<typeof iconButton> & {
    /** The accessible name. Required. */
    label: string;
    icon: ReactNode;
    ref?: Ref<HTMLButtonElement>;
  };

export function IconButton({
  className,
  variant,
  size,
  label,
  icon,
  type = 'button',
  ref,
  ...props
}: IconButtonProps) {
  return (
    <button
      ref={ref}
      type={type}
      aria-label={label}
      title={label}
      className={cn(iconButton({ variant, size }), className)}
      {...props}
    >
      {icon}
    </button>
  );
}
