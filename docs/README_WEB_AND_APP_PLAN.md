# Guli & Batto — Web and App Plan

> **Purpose:** plan the pages and content that the website and the app share, how the game runs in the browser, and how people get it on Android and in the browser.  
> **Replanned 2026-10-21.** The first version of this plan treated the site as a brochure for an Android file and the browser game as a try-out. The web and the app are now peers: both are the whole game, and both carry the same information.  
> **Status (2026-10-22):** the site is live at <https://playgulibatto.vercel.app>, with the redesign: Home, `/games` and four game pages, How to play, About, Contact, Privacy, Download (with a QR code) and Play (a phone, then the game), all rendered from the shared `content/`. The app has the same pages. Not yet built: the site-native browser loader and the all-platform download page. The Download page reads the latest release, which since 2026-10-22 has all four games.

## 1. Goal

**Anyone can learn the four games and play them, on the web or in an app, and each place points to the other.**

- **The web version is the full game,** not a try-out. The apps are the same game with the same rules.
- **The same information everywhere.** What the site teaches, the game teaches too, from the same words and the same diagrams.
- **Each side points to the other.** The site says "get it on Android" and offers to play in the browser. The app says "play on the web".
- **No extra features.** This plan adds pages and content, not new gameplay.

## 2. The pages

Every page exists on the web and, where it makes sense, in the app. One source of content feeds both (section 3).

| Page            | On the web                                                                                        | In the app                                                                            |
| --------------- | ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| **Home**        | `/`: large (section 4)                                                                            | The menu: the wordmark, the arena, Play, and links to the pages below                 |
| **The games**   | `/games` and one page each: `/games/kep`, `/games/batto`, `/games/guli-khela`, `/games/quick-dan` | Mode select, with an info screen for each mode before you start                       |
| **How to play** | `/how-to-play`: very large (section 5)                                                            | The same content as a screen with a section for each mode, the controls and the terms |
| **Play**        | `/play`: the full game in the browser (section 6)                                                 | The game itself; a link "Play on the web"                                             |
| **Download**    | `/download`: the APK and the browser version, with checksums (section 7)                          | "Play on the web" and the Android download                                            |
| **About**       | `/about`: where the rules come from, what the author changed                                      | The same text ([`README_ABOUT.md`](README_ABOUT.md))                                  |
| **Contact**     | `/contact`: how to reach the author, and how to say how you played                                | The same text and links                                                               |
| **Privacy**     | `/privacy`: collects nothing                                                                      | The same text                                                                         |
| **Settings**    | none                                                                                              | Theme, sound; the only app-only page                                                  |

Links out of the app (to the site, to a download) open the system browser. The app never needs a connection to play.

## 3. One source of content

The first About text was copied by hand into three places (a doc, the game, the site). That ends here.

- **`content/`** holds every page's words as plain data: headings, paragraphs, lists, a glossary, and named diagrams. The format is JSON blocks (`heading`, `paragraph`, `list`, `term`, `diagram`), because both a React page and a Godot screen can render it without a Markdown engine.
- **Diagrams are data too.** A diagram names an arena layout (the kep, three holes, a scatter of marbles with a _baad_ cross, a route) and the marbles in it. The site draws it as SVG and the game draws it with the same marble marks, from the same description, so the two cannot drift.
- A build step copies the content into the game's data folder and the site reads it directly. A check fails if they differ.
- The About page copy is the first thing moved over; [`README_ABOUT.md`](README_ABOUT.md) then describes the page and is not a third copy.

## 4. Home page (large)

The home page does the job of introducing the whole game, not just a download button. In order:

1. **Hero:** the headline, a short description, the arena drawing, and the primary action (Download, with a link to Play in the browser). A meta line with the latest version and size.
2. **How it works:** the three steps (aim, release, read the result) with the real aim visuals.
3. **The four games:** a block for each, with its diagram, two or three sentences about what makes it different, and a link to its page.
4. **See it:** real captures of the game: a toss, a hit, a scatter, the _baad_ call, the standings. Light and dark.
5. **Where to play:** the browser and Android, each with its action.
6. **Where it comes from:** the story in a few lines, and a link to About.
7. **How you played:** an invitation to tell the author how you played these games, linking to Contact.
8. **Closing band:** the primary action again.

## 5. How to play (very large)

One long page, with a table of contents and a stable link to each section, and the same content in the app. It must teach all four games to a person who has never played them.

