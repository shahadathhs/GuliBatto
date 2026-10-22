import Link from "next/link";
import { type Block, type Section, diagram, hrefFor } from "@/lib/content";
import { Diagram } from "./diagram";

// Renders a page's blocks, the same ones the game draws with PageBlocks.

function LinkRow({ links }: { links: Extract<Block, { type: "link" }>[] }) {
  const shown = links.flatMap((l) => {
    const href = hrefFor(l);
    return href ? [{ label: l.label, href }] : [];
  });
  if (shown.length === 0) return null;
  return (
    <p className="link-row">
      {shown.map(({ label, href }) =>
        href.startsWith("/") ? (
          <Link key={href + label} className="btn-secondary" href={href}>
            {label}
          </Link>
        ) : (
          <a key={href + label} className="btn-secondary" href={href}>
            {label}
          </a>
        ),
      )}
    </p>
  );
}

export function Figure({ id, caption }: { id: string; caption: string }) {
  return (
    <figure className="figure">
      <Diagram data={diagram(id)} label={caption} />
      <figcaption>{caption}</figcaption>
    </figure>
  );
}

/** Blocks in order; consecutive terms, questions and links are grouped. */
export function Blocks({ blocks, skipDiagram }: { blocks: Block[]; skipDiagram?: string }) {
  const out: React.ReactNode[] = [];
  for (let i = 0; i < blocks.length; i++) {
    const b = blocks[i]!;
    const run = <T extends Block["type"]>(type: T) => {
      const items: Extract<Block, { type: T }>[] = [];
      while (blocks[i]?.type === type) items.push(blocks[i++] as Extract<Block, { type: T }>);
      i--;
      return items;
    };
    switch (b.type) {
      case "heading":
        out.push(<h2 key={i}>{b.text}</h2>);
        break;
      case "paragraph":
        out.push(<p key={i}>{b.text}</p>);
        break;
      case "list":
        out.push(
          <ul key={i}>
            {b.items.map((t) => (
              <li key={t}>{t}</li>
            ))}
          </ul>,
        );
        break;
      case "steps":
        out.push(
          <ol key={i} className="steps-list">
            {b.items.map((t) => (
              <li key={t}>
                <span>{t}</span>
              </li>
            ))}
          </ol>,
        );
        break;
      case "diagram":
        if (b.id !== skipDiagram) out.push(<Figure key={i} id={b.id} caption={b.caption} />);
        break;
      case "term": {
        const terms = run("term");
        out.push(
          <dl key={i} className="terms">
            {terms.map((t) => (
              <div key={t.term}>
                <dt>{t.term}</dt>
                <dd>{t.text}</dd>
              </div>
            ))}
          </dl>,
        );
        break;
      }
      case "qa": {
        const qas = run("qa");
        out.push(
          <div key={i} className="faq">
            {qas.map((q) => (
              <details key={q.q}>
                <summary>{q.q}</summary>
                <p>{q.a}</p>
              </details>
            ))}
          </div>,
        );
        break;
      }
      case "link": {
        out.push(<LinkRow key={i} links={run("link")} />);
        break;
      }
    }
  }
  return <>{out}</>;
}

/** The contents list of a long page: a link to each section heading. */
export function Contents({ sections }: { sections: Section[] }) {
  const titled = sections.filter((s) => s.title);
  return (
    <nav className="contents" aria-label="On this page">
      <p className="caption">On this page</p>
      <ol>
        {titled.map((s) => (
          <li key={s.id}>
            <a href={`#${s.id}`}>{s.title}</a>
          </li>
        ))}
      </ol>
    </nav>
  );
}

/** A page's sections, each with an anchor. */
export function SectionList({
  sections,
  skipDiagram,
}: {
  sections: Section[];
  skipDiagram?: string;
}) {
  return (
    <>
      {sections.map((s) => (
        <section key={s.id} id={s.id} className="sec">
          {s.title && <h2>{s.title}</h2>}
          <Blocks blocks={s.blocks} skipDiagram={skipDiagram} />
        </section>
      ))}
    </>
  );
}
