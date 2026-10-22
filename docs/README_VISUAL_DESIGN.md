# Guli & Batto — Visual Design Guide

> **Goal:** one visual identity across the Godot game and the website. The 3D arena is the hero; everything around it (HUD, menus, site) stays quiet and legible.  
> **Reference renders:** [design/SCREENS.md](design/SCREENS.md) lists every screen; [overview-light](design/overview-light.png) and [overview-dark](design/overview-dark.png) show them all. They are 2D concept renders: the real arena is 3D, so tune from the running game.  
> **Status:** direction proposed, tokens chosen and contrast-checked, fonts and the 3D art still to be decided. Orientation is **portrait** (390 × 844 reference); that is a proposal to confirm in playtests, because aiming with a thumb and reading the arena both depend on it.

## 1. Design direction: Drawn Ground

Guli and Batto are played on bare earth. The board is whatever you scratch into the dirt: a line to stand behind (the _jalla_), a small hole (the _kep_), a ring. The interface borrows that language. Lines are drawn, shapes are circles, and the only saturated objects are the marbles.

Character: warm, tactile, grounded, quiet. Not a candy-coloured casual game, not a postcard of an "exotic village", not a sci-fi marble simulator.

### Signature elements

- **The disc.** A marble is a disc, the primary button is a disc, the kep is an ellipse, the ring is a circle. Controls that are not the primary action are round icon buttons or outlined rounded rectangles (radius 14). There are no sharp-cornered boxes.
- **Drawn lines.** The play ring, the start line, and the aim line are drawn in the dirt: a 3 px line in `line`/ink at reduced opacity, dashed for lines you stand behind. The same line weight is used for UI outlines (2 px) and the selected mode (4 px).
- **One accent: glaze blue.** It is the player's marble colour and the one primary action. The primary button is a solid glaze disc with `on-glaze` text; when the label is longer than six letters ("Rematch", "Back to match") it is a rounded rectangle instead, never a stretched pill. Glaze is not decoration: the player's marbles and the Play/Start/Rematch button are the same blue, so "the blue thing is mine and is what I do next".
- **Marbles carry the colour, and a mark.** Up to four sides: side 1 (you) = glaze blue with a **ring** mark, side 2 = amber with a **dot**, side 3 = jade with a **bar**, side 4 = plum with a **triangle**. Stake and pot marbles in Guli Khela are plain bone with no mark. Colour is never the only signal; the mark is visible from top-down, angled and low views, and sides 2 to 4 are close in lightness, so the mark is what separates them in grayscale. The active marble also gets a ring on the ground beneath it.
- **Earth is not a UI colour.** Arena materials (earth, rim, hole) are 3D materials chosen by the scene, listed in section 2 only to keep them close to the UI. UI never uses them as text or fills.
- **Wordmark.** `GULI & BATTO`, heavy caps with a lighter ampersand. No logo mark until one earns its place.

### Not allowed (rules for every change)

- No gradients, glow, drop shadows, glass, blur or bevels in the UI. (The 3D marbles may have a specular highlight and a contact shadow; that is the scene, not the UI.)
- No cards inside cards. Group with spacing and a small caption; a mode choice may be one outlined row.
- Exactly **one primary (glaze disc) action per screen**. Secondary actions are outlined rounded rectangles; tertiary actions are underlined text.
- No taglines or marketing eyebrow lines, motivational copy, exclamation marks, or emoji. Do not address the player with questions.
- No decorative "village" motifs, stock folk patterns, or stock ambient sound used as a shortcut for authenticity (see section 11).
- No loops or idle animation in the UI. No UI animation over 250 ms except the shot-follow camera and the result cue.
- No default component-library look on the website (soft pastel badges, heavy shadows).
- Prefer deleting to adding. A screen improves when parts are removed.

### Principles

- **Physics first.** The arena and the marbles are the focal point; the HUD never covers the playing surface.
- **Legibility before decoration.** Whose turn, which marble is the striker, what a shot will do, and why a point was awarded must read at a glance.
- **Consistent meaning.** A mark or shape means the same thing in the game, tutorial, site and store images.
- **Accessible by construction.** Colour is never the only signal; every state also has a shape, mark, number or label.
- **Made for thumbs.** Primary actions sit in the bottom third; common drag areas stay free of buttons.