1. **Controls:** aim and power (slingshot, the arrow, the meter, the dead zone, cancel), the camera (orbit, zoom, the three views, reset), pause and restart. With a diagram of a pull.
2. **Reading a turn:** what the HUD shows, the result cues and what each one means, the end of a match.
3. **Kep:** the goal, the setup (jalla, kep, the toss), a turn step by step, scoring with an example round, ties, how a match ends, tips.
4. **Batto:** the goal, the three holes and the route (H1 → H2 → H3 → H2 → H1), the opening toss, hits and bonus shots (and the cap), finishing order, a worked example, tips.
5. **Guli Khela:** the goal, the purse and stake, the opening toss and the scatterer, naming the _baad_ marble, what counts as a clean touch, a fine, winning a dan and what the winner takes, what happens if everyone fails (the three passes), surrender and how a match ends, a worked example, tips.
6. **Quick Dan:** one round of Guli Khela, and when to choose it.
7. **Words:** a glossary: _jalla_ (the line), _kep_ (the hole), _dan_ (a round), _baad_ (the marble you must not touch), fine, stake, scatter, pot.
8. **Questions:** a short FAQ (why did my marble skip the hole, why was my turn ended, can I change the rules).

Each mode section follows the same order so players can compare them. Rules in these pages are quoted from [`README_GAME_RULES.md`](README_GAME_RULES.md); a rule change updates the page in the same change.

## 6. Browser play

The game in the browser is the same Godot project exported to the web.

- **Build and delivery.** CI exports the web build and attaches it to the release (the rolling `latest` and each versioned release). When the site builds, `scripts/fetch-play-build.mjs` downloads it into `web/public/play-build/` (git-ignored), and a Vercel deploy hook rebuilds the site after each release ([DEPLOY.md](DEPLOY.md)). The path carries the version so a browser cache never serves an old build against new files. A failed fetch never fails the site build; `/play` then says it is unavailable.
- **The page loads the engine itself,** not Godot's default page in a frame. A client component creates its own canvas and starts the engine from the exported files, so the page controls the experience:
  - nothing downloads until the visitor presses **Play** (the export is about 40 MB); that press also unlocks audio;
  - a progress percentage while it loads;
  - a check for WebGL 2 and WebAssembly first, with a plain message if either is missing;
  - failure states (download error, engine error) with a retry;
  - the canvas matched to the frame in device pixels, so it stays sharp at any size, and a fullscreen button;
  - on a phone, a "this is better as an app" suggestion.
- **Hosting needs:** WebAssembly served with the right content type and compression. The export is single-threaded, so no special cross-origin headers are needed.
- **Differences from the app:** none in the rules or the modes. The web version has no vibration, and its saved settings live in the browser, which may be cleared. The `/play` page says both.

## 7. Downloads

A release publishes the APK and the web export plus a checksum file. The Download page reads them from the latest release and lists the APK and the browser version, with the size and a link, a short install note, and the checksum.

| Platform | File                                                 | Install note                                          |
| -------- | ---------------------------------------------------- | ----------------------------------------------------- |
| Android  | `gulibatto-<version>.apk`                            | Allow installs from your browser once; not on a store |
| Web      | played at `/play`; the export is also in the release | no install                                            |

`SHA256SUMS` lists every file. The page shows each checksum and the command to check it. If a release is missing a file, that row says it is not in this release and shows no button. It never links to an unverified file. There is no device detection; both are shown.

## 8. Trust and privacy

- Say plainly that these are direct downloads and why the OS may warn.
- Publish a checksum for every file.
- No tracking, no third-party scripts, no third-party fonts at runtime, no cookies, no analytics. The theme choice stays in the browser.
- The privacy page states that the game and the site collect nothing.

## 9. Technical decisions

- **Next.js, App Router, TypeScript,** in `web/`. It holds no game logic and no copy of the rules; it renders the shared content and loads the game's export.
- **Static first.** Pages are pre-rendered; the download page revalidates hourly.
- **No JavaScript needed** for any content or for downloading. The browser game needs JavaScript and says so.
- **Tokens.** The site's CSS variables are generated from `design/tokens.json`, the same source as the game's palette.
- **Diagrams** are SVG drawn from the shared diagram data, with the marble marks; never screenshots.
- **SEO and sharing:** a title, description and share image per page, a sitemap and robots.
- **Accessibility:** both themes pass the contrast table, everything is keyboard reachable with a visible focus, real headings, reduced motion respected, diagrams have text alternatives.
- **Tooling:** oxlint, type-check, unit tests, build and a smoke test run in CI; see [CI.md](CI.md).

