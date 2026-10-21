# Gameplay Features

This file describes what the player should experience, not how every script must implement it. Technical boundaries are in [`README_ARCHITECTURE.md`](README_ARCHITECTURE.md).

## 1. Core play loop

1. Choose a mode and start a short match.
2. Inspect the play surface and the marbles on it (the holes, the line, the other sides' marbles).
3. Adjust the camera to judge angle and distance.
4. Drag the active striker to aim and set power.
5. Release to shoot; marbles roll and collide without further input.
6. Watch the result, understand the score/turn change, and take the next shot.
7. Finish the match and choose rematch or return to mode selection.

The game must make it obvious whose turn it is, which marble is the striker, what a shot will roughly do, and why a point was awarded.

## 2. Aiming and shooting

### Touch

- Drag directly from the active striker marble to aim.
- Use a slingshot convention: pulling back from the intended travel direction aims the striker in the opposite direction. The arrow must make this unambiguous.
- Drag distance controls power, capped at a clearly visible maximum.
- A minimum dead zone prevents accidental shots.
- Releasing commits the shot. A clear cancel action is available while aiming.
- While aiming, the camera does not orbit. The active gesture owns the pointer until release/cancel.

### Desktop

- Left mouse drag beginning on the active striker aims and sets power.
- Right or middle mouse drag on empty arena space orbits the camera.
- Mouse wheel zooms.
- A visible reset-camera control restores the default view. Keyboard shortcuts may supplement, but not replace, visible controls.

### Aim feedback

- A ground-plane arrow indicates shot direction.
- A power indicator grows within a fixed limit.
- Optional predicted-path feedback should be conservative. Do not promise a precise bounce trajectory unless it actually models collision and friction well.
- Invalid or cancelled aiming resets the preview without changing game state.

## 3. Camera system

All views use one camera rig and the same active camera projection/world.

- **Angled play view:** default perspective with enough ground visible to read the board.
- **Top-down view:** useful for placement and tactical judgement.
- **Low ground view:** cinematic inspection, constrained so the camera cannot pass below the surface or clip through the arena.
- **Shot-follow view:** briefly tracks the active shot, then eases back to the player's prior view or a stable arena view.

Player-controlled camera actions:

- Orbit horizontally around a target.
- Adjust elevation within safe limits.
- Zoom in/out within a bounded distance.
- Reset to a known framing.
- Switch view preset or toggle action-follow behaviour.

Camera motion must not change aim input, pause the simulation unexpectedly, or alter the physical result. It should ease between presets rather than snap unless the player requests a reset.

## 4. Marble behaviour

- The striker responds immediately to a committed shot.
- Marbles visibly roll and rotate rather than sliding as texture-only spheres.
- Head-on hits transfer more forward momentum than glancing hits.
- Friction gradually reduces movement and the board reaches an unambiguous settled state.
- Arena boundaries behave consistently and cannot be crossed due to obvious collider gaps.
- Near-zero jitter should not block the next turn indefinitely.
- Marbles have enough visual contrast to distinguish sides without requiring player avatars.

The game may stylise physics for enjoyable play. If so, use repeatable tuning and preserve cause-and-effect; do not change rules or physics silently between camera views or devices.

## 5. Opponent behaviour

For the AI opponents (one to three sides):

- It takes legal turns and uses the same shot interface as the player.
- It aims at obvious targets (in Batto, its next hole, or a rival marble when a hit looks worthwhile) and adjusts power based on rough distance.
- It occasionally misses; perfect shots every turn are not fun or credible.
- It does not see hidden information (if any is introduced later) or manipulate the board.
- It does not need a language model, remote service, or machine learning.

Start with a transparent heuristic: generate a small number of candidate directions/powers, estimate simple outcomes or use a few target-based heuristics, choose one, then add configurable inaccuracy. A sophisticated search algorithm is not a prerequisite.

## 6. Modes and progression

### MVP

- **Kep** — the toss at the hole: every side tosses from behind the jalla, closest to the kep scores, a set number of rounds. The shortest mode and the opening of the other two.
- **Batto** — a race for 2 to 4 sides along three holes and back (H1, H2, H3, H2, H1), with an opening toss, bonus shots for a hit or for reaching a hole, and a finishing order.
- **Guli Khela** — the line, the hole, the stake and the _baad_ marble: stake marbles are scattered around the kep, a side names one _baad_ and must touch exactly one other marble, a wrong touch costs a fine, the winner of a round takes every marble on the ground, and marbles are won and lost across rounds.
- **Quick Dan** (optional) — one round of Guli Khela for a short session.
- Every mode plays against one to three AI opponents. Details are in [`README_GAME_RULES.md`](README_GAME_RULES.md); where the rules come from is on the About page ([`README_ABOUT.md`](README_ABOUT.md)).
- Difficulty setting for opponent aim error only if it can be implemented and tested cheaply.
- Local settings and small local match statistics.

### Later, only if players ask for it

- Local pass-and-play / hot-seat turns.
- More arena surfaces with meaningful friction differences.
- Practice mode with no score.
- Additional locally verified rule variants.
- Cosmetic marble materials, if they do not reduce readability.

No online multiplayer, remote profile, cloud save, or online leaderboard is part of the current product.

## 7. Interface and feedback

In-match HUD should keep only essential information visible:

- mode name and the current objective;
- active side/turn, with that side's marble mark;
- the standings the mode needs: **Kep** the points and round, **Batto** each side's position on the route (H1 → H2 → H3 → H2 → H1) and who has finished, **Guli Khela** each side's purse and the pot on the ground, plus the named _baad_ marble;
- aim/power feedback;
- camera reset/view controls;
- pause/restart (and Surrender in Guli Khela).

In Guli Khela, before each throw the active side **names the baad marble** by tapping one marble; the marble is marked with a drawn cross and the call is shown in text. The shot is blocked until a marble is named.

The modes carry no authenticity labels. A link to the About page is on the menu, and the rule text of a mode states the rule only.

After a shot, use concise feedback such as “In the kep”, “Hit, one more shot”, “Reached hole 2, one more shot”, “Dan won”, “Fine: touched the baad marble”, “No touch”, or “Your turn”. Keep a short result pause so the player can understand the outcome before the next aim begins. All feedback must be derived from the evaluated board state, not guessed from a sound or visual effect.

## 8. Accessibility and comfort

- Offer camera reset at any time.
- Do not require tiny touch targets for common actions.
- Keep the active striker visually distinct and clearly marked.
- Use motion for the camera sparingly; shot-follow should be toggleable or skippable.
- Do not rely on colour alone to identify sides; combine colour with pattern, marker, or shape accents.
- Make sound supplementary: scoring must remain understandable when audio is muted.
- Provide a pause path that reliably cancels unfinished aim gestures.

## 9. Feature acceptance checklist

A feature is not done simply because it appears in a scene. It is done when it behaves correctly after reset/restart, is clear without developer explanation, and is tested on the required input/platform combinations. See [`README_IMPLEMENTATION.md`](README_IMPLEMENTATION.md).
