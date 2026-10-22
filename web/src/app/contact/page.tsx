import type { Metadata } from "next";
import { SectionList } from "@/components/blocks";
import { page, sections } from "@/lib/content";

export const metadata: Metadata = { title: "Contact" };

export default function ContactPage() {
  const p = page("contact");
  return (
    <main className="page">
      <h1>{p.title}</h1>
      <div className="split prose">
        <SectionList sections={sections(p.blocks)} />
      </div>
    </main>
  );
}
