import type { Metadata } from "next";
import { Reveal } from "@/components/reveal";
import { SiteFooter } from "@/components/site-footer";
import { SITE_URL } from "@/lib/site";
import { SiteHeader } from "@/components/site-header";
import "./tokens.css";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: { default: "Guli & Batto", template: "%s · Guli & Batto" },
  description:
    "A small offline 3D marble game made from the traditional marble games of Bangladesh. Aim, shoot, and watch the marbles roll.",
  openGraph: { siteName: "Guli & Batto", type: "website" },
};

// Applies a saved theme choice before the first paint, so the page never flashes the wrong theme.
const THEME_SCRIPT = `try{var t=localStorage.getItem("theme");if(t==="light"||t==="dark")document.documentElement.setAttribute("data-theme",t)}catch(e){}`;

export default function RootLayout({ children }: { children: React.ReactNode }) {
  // The theme script sets data-theme before React loads, so the attribute differs by design.
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: THEME_SCRIPT }} />
      </head>
      <body>
        <a className="skip-link" href="#main">
          Skip to content
        </a>
        <SiteHeader />
        <div id="main">{children}</div>
        <SiteFooter />
        <Reveal />
      </body>
    </html>
  );
}
