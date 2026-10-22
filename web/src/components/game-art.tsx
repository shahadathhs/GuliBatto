import { card, diagram } from "@/lib/content";
import { Diagram } from "./diagram";

/** The diagram of a game's card, as a picture. */
export function GameArt({ cardId }: { cardId: string }) {
  const c = card(cardId);
  return <Diagram data={diagram(c.diagram)} label={`${c.title}: how the ground looks.`} />;
}
