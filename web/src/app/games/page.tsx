import type { Metadata } from "next";
import Link from "next/link";
import { GameArt } from "@/components/game-art";
import { GAMES, card } from "@/lib/content";

export const metadata: Metadata = {
  title: "The games",
  description: "Kep, Batto, Guli Khela and Quick Dan: four marble games, each with its own ground.",
};

export default function GamesPage() {
  return (
    <main className="page">
      <h1>The games</h1>
      <p className="lede">
        Four games with the same controls. Each has its own ground, its own way to score and its own
        end.
      </p>
      <ul className="game-rows">
        {GAMES.map((g) => {
          const c = card(g.card);
          return (
            <li key={g.slug} className="game-row">
              <div className="art">
                <GameArt cardId={g.card} />
              </div>
              <div>
                <h2>{c.title}</h2>
                <ul>
                  {c.lines.map((line) => (
                    <li key={line}>{line}</li>
                  ))}
                </ul>
                <p>
                  <Link className="btn-secondary" href={`/games/${g.slug}`}>
                    Rules for {c.title}
                  </Link>
                </p>
              </div>
            </li>
          );
        })}
      </ul>
    </main>
  );
}
