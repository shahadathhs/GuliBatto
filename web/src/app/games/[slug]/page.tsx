import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { Blocks, Figure } from "@/components/blocks";
import { GAMES, card, game, page } from "@/lib/content";
import { hasPlayBuild } from "@/lib/play-build";

export const dynamicParams = false;

export function generateStaticParams() {
  return GAMES.map((g) => ({ slug: g.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const g = game((await params).slug);
  if (!g) return {};
  const first = page(g.page).blocks.find((b) => b.type === "paragraph");
  return { title: card(g.card).title, description: first?.type === "paragraph" ? first.text : "" };
}

export default async function GamePage({ params }: { params: Promise<{ slug: string }> }) {
  const g = game((await params).slug);
  if (!g) notFound();
  const p = page(g.page);
  const c = card(g.card);
  const lede = p.blocks.find((b) => b.type === "paragraph");
  const hero = p.blocks.find((b) => b.type === "diagram");
  const rest = p.blocks.filter((b) => b !== lede && b !== hero);
  const play = hasPlayBuild();
  return (
    <main className="page">
      <section className="game-head">
        <div>
          <p className="caption">
            <Link href="/games">The games</Link>
          </p>
          <h1>{p.title}</h1>
          {lede?.type === "paragraph" && <p className="lede">{lede.text}</p>}
          <div className="cta-row">
            <Link className="btn-primary" href={play ? "/play" : "/download"}>
              {play ? "PLAY IN YOUR BROWSER" : "GET THE APP"}
            </Link>
          </div>
        </div>
        {hero?.type === "diagram" && <Figure id={hero.id} caption={hero.caption} />}
      </section>

      <div className="game-body">
        <article className="prose">
          <Blocks blocks={rest} />
        </article>
        <aside className="aside">
          <h2 className="caption">At a glance</h2>
          <ul>
            {c.lines.map((line) => (
              <li key={line}>{line}</li>
            ))}
          </ul>
          <h2 className="caption">The other games</h2>
          <ul className="plain">
            {GAMES.filter((o) => o.slug !== g.slug).map((o) => (
              <li key={o.slug}>
                <Link href={`/games/${o.slug}`}>{card(o.card).title}</Link>
              </li>
            ))}
          </ul>
          <p>
            <Link href="/how-to-play">Controls and words</Link>
          </p>
        </aside>
      </div>
    </main>
  );
}
