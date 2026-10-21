import Link from "next/link";

export function SiteFooter() {
  return (
    <footer className="site-footer">
      <p>
        Inspired by the traditional marble games of Bangladesh.{" "}
        <Link href="/about">About these games</Link>
      </p>
      <p>
        <Link href="/privacy">Privacy</Link>
      </p>
    </footer>
  );
}
