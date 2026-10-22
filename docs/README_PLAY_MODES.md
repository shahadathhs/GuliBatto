# Guli & Batto — Play modes

> **Purpose:** plan the two ways to play any of the four games: against the computer, and with friends on one device.  
> **Decided 2026-10-22.** The project overview listed "pass-and-play on one device" under _Not in_. That decision is reversed here, by the author, and the overview is updated with this plan. Online play is still out.

## 1. The two modes

| Play mode             | Players                                | Who shoots                                                   |
| --------------------- | -------------------------------------- | ------------------------------------------------------------ |
| **Against computers** | you, plus 1 to 3 computer sides        | you on your turn; the computer on theirs (today's behaviour) |
| **Pass and play**     | 2 to 5 people on one phone or computer | whoever's turn it is; the device is handed round             |

Both work in all four games, in the app and on the web. A match is one or the other; mixing people and computers is not planned.

The four games stay: Kep, Batto, Guli Khela and Quick Dan. A play mode is chosen after the game, on one short screen ("Who plays?"), and the last choice is remembered in Settings.

## 2. What changes in the game

The code assumes one human side (`human_side`) and a fixed three sides (`RuleProfile.side_count = 3`). The change is to make both a property of the match, not of the profile.

- **Match setup.** A `MatchSetup` value (play mode, number of sides, which are human) is passed to `MatchScene` and the controller. The profile keeps only the defaults.
- **Controller.** `human_side: int` becomes a set of human sides. `is_human_turn`, the shot and baad checks, surrender and the AI table all ask "is this side human?". In pass and play every side is human and no AI is built.
- **Hand-over.** Before a human side shoots in pass and play, a short "Pass to Amber" screen (the side's marble, its colour and mark, one tap to continue) appears, so a shot is never taken by the wrong hand. The camera has already moved to that side's marble.
- **Words.** "Your shot" and "You" become the side's name when more than one person plays: Blue, Amber, Jade, Plum, Rose. Standings, the round result and the end screen use names; against computers they still say "You".
- **Surrender.** Against computers it stays as it is. In pass and play the pause menu offers "End the match", which ends it with the current standings, because one person cannot give up for everyone.
- **Sound.** The win sound plays for the winning side in pass and play, not only for you.

## 3. Five sides

Four sides exist today (blue ring, amber dot, jade bar, plum triangle) and the neutral stake marble is a bone bar. A fifth side needs its own colour and its own mark.

- Add a fifth colour token (**rose**, a pink, already in `design/tokens.json` with its contrast checks) and its text colour, for both themes, with the contrast check, and a fifth mark (a diamond). Both come only from `design/tokens.json`; `make tokens` regenerates the Godot palette and the site CSS.
- `SideStyle` wraps with a modulo today, which would silently give side 5 the colour of side 1. Replace it with a guard and a test that no two sides share a colour or a mark.
- The site's marble drawing and the diagrams get the same fifth style.

## 4. Do the games hold five sides?

Each rule set and board must be checked at 2 and at 5 sides, with a test for each:

- **Kep:** the toss and the five rounds work for any count; check the marbles do not overlap at the jalla.
- **Batto:** five small marbles on a 10 m wide start; check the opening toss and finishing order with five.
- **Guli Khela:** the stake is 3 per side, so five sides scatter 15 marbles; the scatter ring (`StakeLayout`) must fit them, and two sides (6 marbles, one thrower per pass) must still feel like a game.
- **Quick Dan:** one dan; same checks as Guli Khela.
- The turn cap, bonus cap and pass rules do not depend on the count.

## 5. Screens

1. **Modes** (exists): choose the game.
2. **Who plays?** (new): two large choices, "Against the computer" with a 1, 2, 3 stepper, and "Pass and play" with a 2 to 5 stepper; one primary action, Play.
3. **Rules card** (exists): first time only.
4. **Match:** the HUD shows the current side's name and mark; standings show every side.
5. **Pass to ...** (new): between human turns in pass and play.

## 6. What changes on the site and in the content

- `content/` gets a "Play modes" section in How to play (what each is, how the hand-over works), a line on each game page, and a line on Home ("Play against the computer, or hand the phone round"). The app and the site both read it.
- **About, "What I changed":** add "You can play against one to three computers, or hand the device round with two to five people". `docs/README_ABOUT.md` and `content/pages/about.json` change together (the check compares them).
- The Home "short list" line "Computer sides" becomes "Computers or friends".

## 7. Does it sound good?

Yes, with two cautions.

- **It fits the games.** All four are group games first; playing them alone against two computers is the odd case. Hot-seat needs no network, accounts or storage, so it stays inside the offline rule.
- **Caution 1, the fifth side is real work** (token, mark, wrapping bug, tests) and touches the site's drawings too.
- **Caution 2, long matches with five.** Five people means five times the waiting in Batto and Guli Khela. The turn cap already stops a runaway game; if it still drags, Quick Dan is the short answer.
- **Sound of it.** The sounds exist today; two cues are new: a soft "pass" tone on the hand-over screen, and the existing turn tick played in a different pitch per side so a listener can tell whose turn it is. Both are synthesized by `scripts/sounds.mjs` with the rest.

## 8. Order of work

1. Tokens and `SideStyle`: the fifth colour and mark, the guard, tests.
2. `MatchSetup`, controller and HUD: a set of human sides, side names, hand-over screen; all-human matches in the tests.
3. Check each game at 2 and 5 sides (section 4); fix layouts.
4. The "Who plays?" screen, the saved choice, the pause-menu change, the win cue.
5. Content, About and the site: the pages, Home and the fifth marble.
6. The two sounds; hand test on a phone with real people.

### Exit criteria

- Every game starts and finishes against 1, 2 and 3 computers and with 2, 3, 4 and 5 people, in tests and by hand.
- No two sides share a colour or a mark in either theme.
- A hand-over screen separates every pair of human turns.
- The app, the site and About describe both modes in the same words.

## 9. Open questions

- **Computers in pass and play:** not planned. Say if you want "3 friends and 1 computer".
- **Names:** sides are named by colour. Typed names are not planned; they would add a text-entry screen and storage.
- **Default:** Against computers, 2 computers, as today.

## 10. Docs and pictures

The README's pictures are **drawn, not captured.** A headless browser does not keep the real site's layout (its minimum window width, scroll reveals and animation timing change the page), and a headless Godot capture only shows what one scripted frame holds. Instead the pictures are SVG drawn by `scripts/design/` from `design/tokens.json` and the same marble marks, and turned into PNGs by headless Chrome (`node scripts/design/render.mjs`).

**Done on 2026-10-22.**

- The fifth colour (`rose`) is in the token file, the generated palette and the site CSS; the contrast check passes.
- The app renders are brought up to the game as built: Batto's long board, the real Settings, the Pause menu with Surrender, a rules card and the How to play page; new screens for Who plays?, Pass to … and a five-side Kep (17 to 21).
- A six-screen strip (`docs/design/app-strip-light.png` and `-dark`) replaces the all-screens sheet in the README; the sheet stays in `docs/design/`.
- The site renders are redrawn for the redesigned site: Home, a game page and Download, in both themes. The old headless screenshots are removed.
- The stale text pass: the status paragraph, roadmap, overview, architecture note, rules table, features list, AGENTS.md and the screen list, each marked "planned" where the code does not do it yet.

**Still to do with the build.** Re-run the render command when a screen changes, and as a line in the release checklist ([CI.md](CI.md)). When a play-mode part is built, remove the word "planned" in the same change, and update About together with `content/pages/about.json`.