## 10. Order of work

1. **The content source and the diagram format;** move the About copy onto it.
2. **The site pages from it:** the large Home, the four game pages, the large How to play, Contact; check them against the plan with the author's review of the wording.
3. **The in-app pages from the same source:** How to play, mode info, About, Contact, Privacy, and the "web" and "Android" links.
4. **The site-native browser loader** replacing the framed Godot page, with progress, checks and retry.
5. **The all-platform download page,** once the releases publish those files ([CI.md](CI.md)).

### Exit criteria

- A visitor can learn all four games from the site alone, and the app teaches the same.
- A visitor on any platform finds their download, checks it, and is told what the OS will say.
- The browser game loads from the site with progress, fails gracefully, and plays the same as the app.
- Pages work without JavaScript, except the game.
- No third-party requests, cookies or trackers.
- The wording and diagrams on the site and in the app come from one source and a check proves it.

## 11. Open items

- **Contact details** to publish (an email or a form), and where messages go.
- **A custom domain,** if wanted; hosting is Vercel at `playgulibatto.vercel.app`.
- **The author's review** of the How to play and games wording; the diagrams need the author's eye.
- **Real captures** of each mode for the home page, once all four exist.

## 12. Site redesign (planned 2026-10-22)

**Why.** The first site is a brochure. Its text pages (About, How to play, Privacy) cap every block at `44em` inside a 1120 px page, so on a laptop the right half is empty, and the pages that could teach the game (a page per game, diagrams, a table of contents) do not exist. The site also still holds its own copy of the text.

**Layout rules (fix the empty side everywhere).**

- Every page uses one of three shells, never a bare narrow column: **Landing** (full-width bands, two-column sections), **Reading** (contents on the left, text in the middle, a diagram or fact panel on the right), **Tool** (Play, Download: the main object large, notes beside it).
- Text measure stays about 62 characters, so the width goes to a second column, not longer lines. On a phone the columns stack.
- Short pages get a real second column: Privacy shows "what is collected: nothing" as a fact list beside the text; Contact shows the questions worth answering ("what did you call it, how far was the line") beside the ways to reach the author.

**Pages and what each shows.**

| Page                      | Content from `content/`                                                  | Right column                                                  |
| ------------------------- | ------------------------------------------------------------------------ | ------------------------------------------------------------- |
| Home                      | hero, three steps, four games, the pages, where to play, how it began    | arena drawing; real captures when they exist                  |
| Games (`/games`)          | one row per game with its diagram                                        | the diagram                                                   |
| Game page (`/games/<id>`) | the page's blocks, in the order Goal, Setup, A turn, Scoring, Tips       | its diagrams, sticky                                          |
| How to play               | contents plus controls, reading a turn, the four games, words, questions | diagrams beside the section they teach                        |
| Play                      | the site-native loader (section 6)                                       | notes: controls, saved settings, "better as an app" on phones |
| Download                  | APK and browser version, checksums                                       | the install steps                                             |
| About, Contact, Privacy   | the shared pages                                                         | fact panel                                                    |

**How it is built.**

1. A `Blocks` React renderer in `web/src/components/` reads `content/` the way `PageBlocks` does in the game (heading, paragraph, list, term, diagram, link, example), and a `Diagram` SVG component draws `content/diagrams.json` with the marble marks. The hand-copied About, How to play and Privacy are deleted; `make content-check` already guards the source.
2. The three shells, plus a sticky contents list that follows headings.
3. Home, `/games`, the four game pages, How to play and Contact.
4. The site-native loader, then the all-platform download page.
5. A visual pass in both themes at 1440, 1024 and 390 px wide (headless screenshots), and a smoke test that every route renders and has no horizontal scroll.

The visual rules in [README_VISUAL_DESIGN.md](README_VISUAL_DESIGN.md) still apply: one primary action per page, no cards inside cards, no gradients, no decoration.

**Built (first pass, 2026-10-22).** The `Blocks`, `Diagram` and contents components, the Reading and split layouts, a new Home, `/games` and four game pages, How to play with a contents list and diagrams, Contact, a two-column Download, and Play with the controls beside the game. `make content` writes `web/src/lib/content.generated.json` and the content check covers it. Checked as screenshots at 1440, 1024 and 390 px in dark mode and by the smoke test. Not yet done: the site-native loader, light-mode screenshots of every page, real captures on the Home, and the author's review of the wording.
