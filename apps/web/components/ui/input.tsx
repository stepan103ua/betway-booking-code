import { type InputHTMLAttributes, type Ref } from 'react';
import { type VariantProps, cva } from 'class-variance-authority';
import { cn } from '@/lib/cn';

// design-system.md §4: sm (h36) · md (h44) · lg (h52, default). Border is danger when
// `invalid`, accent when focused, else borderInput. `mono` switches to the code face.
// Value transforms (uppercase-the-stored-value for the code preset) belong to the composing
// feature, not this primitive.
const input = cva(
  'w-full rounded-control border bg-surface-input px-4 text-text-primary outline-none transition-colors duration-[120ms] placeholder:text-text-muted focus:border-accent-solid disabled:opacity-45',
  {
    variants: {
      inputSize: { sm: 'h-9', md: 'h-11', lg: 'h-[52px]' },
      mono: { true: 'type-odds', false: 'type-body' },
      invalid: { true: 'border-danger-solid', false: 'border-border-input' },
    },
    defaultVariants: { inputSize: 'lg', mono: false, invalid: false },
  },
);

type InputProps = Omit<InputHTMLAttributes<HTMLInputElement>, 'size'> &
  VariantProps<typeof input> & { ref?: Ref<HTMLInputElement> };

export function Input({ className, inputSize, mono, invalid, ref, ...props }: InputProps) {
  return (
    <input
      ref={ref}
      aria-invalid={invalid || undefined}
      className={cn(input({ inputSize, mono, invalid }), className)}
      {...props}
    />
  );
}