## 2. Themes and tokens

Light ("Day") and dark ("Dusk") are both first-class. The setting offers System (default), Light and Dark. Shapes and layout do not change; only ground and ink swap, and the marbles keep their hues (the blue and amber lighten in dark so they hold their contrast on the dark ground).

| Token      | Light     | Dark      | Use                                                 |
| ---------- | --------- | --------- | --------------------------------------------------- |
| `ground`   | `#F3EBDD` | `#171310` | Screen background                                   |
| `ink`      | `#2A2017` | `#F3EADB` | Text, outlines, solid chips                         |
| `floor`    | `#FBF6EC` | `#221C16` | Raised surfaces on the site, input fills            |
| `mute`     | `#65553F` | `#B5A38B` | Secondary text, captions                            |
| `line`     | `#8C7658` | `#8C7658` | Hairlines and dividers (graphics only)              |
| `glaze`    | `#1B58B8` | `#6EA8FF` | Accent: primary action, player marbles              |
| `on-glaze` | `#FFFFFF` | `#0F141C` | Text and icons on glaze                             |
| `amber`    | `#E39A12` | `#F2A826` | Side 2 marbles and score                            |
| `on-amber` | `#2A2017` | `#171310` | Marks on amber                                      |
| `jade`     | `#1F7A5C` | `#5CC4A0` | Side 3 marbles and score                            |
| `on-jade`  | `#FFFFFF` | `#0D1A15` | Marks on jade                                       |
| `plum`     | `#7A3E8E` | `#C79AD8` | Side 4 marbles and score                            |
| `on-plum`  | `#FFFFFF` | `#1A1020` | Marks on plum                                       |
| `bone`     | `#E8DCC4` | `#D8C9AC` | Stake and pot marbles (plain, no mark)              |
| `foul`     | `#B23A24` | `#F08A72` | Rule violation and error text, with an icon or word |

Arena materials for the 3D scene (not UI tokens): `earth` `#C9A57A` / `#6B5238`, `earth-rim` `#A98558` / `#4E3B28`, `hole` `#5B4128` / `#241A10`.

Contrast (WCAG ratios computed from these values):

| Pair                                  | Light           | Dark |
| ------------------------------------- | --------------- | ---- |
| `ink` on `ground`                     | 13.5            | 15.5 |
| `ink` on `floor`                      | 14.8            | 14.1 |
| `mute` on `ground`                    | 6.1             | 7.5  |
| `mute` on `floor`                     | 6.7             | 6.9  |
| `on-glaze` on `glaze`                 | 6.7             | 7.7  |
| `on-amber` on `amber`                 | 6.8             | 9.2  |
| `glaze` on `ground`                   | 5.7             | 7.7  |
| `foul` on `ground`                    | 5.0             | 7.5  |
| `line` on `ground` (graphics, need 3) | 3.7             | 4.3  |
| `amber` on `ground`                   | 2.0 (fill only) | 9.2  |
| `bone` on `ground`                    | 1.1 (fill only) | 11.3 |
| `jade` on `ground`                    | 4.4 (fill only) | 8.7  |
| `plum` on `ground`                    | 6.1             | 8.0  |
| `on-jade` on `jade`                   | 5.3             | 8.4  |
| `on-plum` on `plum`                   | 7.2             | 7.9  |

Amber, jade and bone are **fills only on the light ground**: they never carry text, and on light they are always outlined with `ink` so a marble separates from the table. Re-check every pair when a value changes.

The four side hues are not distinguished by lightness alone (glaze, jade and plum are close in grayscale, and blue and amber are the only strongly separated pair), so the marks (ring, dot, bar, triangle) carry each side's identity regardless of colour vision.

### Token source of truth

Tokens are defined once, in `design/tokens.json`. `node scripts/tokens.mjs` generates the Godot palette (`game/scripts/generated/palette.gd`) and the web CSS custom properties (`web/src/app/tokens.css`) from it; the concept renders read it too. CI fails if a generated file is out of date, if a text pair in its `contrast` list falls below its minimum, or if a hex value or `Color(...)` appears anywhere else (`make tokens-check`, `make colors-check`). The Milestone 0 test scene is the one exception, until the real arena exists.

## 3. Typography

