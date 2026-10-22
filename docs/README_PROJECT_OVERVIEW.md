# Guli & Batto — Product Document

> The product in one place: what it is, who it is for, what is in it and what is not, what "done" means, how it reaches people, and where it stands. The details live in the documents linked from section 13.  
> **Replanned 2026-10-21.** Last updated with the first release and the live site (2026-10-21).

## 1. Summary

**Guli & Batto** is a 3D game of four traditional marble games from Bangladesh: **Kep**, **Batto**, **Guli Khela** and **Quick Dan**. They are the games the author played as a child on bare ground, with a line drawn in the dirt, a small hole and a few marbles. The game rebuilds them with real physics, so every shot can be learned: line up, pull back, release, watch the marbles roll and collide, and understand why the turn went the way it did.

It is free, runs offline, and has no accounts, ads or tracking. One Godot project runs on **Android and in the browser**, and a website teaches the games and distributes the Android build.

- **Site:** <https://playgulibatto.vercel.app> (play in the browser, download, learn the games)
- **Source and releases:** <https://github.com/shahadathhs/GuliBatto>

**What makes it different:** the physics is real and legible (no scripted outcomes); it is built from games people actually played, with the author's changes listed openly rather than claimed as the official rules; and the web and the apps are the same game with the same information.

## 2. Vision and goals

**Vision.** Anyone who remembers these games can play them again, and anyone who never knew them can learn them in minutes. The game should feel like a patch of real ground.

**Goals**

1. A shot that feels physical and learnable, with results that are always explained.
2. Four modes that each ask for a different decision, on one shared foundation.
3. The same game on Android and the web, and the same information on the web and in the app.
4. Honest labelling in one place: the About page names the sources and what the author changed.
5. A small, dependable release process: change the version, and the APK and the web build are built and published.

## 3. Who it is for

- **People who remember playing.** They will judge the feel and the rules first. They need a way to say how they played, and the game must not lecture them.
- **Curious players.** They have never played marbles this way. They need to understand a shot without being told, in the first minute, and to learn each game from the site or the app.
- **Casual players.** Short rounds, one hand, no account, no ads.

## 4. The four games

Each is a modernised version of a game people played. Sources and the rules in full are in [`README_GAME_RULES.md`](README_GAME_RULES.md); the words and the author's changes are on the About page ([`README_ABOUT.md`](README_ABOUT.md)). Two to four sides: you and one to three computer players.

| Game           | The idea                                                                                                                                                          | Keeps marbles between rounds | Ends                                   | State        |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | -------------------------------------- | ------------ |
| **Kep**        | Toss at the hole from behind the line. In the hole scores most, then the closest                                                                                  | No, scored                   | After a set number of rounds           | **Playable** |
| **Batto**      | Race along three holes and back; a hit or reaching a hole earns another shot                                                                                      | No, ranked                   | All but one have finished              | **Playable** |
| **Guli Khela** | Stake marbles scattered round the hole; name the marble you must not touch, then touch exactly one other; a wrong touch costs a fine; the winner takes the ground | **Yes**, play for keeps      | One side out of marbles, or surrenders | Next         |
| **Quick Dan**  | One round of Guli Khela                                                                                                                                           | No, one stake and one winner | The round is won                       | Next         |

Build order: Kep, Batto, Guli Khela, Quick Dan. Each must ask for a different decision; if two feel alike, the weaker is cut rather than another added.

## 5. The experience

- **Controls:** drag back from your marble to aim, like a slingshot; a longer pull is more power; release to shoot. Drag empty ground to orbit the camera, wheel or pinch to zoom, three views and a reset. Aim is computed in world space, so the camera never changes a shot.
- **A turn:** the game shows whose turn it is, you aim, the marbles roll and settle, the result is judged once from where everything rests, and a short cue says what happened and why.
- **Look and feel:** warm, tactile and quiet. The marbles are the only saturated objects, each side has a mark (ring, dot, bar, triangle) so colour is never the only signal, light and dark themes are both first-class ([`README_VISUAL_DESIGN.md`](README_VISUAL_DESIGN.md)).
- **Session:** short rounds that are easy to restart; a design target to check in playtests.

## 6. Platforms and distribution

| Platform | How people get it                                                  | State                                                     |
| -------- | ------------------------------------------------------------------ | --------------------------------------------------------- |
| Android  | APK from the releases page and the download page; no store listing | Built and published; not tried on a phone                 |
| Web      | Played in the browser at `/play`; the same game                    | Built, published and served; played in a headless browser |

A version change builds both and publishes a release with a checksum file; a rolling "latest" build follows `main`. Hosting is **Vercel** for the site and **GitHub Releases** for the files ([`CI.md`](CI.md), [`DEPLOY.md`](DEPLOY.md)). iOS, store listings and desktop builds (Windows, macOS, Linux) are not planned: people on a computer play in the browser.

## 7. Content: the same pages on the web and in the app

The website and the app carry the same information from one source ([`README_WEB_AND_APP_PLAN.md`](README_WEB_AND_APP_PLAN.md)): **Home**, **the games** (a page for each), **How to play** (very large: controls, every game with a worked example, a glossary of _jalla_, _kep_, _dan_ and _baad_, a short FAQ), **Play** or **Download**, **About**, **Contact** and **Privacy**; **Settings** is in the app only. The web points people to the apps, and the apps point to the web version. Today the site has the first version of Home, How to play, About, Download, Privacy and Play; the large pages, the per-game pages, Contact and the in-app copies are planned.

## 8. Scope

**In:** the four games, complete; one to three computer opponents in each; Android and the web from one project; the pages above on the web and in the app; automatic releases; and the basics a game needs: menu and mode select, pause and restart, a theme setting, basic sound and locally saved settings.

