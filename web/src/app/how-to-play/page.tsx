import type { Metadata } from "next";
import { Contents, SectionList } from "@/components/blocks";
import { page, sections } from "@/lib/content";

export const metadata: Metadata = {
  title: "How to play",
  description:
    "Take a shot, read the result, and learn the four games: Kep, Batto, Guli Khela and Quick Dan.",
};

export default function HowToPlayPage() {
  const p = page("how_to_play");
  const parts = sections(p.blocks);
  return (
    <main className="page reading">
      <Contents sections={parts} />
      <article className="prose">
        <h1>{p.title}</h1>
        <SectionList sections={parts} />
      </article>
    </main>
  );
}
