import type { Metadata } from 'next';
import { Archivo, JetBrains_Mono } from 'next/font/google';
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
  // No `data-theme` — dark is the unstyled default (design-system.md §1).
  return (
    <html lang="en">
      <body className={`${archivo.variable} ${jetbrainsMono.variable}`}>
        <div className="mx-auto min-h-dvh max-w-[1120px] px-4 py-8 sm:px-8">{children}</div>
      </body>
    </html>
  );
}
