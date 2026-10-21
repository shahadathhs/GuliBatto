# Guli & Batto — Project Overview

> **Replanned 2026-10-21.** The first plan treated this as a minimal prototype with a brochure site. The goal is now a complete game: four traditional marble games, each represented properly, on Android, the web, Windows, macOS and Linux, with the same game and the same information everywhere. Nothing beyond that is planned. Sections 2 and 4 say what that means, and [`README_ROADMAP.md`](README_ROADMAP.md) says in what order.

## 1. The idea

Make a tactile 3D game from the traditional marble games the project owner played as a child: **Kep**, **Batto**, **Guli Khela** and **Quick Dan**. The player interacts with marbles and a physical play area rather than controlling human avatars. One arena, one marble behaviour, one aiming system and one camera rig serve all four modes.

The product should feel like playing on a real patch of ground: line up a shot, judge distance and angle, release, watch the marbles collide and roll, then understand why the turn was won or lost.

This game is one person's attempt to bring childhood memories back. Nothing in it is invented from nothing: each mode starts from a game people played, the author modified the rules for play on a screen, and one central page, [`README_ABOUT.md`](README_ABOUT.md), says so plainly, so no mode needs an "adapted" or "provisional" label. The sources are in [`README_GAME_RULES.md`](README_GAME_RULES.md).

## 2. Scope: what is in, and what is not

**The scope is the four modes, represented properly, on every platform, with nothing extra.**

### In

- **Four modes, complete:** Kep (the toss at the hole), Batto (a race along three holes and back), Guli Khela (the line, the hole, the stake and the _baad_ marble) and Quick Dan (one round of Guli Khela). Rules in [`README_GAME_RULES.md`](README_GAME_RULES.md).
- **One to three computer opponents** in every mode, so each can be played alone, with two to four sides.
- **Five platforms from one Godot project:** Android, the web (the full game, not a try-out), Windows, macOS and Linux.
- **The same information on the web and in the app,** from one source of content (see [`README_WEB_AND_APP_PLAN.md`](README_WEB_AND_APP_PLAN.md)): Home, How to play (large, with every mode), a page for each game, Play or Download, About, Contact and Privacy. The web points people to the apps; the apps point people to the web version.
- **Automatic releases for every platform** when the version changes, with checksums.
- **The basics a game needs,** as in the first plan: a menu and mode select, in-game status, pause and restart, a theme setting, basic sound, and locally saved settings.

### Not in

Pass-and-play on one device, Bangla or other languages, statistics and achievements, extra arenas or skins, a campaign, online play, accounts, leaderboards, cloud saves or any backend, human characters, ads and monetisation, a dashboard or authoring tool. Adding any of these is a new decision recorded here first.

## 3. What "represented properly" means

A mode is done when all of these are true. This is the acceptance list for each of the four.

1. **The rules are exactly the written rules.** Every rule in the mode's section of [`README_GAME_RULES.md`](README_GAME_RULES.md) is implemented and has a test on a hand-built board.
2. **The board shows the real elements of the game.** Jalla and kep for Kep; three holes and the route for Batto; the scatter, the named _baad_ marble, the pot and each side's purse for Guli Khela.
3. **The computer sides play the mode's real decisions.** Batto: go for the hole or hit a rival. Guli Khela: name a _baad_ marble and touch exactly one other. They sometimes miss.
4. **The result is always explained.** After every shot the player sees what happened and why ("In the kep", "Hit, one more shot", "Fine: touched the baad marble"), derived from the settled board.
5. **The mode is explained to a first-time player,** in the game and on the site, from the same words: the rules, a diagram, and the terms (_jalla_, _kep_, _dan_, _baad_).
6. **It works on all five platforms** with the same behaviour, and has been played by hand on at least a phone and a desktop browser.

## 4. Product principles

1. **Physics first.** The pleasure of a shot comes from understandable direction, power, rolling, friction and collisions. Do not hide weak physical behaviour under visual effects.
2. **One simulation, several views.** Camera modes change presentation, not the world state or the shot outcome.
3. **No people required.** The game shows the play surface, marbles, marks and the environment. No human avatars.
4. **One game on every platform.** The same Godot project, the same rules and the same content. A platform may differ only where it must (no vibration on a desktop).
5. **Offline and private.** No account, server, analytics or online match is needed for play. The web version runs entirely in the browser.
6. **Do the four modes well before anything else.** Depth in the four modes, not breadth of features.
7. **Be honest about tradition, in one place.** The About page names the sources and lists what the author changed. Modes carry no authenticity labels, and nothing claims to be the official rules.

## 5. Target experience

