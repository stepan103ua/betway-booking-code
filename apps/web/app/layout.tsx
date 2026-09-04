import type { Metadata } from 'next';
import { Archivo, JetBrains_Mono } from 'next/font/google';
import { ModeTabs } from '@/components/mode-tabs';
import './globals.css';

// Archivo (UI) + JetBrains Mono (odds, codes) — design-system.md §3. No font binaries were
// supplied, so both pull from Google Fonts, same as apps/mobile via `google_fonts`.
const archivo = Archivo({ subsets: ['latin'], variable: '--font-archivo', display: 'swap' });
const jetbrainsMono = JetBrains_Mono({
  subsets: ['latin'],
  variable: '--font-jetbrains-mono',
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'Betway Booking Code',
  description: 'Decode, create and convert Betway Nigeria booking codes.',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  // No `data-theme` — dark is the unstyled default (design-system.md §1). Wordmark + the
  // Decode/Create/Convert mode switch (design-system.md §4) are the whole shell; each screen
  // starts straight into its content and the active tab names it.
  return (
    <html lang="en">
      <body className={`${archivo.variable} ${jetbrainsMono.variable}`}>
        <div className="mx-auto min-h-dvh w-full max-w-[680px] px-4 py-6 sm:px-6 sm:py-10">
          <header className="mb-4 flex items-center gap-2">
            <span className="type-code grid size-[26px] place-items-center rounded-tile bg-accent-solid text-[12px] font-bold text-text-on-accent">
              BC
            </span>
            <span className="type-h2 tracking-[-0.03em] text-text-primary">
              booking<span className="text-text-muted">code</span>
            </span>
          </header>
          <div className="mb-6">
            <ModeTabs />
          </div>
          {children}
        </div>
      </body>
    </html>
  );
}