- **Direction:** a heavy geometric sans for titles and labels (caps with generous letter-spacing), a regular weight for body. Numerals tabular so scores never change width.
- **Language coverage is the deciding constraint.** If the UI ships in Bangla as well as English (open decision), the font must cover both scripts. Candidates to evaluate: Hind Siliguri, Noto Sans Bengali with a Latin companion, Baloo Da 2. Check each on the wordmark, on 12–16 px labels, and in Godot's text rendering before choosing; record the licence (SIL OFL) beside the font files.
- The renders use macOS system fonts (Avenir Next) as placeholders. They are not shippable. Fonts are bundled in the game and self-hosted on the site; nothing is loaded from a third-party host at runtime.
- Long text uses sentence case; caps are for labels, titles and button text. Do not use pixel or monospaced faces as the identity.

Reference sizes at the 390 px design width (test on devices):

| Role               | Size  |
| ------------------ | ----- |
| Score (match over) | 140   |
| Screen title, turn | 28–30 |
| Mode name          | 22    |
| Button label       | 14–18 |
| Body               | 15–17 |
| Caption, chip      | 11–13 |

## 4. Shape and component language

| Element           | Rule                                                                                                                                                                                                                                                                          |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Primary action    | Solid `glaze` disc, 96–112 px across, label in `on-glaze`, bottom third of the screen                                                                                                                                                                                         |
| Secondary action  | Outlined rounded rectangle (radius 14, 2 px `ink`), `ground` fill so it reads over any scrim                                                                                                                                                                                  |
| Tertiary action   | Underlined text in `ink`                                                                                                                                                                                                                                                      |
| Icon button       | 44 px circle, 2 px `ink` outline; selected = filled `ink` with a `ground` glyph                                                                                                                                                                                               |
| Mode row          | Outlined rounded rectangle (radius 18) with the mode's name, one line of what it is, and a small diagram of its arena (kep, three holes, or kep with scattered marbles); selected = 4 px outline plus a check in a filled `ink` circle. No chips or labels about authenticity |
| Toggle            | 70 × 34 pill: filled `ink` with ON, outlined with OFF; the word is always shown                                                                                                                                                                                               |
| Result cue        | Solid `ink` rounded rectangle with `ground` text, one line, over the lower arena                                                                                                                                                                                              |
| Coach prompt      | Solid `ink` rounded rectangle with a bold caption and two lines of text                                                                                                                                                                                                       |
| Marble            | Sphere; side colour plus mark (ring / dot / bar / triangle); stake marbles plain bone; contact shadow                                                                                                                                                                         |
| Baad marker       | A drawn cross on the ground under the named _baad_ marble (2 px `ink`), with the word BAAD in the call banner; never colour alone                                                                                                                                             |
| Route chips       | In Batto, a row of five small circles H1 H2 H3 H2 H1 under the HUD, one filled `ink` for the active side's next hole; each side's finished marker is its mark                                                                                                                 |
| Striker marker    | A 3 px glaze ring on the ground under the active striker; the marble is slightly larger                                                                                                                                                                                       |
| Aim line          | Dashed `ink` line from the striker back to the finger; solid glaze arrow forward with a filled head                                                                                                                                                                           |
| Power meter       | 200 × 14 outlined bar, filled `glaze`, with `POWER nn%` as text beside it                                                                                                                                                                                                     |
| Jalla, kep, holes | In the 3D scene: the jalla is a 3 px chalk line (dashed, to stand behind), each hole a dark recess with a visible lip and a small number H1 to H3 in Batto                                                                                                                    |

## 5. Screens, layout and the arena

### Layout (portrait, 390 × 844 reference)

1. **HUD (top 140 px):** mode name with its status caption, the turn in large type, score and targets left on one line, and a pause icon button at the right.
2. **Arena:** the middle of the screen, as large as it can be without touching the HUD or the camera bar. Nothing is drawn over it except the aim line and the result cue.
3. **Thumb zone (bottom 120 px):** camera view buttons at the left (angled, top-down, low), reset at the right. While aiming, this row is replaced by a power meter and a Cancel text action. While the shot is in flight it shows one quiet line.
4. Drag areas for orbit and aim stay clear of buttons, so a user can orbit empty ground without brushing a control.

If height runs out, the HUD compresses first; the arena shrinks last. Do not let marbles become hard to tell apart on a 360 × 640 screen.

