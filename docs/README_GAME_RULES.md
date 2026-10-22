# Game Rules: Where They Come From and the Four Modes

> **Status:** direction set on 2026-10-21; the Batto and Guli Khela rules were settled the same day. Every mode starts from a game that people actually played. The author modified the rules for play on a phone, and those modifications are listed openly in each mode ("Changed for digital play"). There are no per-mode labels in the game; the honesty lives in one central page, [README_ABOUT.md](README_ABOUT.md). Values marked _initial_ are starting numbers to tune, and "To confirm with players" lists what could change after talking to people who played.

## 1. Where the rules come from

| Source                          | What it is                                                                                                                                                                                                                                                               | Used for                   |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------- |
| **A. The author's memory**      | The author's own account of the three-hole game, recorded 2026-10-21                                                                                                                                                                                                     | Batto                      |
| **B. A written Bangla account** | A written description of a game with a line (_jalla_ or _joi_), a hole (_kep_), a stake of marbles, a _baad_ marble and a fine. The author provided it on 2026-10-21; its rules are paraphrased in this document, never quoted                                           | Kep, Guli Khela            |
| **C. Banglapedia**              | "Folk Games", the Gulikhela entry: <https://en.banglapedia.org/index.php?title=Folk_Games>. Players stand roughly nine to ten feet from a hole, throw marbles toward it, keep those that reach it, then try to hit other marbles; failure can cost a marble and the turn | Cross-check for Guli Khela |

These are accounts, not a single authority. The same game is played differently from place to place, so none of them is called "the rules", and the game never claims to be official or authentic. It says where each game comes from on the About page, and it uses the words the accounts use: _jalla_ (line), _kep_ (hole), _dan_ (a round), _baad_ (the excluded marble), _fine_.

## 2. The four modes

|                              | **Kep**                                  | **Batto**                                                     | **Guli Khela**                                     | **Quick Dan**                               |
| ---------------------------- | ---------------------------------------- | ------------------------------------------------------------- | -------------------------------------------------- | ------------------------------------------- |
| Comes from                   | Account B (the opening toss)             | Account A                                                     | Accounts B and C                                   | Account B (one round)                       |
| Shape                        | Toss at the hole; closest wins           | Race along three holes and back                               | Stake marbles; touch exactly one, never the _baad_ | One round of Guli Khela                     |
| Sides                        | 2 to 4 (you plus 1 to 3 AI)              | 2 to 4                                                        | 2 to 4                                             | 2 to 4                                      |
| Key decision                 | Judging distance and power               | Hole or hit: aim ahead, or send a rival away for a bonus shot | Which marble is _baad_, and a clean single touch   | The same, with no long-term stakes          |
| Keeps marbles between rounds | No, it is scored                         | No, it is ranked                                              | **Yes**, play for keeps                            | No, one stake, one winner                   |
| Ends when                    | After a set number of rounds             | All but one have finished                                     | One side is out of marbles or surrenders           | The round is won                            |
| Result                       | Points, then ranking                     | Finishing order; the last loses                               | Marble counts; the last with marbles wins          | The winner takes the pot                    |
| Role                         | Quick, simplest, shares the opening toss | The race                                                      | The full traditional game                          | A short session of the full game (optional) |

Order of building: **Kep** (smallest, and its toss is the opening of the other two), then **Batto**, then **Guli Khela**, then **Quick Dan** if short sessions need it. The modes must ask for different decisions. If two of them feel like the same rule, cut the weaker one rather than adding a fifth.

## 3. Shared rules