**Not in:** pass-and-play on one device, other languages, statistics and achievements, extra arenas or skins, a campaign, online play, accounts, leaderboards, cloud saves or any backend, human characters, ads and monetisation, a dashboard or authoring tool. Adding any of these is a new decision recorded here first.

## 9. When a game is "represented properly"

All six must hold for each of the four games.

1. **The rules are exactly the written rules,** each with a test on a hand-built board.
2. **The board shows the real elements:** jalla and kep; three holes and the route; the scatter, the named _baad_ marble, the pot and each side's purse.
3. **The computer sides make the game's real decisions,** and sometimes miss.
4. **The result is always explained** after every shot, from the settled board.
5. **The game is explained to a first-time player,** in the app and on the site, from the same words and diagrams.
6. **It works the same on Android and the web** and has been played by hand on a phone and in a desktop browser.

## 10. Quality and success

- A first-time player can aim and shoot after one short prompt and read why a turn went as it did.
- Changing the camera never changes the shot or the result.
- Shots are repeatable enough that skill matters, and collisions still make interesting outcomes.
- The four games feel different.
- It runs acceptably on a real mid-range Android phone, and in a desktop browser.
- People who played these games recognise them or tell the author how theirs differed, and the About page invites that.

These are observations to record in playtests, not numeric targets: there are no players yet to measure.

## 11. Status

| Area                                   | State                                                                                                                                                 |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| Shot, physics, settling, camera, input | Built and tested (87 automated tests, real input through the whole stack); **not played by hand on a phone**                                          |
| Kep                                    | Complete: scoring, rounds, computer sides, the full screen set in light and dark                                                                      |
| Batto                                  | Complete: opening toss, the three-hole race, bonus shots, finishing order and computer sides that choose between a hole and a hit; not played by hand |
| Guli Khela, Quick Dan                  | Not built                                                                                                                                             |
| Site                                   | Live at the address above: Home, How to play, About, Download, Privacy, Play, share image, theme toggle                                               |
| Releases                               | `v0.0.1` published with the APK, the web export and checksums; the site rebuilds on each release through a deploy hook                                |
| Checks                                 | Lint, token and colour checks, file size, game and site tests, a smoke test of every page, and a CI pipeline that passes on `main`                    |
| Not done                               | Playing on real devices; checking the rules with people who played; sound, saved settings and the shared pages                                        |

The order of work is in [`README_ROADMAP.md`](README_ROADMAP.md) and the checklist in [`../TODO.md`](../TODO.md).

## 12. Decisions and open questions

| Topic                 | Decision                                                | Needs                                                                                         |
| --------------------- | ------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Name                  | "Guli & Batto" is a working label                       | Name, spelling and cultural fit                                                               |
| Modes                 | Kep, Batto, Guli Khela, Quick Dan, all four complete    | The rules checked with at least one more person who played each                               |
| Platforms             | Android and web                                         | Whether to add iOS, a store or desktop builds later (not planned)                             |
| Orientation           | Portrait on phones; the web version resizes             | Playtests on real devices                                                                     |
| Language              | English, with the games' own words                      | None planned                                                                                  |
| Opponents             | One to three computer sides, same shot interface        | Whether they play each game convincingly                                                      |
| Rendering and physics | Compatibility renderer, Jolt physics, on every platform | Performance on real phones and browsers; Jolt in the browser is only seen to behave correctly |
| Site address          | `playgulibatto.vercel.app`                              | A custom domain later, if wanted                                                              |
| Contact details       | Not chosen                                              | An email or form to publish                                                                   |
| Persistence           | Local save only                                         | Browser storage behaviour and a clear reset                                                   |

## 13. Principles and documentation

**Principles.** Physics first. One simulation, several views. No people required. One game, on the web and on Android. Offline and private. Do the four games well before anything else. Be honest about tradition, in one place.

| Document                                                                                       | What it holds                                                         |
| ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| [`README_ABOUT.md`](README_ABOUT.md)                                                           | The About page: where the rules come from and what the author changed |
| [`README_GAME_RULES.md`](README_GAME_RULES.md)                                                 | Sources, the four games, turn flow and scoring                        |
| [`README_GAMEPLAY_FEATURES.md`](README_GAMEPLAY_FEATURES.md)                                   | The player-facing behaviour contract                                  |
| [`README_ARCHITECTURE.md`](README_ARCHITECTURE.md)                                             | Scenes, systems, dependencies, data flow                              |
| [`README_WEB_AND_APP_PLAN.md`](README_WEB_AND_APP_PLAN.md)                                     | The pages, the shared content, browser play, downloads                |
| [`README_VISUAL_DESIGN.md`](README_VISUAL_DESIGN.md), [`design/SCREENS.md`](design/SCREENS.md) | Visual language, tokens, screens                                      |
| [`README_IMPLEMENTATION.md`](README_IMPLEMENTATION.md)                                         | Build sequence and technical checks                                   |
| [`README_ROADMAP.md`](README_ROADMAP.md)                                                       | Phases and gates                                                      |
| [`CI.md`](CI.md), [`DEPLOY.md`](DEPLOY.md)                                                     | The pipeline, releases, and the Vercel setup                          |
| [`README_CODE_STANDARDS.md`](README_CODE_STANDARDS.md)                                         | Conventions and review checklist                                      |

**References.** [Banglapedia, "Folk Games"](https://en.banglapedia.org/index.php?title=Folk_Games) (Gulikhela); Godot documentation for [web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) and [Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) exports and [`RigidBody3D`](https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html). Reviewed 2026-10-21; check the documentation again when pinning a new Godot version.
