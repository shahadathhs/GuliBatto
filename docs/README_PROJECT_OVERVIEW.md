# Guli & Batto — Project Overview

> **Working title.** The name, final rules, art direction, and release scope are not locked. This document records the current product hypothesis so implementation does not quietly turn into a much larger project.

## 1. The idea

Make a small, tactile 3D game inspired by the traditional marble games the project owner played as a child: **Guli Khela**, **Batto**, and the toss at the hole they share. The player interacts with marbles and a physical play area rather than controlling human avatars. The same arena, marble behaviour, aiming system, and camera rig should support more than one ruleset.

The product should feel like playing on a real patch of ground: line up a shot, judge distance and angle, release, watch the marbles collide and roll, then understand why the turn was won or lost.

This game is one person's attempt to bring childhood memories back. Nothing in it is invented from nothing: each mode starts from a game people played, the author modified the rules for play on a phone, and one central page, [`README_ABOUT.md`](README_ABOUT.md), says so plainly, so no mode needs an "adapted" or "provisional" label. The sources are listed in [`README_GAME_RULES.md`](README_GAME_RULES.md).

## 2. Product principles

1. **Physics first.** The pleasure of a shot comes from understandable direction, power, rolling, friction, and collisions. Do not hide weak physical behaviour under visual effects.
2. **One simulation, several views.** Camera modes change presentation, not the world state or shot outcome.
3. **No people required.** The first release shows the play surface, marbles, marks, and the environment. Human avatars and animation are not needed to communicate a turn.
4. **Offline-first.** No account, remote service, online match, analytics SDK, or server is required for core play.
5. **One small game before a platform.** Ship one polished arena and a few clearly different modes before considering extra arenas, cosmetics, or a content-management tool.
6. **Be honest about tradition, in one place.** The About page names the sources and lists what the author changed. Modes carry no authenticity labels, and nothing claims to be the official rules.

## 3. Target experience

- **Primary platform:** Android phones.
- **Secondary platform:** desktop browsers, with mouse-and-keyboard controls. Touch input in mobile browsers is a useful test target, but must not compromise native Android controls.
- **Engine:** Godot 4, GDScript, 3D scenes, and the Compatibility renderer so a single project can target Android and Web.
- **Play style:** single-player, turn-based shots against a simple local opponent or challenge setup. No real-time networked play.
- **Audience:** players curious about marble games, people who remember playing them, and casual players who enjoy short skill-based rounds.
- **Session length:** short rounds that are easy to restart. This is a design target to validate in playtests, not a measured result.

## 3a. Who it is for

- **People who remember playing.** They will judge the feel and the rules first. They need a way to say how they actually played, and the game must not lecture them.
- **Curious players.** They have never played marbles this way. They need to understand a shot without being told, in the first minute.
- **Casual mobile players.** Short rounds, one hand, no account, no ads.

## 3b. Goals

1. A shot that feels physical and learnable.
2. Four modes that ask for different decisions, on one shared foundation.
3. A game that runs acceptably on a mid-range Android phone and in a desktop browser.
4. One honest About page that says where the rules come from and what the author changed.
5. A small public site that explains the game and distributes the APK.

## 4. Proposed first release (MVP)

### Must have

- One compact 3D ground arena with clear boundaries.
- A controllable striker marble and a small set of target/opponent marbles.
- Aim preview, bounded shot power, release-to-shoot, and a reliable turn state machine.
- Rolling, stopping, and marble-to-marble collisions that behave consistently enough to learn.
- A shared camera rig with orbit, zoom, elevation limits, reset, and a temporary action-follow view.
- Four selectable modes, each a modernised version of a remembered game: **Kep** (the toss at the hole), **Batto** (a race along three holes and back), **Guli Khela** (the line, the hole, the stake and the _baad_ marble) and **Quick Dan** (one round of Guli Khela, optional). Order of building: Kep, Batto, Guli Khela, Quick Dan. Rules and sources are in [`README_GAME_RULES.md`](README_GAME_RULES.md).
- One to three local opponents (AI) that choose legal, comprehensible shots; no machine learning. Batto plays with two to four sides.
- Main menu, mode selection, an About page, in-game status, pause/restart, basic sound, and locally saved settings/progress.
- Android and browser test exports before content scope expands.
- A small static marketing site: what the game is, how to play, download, privacy. No backend.

### Explicitly out of scope

- Online multiplayer, matchmaking, friends, chat, accounts, leaderboards, cloud saves, or a backend.
- Human characters, skins, cinematics, open-world exploration, or realistic bodily animation.
- A web app that runs the game's menus, or a remote administrator dashboard. (A small marketing site for the game is in scope; see [`CI.md`](CI.md).)
- Large numbers of arenas, a campaign with dozens of levels, procedural content, paid assets, ads, or monetisation in the prototype.
- A promise of perfect physical equivalence to real-world marbles on every device. The goal is stable, legible game feel.

## 5. What would make the prototype worth continuing?

Continue only if tests show that:

