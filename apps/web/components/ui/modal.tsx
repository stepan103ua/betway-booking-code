'use client';

import { type ReactNode, useEffect, useRef } from 'react';
import { X } from 'lucide-react';
import { IconButton } from '@/components/ui/icon-button';

/**
 * The one modal surface (design-system.md §4). A native <dialog> in modal mode gives the
 * scrim, focus trap and Esc-to-close; the chrome and the sheet↔dialog responsiveness are in
 * `.app-modal` (globals.css) — bottom sheet on phones, centred dialog on desktop.
 */
type ModalProps = {
  open: boolean;
  onClose: () => void;
  title: string;
  children: ReactNode;
  footer?: ReactNode;
};

export function Modal({ open, onClose, title, children, footer }: ModalProps) {
  const ref = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const dialog = ref.current;
    if (!dialog) return;
    if (open && !dialog.open) dialog.showModal();
    if (!open && dialog.open) dialog.close();
  }, [open]);

  return (
    <dialog
      ref={ref}
      className="app-modal"
      onCancel={(e) => {
        // Let the exit transition run: prevent the synchronous close, drive it through state.
        e.preventDefault();
        onClose();
      }}
      onClose={onClose}
      onClick={(e) => {
        if (e.target === ref.current) onClose();
      }}
    >
      <div className="flex max-h-[inherit] flex-col">
        <div className="flex justify-center pt-3 sm:hidden">
          <span className="h-1 w-9 rounded-pill bg-border-strong" aria-hidden />
        </div>
        <header className="flex items-center justify-between gap-3 px-5 py-3 sm:pt-5">
          <h2 className="type-h3 text-text-primary">{title}</h2>
          <IconButton label="Close" size="sm" icon={<X className="size-4" />} onClick={onClose} />
        </header>
        <div className="min-h-0 flex-1 overflow-y-auto px-5 pb-5">{children}</div>
        {footer && <footer className="border-t border-border-subtle p-4 sm:p-5">{footer}</footer>}
      </div>
    </dialog>
  );
}
