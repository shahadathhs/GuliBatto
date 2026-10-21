import type { Metadata } from "next";
import Link from "next/link";
import "./tokens.css";
import "./globals.css";

export const metadata: Metadata = {
  title: { default: "Guli & Batto", template: "%s · Guli & Batto" },
  description:
    "A small offline 3D marble game inspired by the traditional marble games of Bangladesh. Aim, shoot, and watch the marbles roll.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <header>
          <Link className="brand" href="/">
            Guli &amp; Batto
          </Link>
          <nav>
            <Link href="/how-to-play">How to play</Link>
            <Link href="/about">About</Link>
            <Link href="/download">Download</Link>
            <Link href="/privacy">Privacy</Link>
          </nav>
        </header>
        {children}
        <footer>
          Inspired by the traditional marble games of Bangladesh.{" "}
          <Link href="/about">About these games</Link>
        </footer>
      </body>
    </html>
  );
}
