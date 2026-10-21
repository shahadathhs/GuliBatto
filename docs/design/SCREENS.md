# Guli & Batto — Screens

Concept renders of every game screen in both themes (light "Day", dark "Dusk"). They are design targets, not final art: the real arena is 3D, fonts are placeholders, and the numbers are examples. Regenerate with `node scripts/design/render.mjs` (needs Google Chrome); the sources are in `scripts/design/`.

Overview sheets: [overview-light.png](overview-light.png) · [overview-dark.png](overview-dark.png)

Individual screens (390 × 844, 2x): `screens/light/` and `screens/dark/`.

| #   | Screen                    | Purpose and states                                                                                       |
| --- | ------------------------- | -------------------------------------------------------------------------------------------------------- |
| 01  | Menu                      | Wordmark, arena with a kep and the jalla, Play (primary), How to play, About, Settings                   |
| 02  | Mode select               | Kep, Batto, Guli Khela, Quick Dan: one line and a small arena diagram each, no labels; About link; Start |
| 03  | About these games         | The central page: childhood games, where the rules come from, what the author changed, what this is not  |
| 04  | First-use prompt          | Coach prompt over the Kep screen: pull back, then release; shown once, dismissed with "Got it"           |
| 05  | Kep, your toss            | Round, your turn, points chips per side (marble marks), the kep, the jalla, tosses already made          |
| 06  | Kep, round result         | Who was in the kep or closest, points for the round, running totals, Next                                |
| 07  | Batto, your turn          | Route chips H1 H2 H3 H2 H1 with the next hole filled, three holes in a line, each side's next hole       |
| 08  | Batto, hit and bonus shot | A hit on a rival, the rival knocked away, "Hit, one more shot"                                           |
| 09  | Batto, finishing order    | Ranking 1 to 4 with each side's mark; the last on the route is last; Rematch (primary)                   |
| 10  | Guli Khela, name the baad | Stake marbles scattered around the kep, purses and pot in the HUD, "Tap the baad marble"                 |
| 11  | Guli Khela, aiming        | The baad marble marked with a drawn cross, the arrow at another marble, power meter, Cancel              |
| 12  | Guli Khela, fine          | The shooter touched the baad marble: a fine of one marble into the pot; the next side is up              |
| 13  | Guli Khela, dan won       | Marbles taken, purses before and after, Next dan (primary), Surrender                                    |
| 14  | Pause                     | Resume (primary), Restart, How to play, Settings, Back to menu; cancels any aim in progress              |
| 15  | Settings                  | Sound, music, vibration, reduce motion, follow camera, theme, reset saved data                           |
| 16  | Camera views              | Angled, top-down and low views of the same Batto board (a reference sheet, not a screen)                 |

## Not in this set

- **Quick Dan screens:** the same as Guli Khela 10 to 13 with the match ending after the first dan.
- **Four-side variants:** the HUD chips and rankings show three or four marks the same way.
- **Load or save error:** a single plain line and one action; shown in the game when it is first needed.
- **Bangla text:** every screen needs a Bangla pass once the UI language is decided; the games' own words (_jalla_, _kep_, _dan_, _baad_) are shown in Latin letters for now.
- **Motion:** shot-follow, camera easing and the result cue are described in [../README_VISUAL_DESIGN.md](../README_VISUAL_DESIGN.md), not shown in stills.

## Web renders

The site is planned in [../README_WEB_PLAN.md](../README_WEB_PLAN.md). Renders (version, size and hash are placeholders). Mobile renders are 500 px wide, because headless Chrome will not make a narrower window:

| Page              | Light                                                            | Dark                                                           |
| ----------------- | ---------------------------------------------------------------- | -------------------------------------------------------------- |
| Landing, desktop  | [web/light/landing-desktop.png](web/light/landing-desktop.png)   | [web/dark/landing-desktop.png](web/dark/landing-desktop.png)   |
| Landing, mobile   | [web/light/landing-mobile.png](web/light/landing-mobile.png)     | [web/dark/landing-mobile.png](web/dark/landing-mobile.png)     |
| Download, desktop | [web/light/download-desktop.png](web/light/download-desktop.png) | [web/dark/download-desktop.png](web/dark/download-desktop.png) |
| Download, mobile  | [web/light/download-mobile.png](web/light/download-mobile.png)   | [web/dark/download-mobile.png](web/dark/download-mobile.png)   |