- players can aim and shoot without a verbal explanation after a brief prompt;
- changing camera view never changes the shot direction or physics result;
- shots feel repeatable enough that skill matters, while collisions still create interesting outcomes;
- the modes feel meaningfully different after a few rounds;
- the game runs acceptably on the developer's Android test device and in a supported desktop browser;
- the game remains enjoyable without accounts, unlock pressure, or internet access after installation.

Record observations rather than inventing numeric success metrics before there are test players. A useful first test is to ask three people unfamiliar with the prototype to complete a round while the developer stays quiet and notes where they get confused.

### Repository layout

```text
GuliBatto/
├── game/        Godot project (scenes, scripts, resources, tests)
├── web/         marketing site (Next.js)
├── scripts/     version bump, Android CI setup, concept renders
├── docs/        this specification and the design renders
├── Makefile     command surface
└── VERSION      source of truth for releases
```

Details are in [`README_ARCHITECTURE.md`](README_ARCHITECTURE.md).

## 6. Assumptions and unresolved decisions

| Topic        | Current decision                                                                                                                                                                                      | Needs validation                                                                                        |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Project name | “Guli & Batto” is a working label                                                                                                                                                                     | Name, spelling, and cultural fit                                                                        |
| Guli Khela   | The kep, jalla, stake, _baad_ and fine game from a written Bangla account, cross-checked with Banglapedia; played for keeps; winner takes the ground; the scatterer keeps it after three empty passes | What a fine costs and the usual stake where people played                                               |
| Batto        | The author's three-hole route race, H1 → H2 → H3 → H2 → H1; a hit or reaching a hole earns a bonus shot, capped at three in a row                                                                     | At least one more account; the hole spacing                                                             |
| Kep          | The opening toss as a short precision mode                                                                                                                                                            | Scoring and number of rounds; how the toss is thrown                                                    |
| Quick Dan    | One round of Guli Khela as a profile of it                                                                                                                                                            | Whether short sessions need it; may be cut                                                              |
| View system  | Free camera plus a shot-follow mode                                                                                                                                                                   | Control comfort on real phones                                                                          |
| Opponents    | One to three AI sides using the same shot interface. The AI arrives with Batto in Milestone 4; Milestone 3 (Kep) tests with a debug hot-seat only                                                     | Whether the first AI is good enough for a race and for the _baad_ game; whether real hot-seat is wanted |
| Persistence  | Local save only                                                                                                                                                                                       | Browser storage behaviour and clear/reset UX                                                            |
| Rendering    | Compatibility renderer for cross-platform scope                                                                                                                                                       | Performance and visual quality on target devices                                                        |
| Orientation  | Portrait, 390 × 844 reference (proposed; the scaffold was first set to landscape without a decision)                                                                                                  | Aiming comfort and arena readability on real phones, in both orientations                               |
| UI language  | English with Bangla terms (_jalla_, _kep_, _dan_, _baad_); full Bangla support open and now more likely, since the games' own words are Bangla                                                        | Whether Bangla ships, and a font that covers both scripts in Godot and on the web                       |
| Distribution | Direct APK from GitHub Releases, plus a marketing site                                                                                                                                                | Whether a store listing is wanted, and where the site is hosted                                         |

## 7. Documentation map

- [`README_ARCHITECTURE.md`](README_ARCHITECTURE.md) — scenes, systems, dependencies, and data flow.
- [`README_CODE_STANDARDS.md`](README_CODE_STANDARDS.md) — conventions and review checklist.
- [`README_GAME_RULES.md`](README_GAME_RULES.md) — sources, the four modes, turn flow, and scoring.
- [`README_GAMEPLAY_FEATURES.md`](README_GAMEPLAY_FEATURES.md) — the player-facing behaviour contract.
- [`README_IMPLEMENTATION.md`](README_IMPLEMENTATION.md) — build sequence and technical acceptance checks.
- [`README_ABOUT.md`](README_ABOUT.md) — the central About page: where the rules come from and what the author changed.
- [`README_WEB_PLAN.md`](README_WEB_PLAN.md) — the marketing site: pages, download flow, trust, exit criteria.
- [`CI.md`](CI.md) — pipeline, tooling, secrets and the planned gates.
- [`design/SCREENS.md`](design/SCREENS.md) — concept renders of every screen and the site.
- [`README_ROADMAP.md`](README_ROADMAP.md) — staged scope and decision gates.
- [`README_VISUAL_DESIGN.md`](README_VISUAL_DESIGN.md) — environments, camera language, UI, and performance constraints.

## 8. Research references

- Banglapedia, “Folk Games”, including the entry for Gulikhela: <https://en.banglapedia.org/index.php?title=Folk_Games>
- Godot Engine, web export documentation: <https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html>
- Godot Engine, Android export documentation: <https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html>
- Godot Engine, `RigidBody3D`: <https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html>

Research review date: 2026-10-21. Platform details can change; verify the documentation again when pinning the exact Godot version.
