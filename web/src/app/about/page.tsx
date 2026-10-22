import type { Metadata } from "next";
import { Contents, SectionList } from "@/components/blocks";
import { page, sections } from "@/lib/content";

export const metadata: Metadata = {
  title: "About these games",
  description:
    "Where the rules of Guli & Batto come from, and what the author changed for play on a phone.",
};

// The text is content/pages/about.json, shown here and in the game; `make content-check` compares
// it with docs/README_ABOUT.md.
export default function AboutPage() {
  const p = page("about");
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