- **Platforms:** Android phones (the first target), desktop and mobile browsers, Windows, macOS and Linux desktops.
- **Engine:** Godot 4, GDScript, 3D scenes and the Compatibility renderer, so one project reaches every platform including the web.
- **Controls:** touch and mouse. On touch: drag back from your marble to aim, drag empty ground to orbit, pinch to zoom. On a desktop: the same with the mouse, wheel to zoom.
- **Play style:** turn-based shots against computer sides. No real-time networked play.
- **Session length:** short rounds that are easy to restart, a design target to check in playtests.

## 6. What would make the game worth shipping

- A first-time player can aim and shoot after one short prompt and read why a turn went the way it did.
- Changing the camera never changes the shot or the result.
- Shots are repeatable enough that skill matters, and collisions still make interesting outcomes.
- The four modes feel different: each asks for a different decision.
- It runs acceptably on a real mid-range Android phone, in a desktop browser, and on each desktop OS.
- People who played these games recognise them, or tell us how theirs differed, and the About page invites that.

## 7. Repository layout

```text
GuliBatto/
├── game/        Godot project (scenes, scripts, resources, tests)
├── web/         the website (Next.js), with the content pages and the browser game
├── content/     (planned) the shared words and diagrams: how to play, the games, about
├── design/      tokens.json, the one source of colours
├── scripts/     tokens, checks, version bump, concept renders
├── docs/        this specification and the design images
├── Makefile     command surface
└── VERSION      source of truth for releases
```

Details are in [`README_ARCHITECTURE.md`](README_ARCHITECTURE.md).

## 8. Decisions and open questions

| Topic           | Current decision                                                             | Needs                                                       |
| --------------- | ---------------------------------------------------------------------------- | ----------------------------------------------------------- |
| Project name    | "Guli & Batto" is a working label                                            | Name, spelling and cultural fit                             |
| Modes           | Kep, Batto, Guli Khela, Quick Dan; all four to be complete                   | Rules checked with at least one more person who played each |
| Platforms       | Android, web, Windows, macOS, Linux; iOS and a store listing are not planned | Whether to add either later                                 |
| Desktop signing | Unsigned at first; the OS will warn                                          | Apple and Windows signing if people complain                |
| Orientation     | Portrait on phones; desktop and web resize                                   | Playtests on real devices                                   |
| Language        | English, with the games' own words (_jalla_, _kep_, _dan_, _baad_)           | None planned                                                |
| Opponents       | One to three computer sides using the same shot interface                    | Whether the AI is good enough in each mode                  |
| Rendering       | Compatibility renderer for every platform                                    | Performance on real phones and in browsers                  |
| Physics         | Jolt, set explicitly; works in the browser export we played                  | Check on every platform                                     |
| Site hosting    | Not chosen; any static or Node host                                          | A choice, and the Contact details to publish                |
| Persistence     | Local save only                                                              | Browser storage behaviour and a clear reset                 |

## 9. Documentation map

- [`README_ABOUT.md`](README_ABOUT.md) — the central About page: where the rules come from and what the author changed.
- [`README_GAME_RULES.md`](README_GAME_RULES.md) — sources, the four modes, turn flow and scoring.
- [`README_GAMEPLAY_FEATURES.md`](README_GAMEPLAY_FEATURES.md) — the player-facing behaviour contract.
- [`README_ARCHITECTURE.md`](README_ARCHITECTURE.md) — scenes, systems, dependencies and data flow.
- [`README_WEB_AND_APP_PLAN.md`](README_WEB_AND_APP_PLAN.md) — the pages on the web and in the app, the shared content, browser play and downloads.
- [`README_VISUAL_DESIGN.md`](README_VISUAL_DESIGN.md) — environments, camera language, UI and performance constraints; [`design/SCREENS.md`](design/SCREENS.md) lists the screens and the site.
- [`README_IMPLEMENTATION.md`](README_IMPLEMENTATION.md) — build sequence and technical acceptance checks.
- [`README_ROADMAP.md`](README_ROADMAP.md) — phases and decision gates.
- [`CI.md`](CI.md) — the pipeline, releases for every platform, tooling and secrets.
- [`DEPLOY.md`](DEPLOY.md) — setting up the site on Vercel, the release files, and the signing key.
- [`README_CODE_STANDARDS.md`](README_CODE_STANDARDS.md) — conventions and review checklist.

## 10. Research references

- Banglapedia, "Folk Games", including the entry for Gulikhela: <https://en.banglapedia.org/index.php?title=Folk_Games>
- Godot Engine, web export: <https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html>
- Godot Engine, Android export: <https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html>
- Godot Engine, desktop exports: <https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html>
- Godot Engine, `RigidBody3D`: <https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html>

Research review date: 2026-10-21. Platform details can change; verify the documentation again when pinning the exact Godot version.