- A shot may be taken only when the match state accepts one, and only by the side whose turn it is. A shot has a ground-plane direction and a bounded power. Releasing inside a small dead zone cancels instead of firing.
- Once fired, no aim input is accepted until the board settles and the shot is evaluated. The marble cannot be moved by the player after release.
- **Evaluation happens once, on the settled board.** A ruleset reads a `BoardSnapshot` (where every marble rests) and a `ShotReport` (which marbles the shooter's marble touched, in order). Contact callbacks only feed the report; they never score.
- **Touch and hit.** A _touch_ is the shooter's marble contacting another marble during its own shot, as recorded in the report. A marble that is only nudged by a third marble is not touched by the shooter. In Batto a touch of a rival's marble is a _hit_.
- **In the kep (or a hole)** means the settled board shows the marble resting with its centre inside the hole radius. Rolling through and out is not in.
- Marbles that leave the bounded arena are put back where they left it, on the boundary. (_Changed for digital play._)
- Camera position and mode never affect the shot, the physics or the result.
- A restart builds a fresh match; it never reuses partial turn state.
- The arena has a **jalla** (a drawn line to stand behind) and one or more holes, drawn on bare earth.

### Opening toss (Kep, Batto, Guli Khela)

Every side tosses one marble from behind the jalla toward the first hole. When the board settles, sides are ordered by distance to that hole, closest first, and a marble resting in the hole counts as closest. This order starts the match (or the round). Tosses are not touches.

## 4. Kep — the toss

**From:** Account B. The toss that decides who goes first becomes a short mode of its own.

- **Arena:** the jalla and one kep, at a distance (_initial:_ about 4 to 5 hand-lengths, scaled for readability).
- **Round:** every side tosses one marble from behind the jalla. After settling, a marble in the kep scores 3 points and otherwise the closest scores 2; the second closest scores 1. Ties share the higher score.
- **Match:** a set number of rounds (_initial:_ 5). Highest total wins; ties are shared. Sides take the toss in order of the previous round's result, worst first (_changed for digital play_, so the leader does not get an edge).
- **Changed for digital play:** the points and the number of rounds. The source only says that the closest goes first.
- **To confirm with players:** how the toss is thrown (rolled, thrown or flicked), whether the toss may touch another marble, and whether a marble in the kep wins outright.

## 5. Batto — the three-hole race

**From:** Account A (the author's memory).

> Three holes. Players first toss from a distance toward a hole; everyone tries to get as close as possible. The closest goes first, then the order follows. Play goes from the first hole to the second, then the third, and then comes back toward the first in reverse. Along the way a player can try to hit another player's marble to knock it far away. If the hit connects, the hitter gets one more move toward the next hole. The last player who fails to reach the hole fails.

- **Arena:** a jalla and three holes in a line, H1, H2 and H3.
- **Start:** the opening toss toward H1 orders the sides.
- **Route:** H1 → H2 → H3 → H2 → H1, five legs. Each side has a progress index naming the hole it must reach next. A side is **finished** when its marble rests in H1 on the last leg.
- **Turn:** the side shoots its own marble from where it lies. A shot that ends with the marble resting in its target hole advances the progress index; resting in any other hole does nothing.
- **Bonus shots:** the shooter takes **one more shot** after either of these, evaluated from the settled board:
  - the shot was a **hit** (the shooter's marble touched a rival's marble), or
  - the shot **reached the target hole**.
    A bonus shot that earns a bonus shot chains. Chains are capped at three bonus shots in a turn (_changed for digital play_). A side that has just finished gets no bonus shot.
- **A hit rival** is knocked away by the physics; there is no scripted penalty.
- **End:** the match ends when all but one side have finished; the side still on the route is last. Finishing order is the result. A side that finishes leaves the ground, so it cannot block the last hole or be hit.
- **Opening toss counts:** a toss that comes to rest in H1 has reached H1, so that side starts the race heading for H2. A toss gives no bonus shot, and touching another marble during it changes nothing.
- **Turn cap:** after every unfinished side has taken its turn cap, the race stops and the sides still on the route are ranked by how far along the route they are, then by how close their marble is to the hole they were heading for.
- **Changed for digital play:** the bonus-shot cap, a turn cap per side (_initial:_ 40) and how it ends a race, finished marbles leaving the ground, a first toss in H1 counting as reaching it, the return of marbles that leave the arena to the boundary, and the fixed hole spacing (about 1.25 m apart in a line, H1 nearest the jalla).
- **To confirm with players:** whether the route is really five legs; the hole layout and spacing; whether a marble resting in a hole can be hit.

## 6. Guli Khela — kep and baad

**From:** Account B, with Account C as a cross-check.

- **Arena:** a jalla (the line to stand behind) and one kep (the hole), four to five hand-lengths away in the source, scaled here for readability.
- **Purse:** each side starts with a purse of marbles (_initial:_ 10) and pays a stake to start each dan. Each side also has its own **throwing marble**, which is not part of the purse and always goes back to its owner after a throw.
- **Dan** (one round, played in passes):
  1. **Opening toss** from behind the jalla. The closest side (a marble in the kep counts as closest) is the **scatterer** and collects the stake from every side (_initial:_ 3 marbles each, configurable from 2 to 4).
  2. **Scatter:** the stake marbles are placed gently around the kep. The game does this with a seeded layout; the scatterer plays no shot.
  3. **A pass:** each other side, in turn order, gets **one attempt**. It first **names the baad marble** (tap one; a throw without a named baad is refused), then throws its marble from behind the jalla. The evaluated shot decides:
     - **Exactly one other marble touched, and it is not the baad marble:** the side **wins the dan**.
     - **The baad marble touched, or two or more marbles touched:** a **fine**. The side adds one marble from its purse to the ground. A side with an empty purse pays nothing. The attempt ends; it does not win.
     - **No marble touched:** a plain miss. The attempt ends.
  4. Marbles stay where they come to rest; the next attempt is played on the same ground, which now includes any fined marbles. A throw that ends with the throwing marble in the kep has no special effect.
- **Winning a dan:** the winner takes **all the marbles on the ground**: the stake, every fine, and any other marbles in play. Their own throwing marble goes back to them. A new dan then begins with a new opening toss, and a new scatterer.
- **If every other side fails:** the pass ends with no winner. A new pass starts on the same ground, now larger with any fines. After **three passes** (_initial_) with no winner, the **scatterer wins the dan** and takes the ground, because the ground was held against everyone. In a two-side match, this means the other side has three attempts to touch exactly one marble.
- **End of the match:**
  - A side that cannot pay the stake at the start of a dan, or that surrenders, is out.
  - The match ends when one side remains, or at the dan limit (_initial:_ 20), when the side with the most marbles wins.
- **Marbles that leave the arena** are put back on the boundary where they left.
- **Changed for digital play:** the game scatters the marbles; the fine is exactly one marble; the winner takes the whole ground; the three-pass limit; the purse and stake sizes; the dan limit; and a Surrender button.
- **To confirm with players:** what a fine costs where they played, the usual stake (2, 3 or 4), and whether the scatterer always keeps the ground when nobody touches.

## 7. Quick Dan — one round

**From:** Account B, one dan on its own. It is a profile of Guli Khela, not a separate ruleset.

- The same opening toss, stake, scatter, _baad_ call and fines, but the match ends after the first dan is won. Purses reset for the next match. It is built only if short sessions need it.

## 8. Round lifecycle

```text
New match
  -> Create arena for the mode (jalla, kep or holes)
  -> Opening toss; order sides by closeness
  -> (Guli Khela) stake into the pot and scatter around the kep
  -> Show whose turn it is and the objective
  -> (Guli Khela) name the baad marble
  -> Player / AI aims
  -> Validate and commit one shot
  -> Simulate until settled
  -> Snapshot board + shot report
  -> Evaluate score, progress, win, fine, bonus shot, end (once)
  -> Show short result cue
  -> Same side again OR next side OR next dan OR match result
```

## 9. Rules data that should be configurable

- Number of sides, purse size and stake size.
- Jalla position; hole positions and radii; boundary shape.
- Route (an ordered list of hole indices) for Batto.
- Kep points, number of rounds.
- Bonus-shot and chain caps, fine size, dan limit, turn caps.
- What counts as in a hole, a touch or a hit.
- Score values and tie-break policy.

Do not build a generic rules engine. Keep four small, readable rulesets (Quick Dan is a profile) behind one shared match lifecycle.

## 10. Checking the rules with people

1. Show the written rules for a mode to at least two people who played it, ideally from different places or generations.
2. Ask them to draw the play area and walk through a complete round, including a miss, a touch and a fine.
3. Record local names and spellings of the line, hole, pieces and actions; ask whether variants have other names.
4. Compare accounts and keep the author's choices separate from what people agree on.
5. Where practical, record a short demonstration with consent; never publish footage of people without permission.
6. Change the rules or the About page to reflect what was learned, and record who said it (locality and date, with permission).

The game does not wait for this to ship, because it never claims to be the official rules; but each answer should make the game more faithful to the people who played it.