### Camera views

| View             | Purpose                                                | Constraint                                                                   |
| ---------------- | ------------------------------------------------------ | ---------------------------------------------------------------------------- |
| Angled (default) | Read the whole board, the holes, and the active marble | Shows the active marble, the holes and the boundary at once                  |
| Top-down         | Tactical judgement                                     | Limited perspective distortion; aim computed in world space                  |
| Low              | Cinematic inspection                                   | Minimum height above ground; never inside walls; optional if it harms aiming |
| Follow           | Tracks the shot, then returns to the player's view     | Skippable; can be turned off in Settings; never changes the result           |

The concept sheet [design/screens/light/16-camera-views.png](design/screens/light/16-camera-views.png) shows the three static views.

### Aim feedback

The aim line and arrow are computed in world space and projected onto the ground, never inferred from screen pixels, so they stay correct in every view. Pulling back sets direction opposite the pull; the arrow must make that unambiguous. A conservative predicted path is optional and must not promise bounces the physics cannot model.

## 6. Motion

Animation explains the simulation; it does not delay it.

- The marbles move because the physics moves them, never because an animation was played.
- Result cues appear **after** the board is evaluated, never before; they are derived from the evaluated state.
- Camera transitions are eased and brief (300–500 ms for preset changes, skippable follow); reset may snap if the player asked for it.
- With **Reduce motion**, follow is off, camera presets cut instead of easing, and result cues appear without sliding.
- UI control feedback is 150 ms or less. Nothing loops while idle. Rendering pauses when the app loses focus.
- Dust on a hard ground contact is allowed, small and short, and never obscures final marble positions.

## 7. Voice and copy

Short labels in caps for controls; plain sentences for explanations. Say what happened and what the player can do next.

Use: `YOUR TURN`, `ROLLING`, `TARGET CLAIMED +1`, `OPPONENT MARBLE OUT`, `NO SCORE`, `MATCH OVER`, `IN THE KEP`, `HIT, ONE MORE SHOT`, `REACHED HOLE 2, ONE MORE SHOT`, `NAME THE BAAD MARBLE`, `DAN WON`, `FINE`, `NO TOUCH`, `YOU WON`. Terms use the games' own words with a short gloss on first use: _jalla_ (line), _kep_ (hole), _dan_ (round), _baad_ (the marble you must not touch).

Avoid "Wrong!", "You lose!", exclamation marks, and any wording that calls a rule official, authentic or "how it is really played". History and the author's changes live on the About page ([README_ABOUT.md](README_ABOUT.md)), not on mode screens.

## 8. The 3D arena

### First arena

One compact, slightly irregular patch of packed earth with a clear boundary. Cheap geometry and materials first:

- ground with subtle low-frequency dirt variation and a little roughness noise, not high-frequency clutter;
- low boundary stones or a shallow raised edge where needed;
- the jalla and a readable kep with a visible lip, and, for Batto, a large rectangular board with three big numbered holes in a line that stay distinguishable from every supported view;
- restrained background props only when they establish scale, none tall enough to block likely camera paths;
- a neutral horizon that keeps the arena silhouette readable.

The collision surface stays flat and simple under a visually varied mesh until the physics is calibrated (see [README_ARCHITECTURE.md](README_ARCHITECTURE.md)).

### Marbles

Hero objects. Imply glass, clay or polished stone with a narrow specular highlight and a simple reflected-environment impression. Same mesh and collider scale for every marble; the striker is identified by its ground ring and a slightly larger radius, not by hiding its surface. Each side has a base colour plus a mark (ring, dot, bar); check all pairs for colour-vision differences.

### Lighting and rendering budget

The target is the Godot **Compatibility** renderer (WebGL 2 on the web). Start with one key directional light and restrained fill. Prefer simple materials; keep post-processing absent until profiling proves it affordable; limit texture sizes, particles and decorative meshes. Test exported builds on a real phone and a browser, not the editor. Design a low-cost setting that drops shadows, effects and background clutter while keeping marbles and boundaries readable.

## 9. Screens and states

The game screens are listed with their purpose in [design/SCREENS.md](design/SCREENS.md). Every one must exist in both themes before UI is called done. State handling:

