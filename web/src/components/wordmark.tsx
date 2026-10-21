import Link from "next/link";

export function Wordmark() {
  return (
    <Link href="/" className="wordmark" aria-label="Guli & Batto, home">
      GULI <span>&amp;</span> BATTO
    </Link>
  );
}
