# Game Rules: Evidence and Proposed Modes

## 1. Important distinction

This project draws inspiration from Bangladeshi marble play, but it must not claim that a proposed game rule is a historically authentic version unless it has been checked against reliable sources and people familiar with local play.

Banglapedia's “Folk Games” entry describes **Gulikhela** as a marble game. It describes players standing roughly nine to ten feet from a hole, throwing marbles toward the hole, keeping marbles that reach it, and then trying to hit other marbles; failure can cost a marble and the turn. This is a published description, not proof that every community used those exact dimensions or penalties.

As of the research review on 2026-10-21, the public sources checked did **not** establish a standard set of rules under the exact game name **“Batto”**. That is not proof that the local game does not exist: it may be known orally, have a regional spelling/name, or have rules poorly represented online. Treat it as a research question, not a blank to fill with invented facts.

Source: Banglapedia, “Folk Games”: <https://en.banglapedia.org/index.php?title=Folk_Games>

## 2. Mode A — Guli Khela (adapted pit-and-strike)

**Status:** a playable adaptation based on the published Gulikhela description, not a claim of exact traditional fidelity.

### Equipment and arena

- One striker marble for the active side.
- A small set of target marbles.
- A shallow pit/hole or clearly readable target recess in a bounded dirt play surface.
- A marked starting line at a configurable distance. A real-world reference of approximately nine to ten feet appears in the cited source, but the digital arena can use a scaled distance chosen for readability and validated game feel.

### Proposed turn flow

1. The active player receives a striker and sees the current board.
2. The player aims and chooses shot power.
3. Releasing the aim gesture fires one shot.
4. All relevant marbles roll until the board is settled.
5. The ruleset checks whether a target marble entered the pit/goal and whether a target marble was struck according to the chosen mode configuration.
6. Score and turn continuation are resolved once, then the next turn begins.

### MVP scoring proposal

For clarity and quick play, use the following as an initial digital rule profile; it is a design choice, not a claim about all traditional play:

- A target marble that comes to rest in the pit/goal is claimed for one point.
- A clean legal hit on a target marble outside the pit earns one point if the mode's “strike to claim” option is enabled.
- A miss ends the turn.
- The match ends when all target marbles are claimed or the configured turn limit is reached. The highest score wins; a tie is a tie.
- Until the AI exists (Implementation Milestone 3), the mode runs as a single-side score attack: one player takes every turn until the limit or until all targets are claimed, and the result is the final score.
- "In the pit" means the board snapshot shows the marble resting with its centre inside the pit radius. A marble that rolls through the pit and out is not claimed.

Avoid combining every traditional variation at once. Initially expose at most one clearly named variant. Once local play research is complete, either change the defaults to reflect the chosen local variant or add a separately labelled “Classic-inspired” variant.

### Questions to validate with real players

- Are marbles thrown first and then struck, or are players required to use a particular shot technique?
- Does a hole/pit exist in the remembered local variant? What size and distance are usual?
- Are marbles won/kept physically, or is the purpose only to score?
- What counts as a legal hit, a miss, a foul, or a lost turn?
- Are there named regional variations the game should acknowledge?

Do not hard-code the disputed answers across multiple scripts. Keep the agreed version in a mode profile.

## 3. Mode B — Batto Challenge (provisional rules)

**Status:** a custom digital mode intended to share the same marble-and-shooting system. Its name and traditional accuracy are not verified.

The prototype should differentiate it mechanically from Guli Khela without pretending the design proposal is historical. Before public release, ask local players who use the name “Batto” what objects are used, how a turn works, and what determines the winner. Record the source of the account and any disagreement between regions.

### Prototype rule proposal: circle knockout

- Each side has a coloured/marked set of marbles in a ring-shaped play area.
- Sides alternate one shot at a time using their striker.
- A shot aims to displace opposing marbles beyond the ring boundary while keeping one's own target marbles inside.
- Each opposing marble that finishes fully outside the boundary scores one point for the active side.
- A striker leaving the play area does not score; the active turn ends after all marbles settle.
- A marble that crosses the line and rolls back inside is not out; status is evaluated after the board settles.
- The mode ends when one side has no target marbles left or the turn limit is reached. Highest score wins.

This is a **gameplay proposal only**. It can be renamed if research shows that “Batto” refers to different play. Do not describe it as a preserved traditional ruleset in store copy until verified.

## 4. Shared rules and legal shot definition

- A human or local AI may take a shot only when the match state is `WAITING_FOR_SHOT` and the current side is valid.
- A shot has a normalised ground-plane direction and a bounded power value.
- The aim system has a dead zone; releasing within it cancels instead of applying a tiny accidental impulse.
- Once fired, no new aim input is accepted until settlement and rule evaluation finish.
- The game evaluates the whole final board once after settlement. Collision callbacks are evidence of contact, not a direct scoring instruction.
- The striker may not be moved by the player after release.
- Camera position and camera mode never affect the shot vector, power, collisions, or score.
- A reset/restart restores the initial layout and score atomically; it does not reuse partial turn state.

## 5. Round lifecycle

```text
New match
  -> Create arena and place marbles
  -> Show current side and objective
  -> Player / AI aims
  -> Validate and commit one shot
  -> Simulate until settled
  -> Snapshot board
  -> Evaluate score, penalties, and end condition
  -> Show short result cue
  -> Next turn OR match result
```

## 6. Rules data that should be configurable

- Starting layout and player ownership.
- Pit/goal position and size (for modes that need one).
- Play boundary shape.
- Shot and turn limits.
- What counts as claimed, out, or fouled.
- Score values and tie-break policy.
- Whether a successful action retains the turn.

Do not make a full generic rules engine. Keep two small, readable rulesets behind a shared match lifecycle.

## 7. Research protocol before calling rules authentic

1. Ask at least two people who have personally played the game, ideally from different localities or generations.
2. Ask them to demonstrate or draw the play area and walk through a complete turn, including a miss and a foul.
3. Record local names/spellings for pieces and actions; ask whether variants have different names.
4. Compare accounts and distinguish consensus from disagreement.
5. Where practical, record a short demonstration with consent; do not publish personal footage without permission.
6. Update this document with a dated “verified local variant” section and clearly attribute the account (for example, locality and interview date, with permission), while retaining sources for broader claims.

Until then, labels such as “adapted”, “inspired by”, and “provisional” are more accurate than “authentic original rules”.
