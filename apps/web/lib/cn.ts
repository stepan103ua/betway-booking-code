import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

/**
 * Merge class lists so a caller's utility wins over a component's default for the same
 * property (`<Button className="h-[52px]" />` beats the variant's `h-12`). The standard
 * shadcn/ui helper — the `components/ui/` primitives (docs/design-system.md §4) are built
 * the shadcn way: plain elements, `cva` variants, retinted to our tokens.
 */
export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}