- **Loading, paused, error:** one plain line of text and at most one action, with no illustration.
- **About:** one plain text screen reached from the menu, with the same layout as Settings; see [README_ABOUT.md](README_ABOUT.md). Mode screens carry no authenticity labels.
- **Save data failure:** the game starts with defaults and says so once; nothing is blocking.

## 10. The website

The site uses the same tokens, wordmark and rules, so it reads as the same product. Details and the page-by-page plan are in [README_WEB_AND_APP_PLAN.md](README_WEB_AND_APP_PLAN.md); renders are in [design/web/](design/web/).

- Purpose: explain the game and get people to install it. **Download is the single primary action.**
- On the web the primary action is the same glaze, drawn as a full-round button (a disc is impractical for a wide label).
- The marble and arena illustration is the visual; avoid stock photography and folk clichés.
- Pages are complete and readable without JavaScript. Both themes follow the visitor's system setting, with a visible toggle that is a progressive enhancement.
- Respect reduced motion; nothing loops.

## 11. Sound

A small, original set, written from code by `scripts/sounds.mjs` (so there is nothing to license; `make sounds` regenerates the files in `game/audio/` and `make sounds-check` fails if they drift): a marble striking a marble, a marble on the wall, a marble dropping into a hole, the shot leaving the finger, a button tap, and a win and a lose chime. Hard hits are louder, and the pitch of the repeating sounds varies a little. The sounds are synthetic and have not been judged by ear yet; recordings can replace the files (record their source and licence beside them). Sound supports weight and result; every critical result also has a visual cue and works muted. Do not use a recording of a real person's voice or a recognisable cultural performance without permission and licence, and do not use stock "village" ambience to imply authenticity. Record the source and licence of every file beside it.

## 12. Cultural visual integrity

Use observation of real play areas where possible; ask permission before photographing people or private places. Prefer specific, grounded detail to generic visuals. When a local player explains a tool, layout or marking, record it, say which locality it came from, and confirm whether it is local or broader before it appears in the game or on the site.

## 13. Accessibility and comfort

- Text and icons meet contrast in both themes (section 2); touch targets are at least 44 × 44.
- Colour is never the only signal: side marks, the striker ring, chips with words.
- Camera reset is always reachable; follow is toggleable; motion is restrained.
- Sound is supplementary. A pause path reliably cancels an unfinished aim gesture.
- Test on real phone-sized screens, not only a desktop window.

## 14. Process and verification

1. **Concept** (done): direction chosen and rendered in both themes.
2. **Tokens and doc:** this document and the token source agree; the generator and the colour check are added with the first UI.
3. **Play screen first:** ready, aiming, in flight, result; both themes; real 3D arena.
4. **Remaining screens:** built from existing parts. A new part is added to the system, with the doc updated and a stated reason.
5. **Site:** built from the same parts.

Verification: a debug-only screenshot path in the game (a command-line flag that saves a frame and quits, absent from release builds). Capture each screen at **390 × 844**, **360 × 640** and **412 × 915**, in both themes, with realistic state. Look at every image and list what is wrong before reporting a screen done. The concept renders are regenerated with `node scripts/design/render.mjs` (needs Google Chrome).

## 15. Acceptance checklist

- [ ] Cover the wordmark: could this be another game? If yes, fail.
- [ ] The arena is the focal point; the HUD never covers it.
- [ ] The striker, whose turn it is, and each side's marbles are recognisable in grayscale.
- [ ] Every state (aiming, rolling, claimed, out, no score, paused, error) is distinct without colour.
- [ ] No gradient, glow, shadow, glass, card-in-card, tagline, or exclamation mark in the UI.
- [ ] Exactly one primary action per screen.
- [ ] Every UI colour comes from the tokens; none hand-defined outside the generated files.
- [ ] Both themes pass the contrast table and look intentional.
- [ ] Layout holds at 390 × 844, 360 × 640 and 412 × 915 with no overlap.
- [ ] The edge, the jalla and the holes are readable from every camera view.
- [ ] Controls work by touch without a mandatory drag; orbiting never fires a shot.
- [ ] Reduce motion works; nothing loops while idle; the low-cost setting keeps marbles readable.
- [ ] The site works without JavaScript and matches the game's language.
- [ ] No label or wording claims the rules are official or authentic; the About page matches the rules and lists what the author changed.
- [ ] This document matches the code.
