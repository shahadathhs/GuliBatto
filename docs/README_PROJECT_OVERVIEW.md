# Guli & Batto — Project Overview

> **Working title.** The name, final rules, art direction, and release scope are not locked. This document records the current product hypothesis so implementation does not quietly turn into a much larger project.

## 1. The idea

Make a small, tactile 3D game inspired by the marble games the project owner remembers as **Guli Khela** and **Batto**. The player interacts with marbles and a physical play area rather than controlling human avatars. The same arena, marble behaviour, aiming system, and camera rig should support more than one ruleset.

The product should feel like playing on a real patch of ground: line up a shot, judge distance and angle, release, watch the marbles collide and roll, then understand why the turn was won or lost.

The game is a digital interpretation, not a claim that every region plays these games identically. Gulikhela is documented as a Bangladeshi folk game in Banglapedia. The available public research did not establish a reliable, standardized ruleset under the exact name “Batto”. That mode must remain explicitly provisional until checked with people who know it firsthand. See [`README_GAME_RULES.md`](README_GAME_RULES.md).

## 2. Product principles

1. **Physics first.** The pleasure of a shot comes from understandable direction, power, rolling, friction, and collisions. Do not hide weak physical behaviour under visual effects.
2. **One simulation, several views.** Camera modes change presentation, not the world state or shot outcome.
3. **No people required.** The first release shows the play surface, marbles, marks, and the environment. Human avatars and animation are not needed to communicate a turn.
4. **Offline-first.** No account, remote service, online match, analytics SDK, or server is required for core play.
5. **One small game before a platform.** Ship one polished arena and two clearly different rulesets before considering extra arenas, cosmetics, or a content-management tool.
6. **Be honest about tradition.** Separate source-backed description from new rules designed for the game.

## 3. Target experience

- **Primary platform:** Android phones.
- **Secondary platform:** desktop browsers, with mouse-and-keyboard controls. Touch input in mobile browsers is a useful test target, but must not compromise native Android controls.
- **Engine:** Godot 4, GDScript, 3D scenes, and the Compatibility renderer so a single project can target Android and Web.
- **Play style:** single-player, turn-based shots against a simple local opponent or challenge setup. No real-time networked play.
- **Audience:** players curious about marble games, people who remember playing them, and casual players who enjoy short skill-based rounds.
- **Session length:** short rounds that are easy to restart. This is a design target to validate in playtests, not a measured result.

## 4. Proposed first release (MVP)

### Must have

- One compact 3D ground arena with clear boundaries.
- A controllable striker marble and a small set of target/opponent marbles.
- Aim preview, bounded shot power, release-to-shoot, and a reliable turn state machine.
- Rolling, stopping, and marble-to-marble collisions that behave consistently enough to learn.
- A shared camera rig with orbit, zoom, elevation limits, reset, and a temporary action-follow view.
- Two selectable modes: **Guli Khela — adapted pit-and-strike rules** and **Batto Challenge — provisional knockout rules**.
- A local opponent that chooses legal, comprehensible shots; it does not need machine learning.
- Main menu, mode selection, in-game status, pause/restart, basic sound, and locally saved settings/progress.
- Android and browser test exports before content scope expands.
- A small static marketing site: what the game is, how to play, download, privacy. No backend.

### Explicitly out of scope

- Online multiplayer, matchmaking, friends, chat, accounts, leaderboards, cloud saves, or a backend.
- Human characters, skins, cinematics, open-world exploration, or realistic bodily animation.
- A web app that runs the game's menus, or a remote administrator dashboard. (A small marketing site for the game is in scope; see [`README_RELEASE.md`](README_RELEASE.md).)
- Large numbers of arenas, a campaign with dozens of levels, procedural content, paid assets, ads, or monetisation in the prototype.
- A promise of perfect physical equivalence to real-world marbles on every device. The goal is stable, legible game feel.

## 5. What would make the prototype worth continuing?

Continue only if tests show that:

- players can aim and shoot without a verbal explanation after a brief prompt;
- changing camera view never changes the shot direction or physics result;
- shots feel repeatable enough that skill matters, while collisions still create interesting outcomes;
- the two modes feel meaningfully different after a few rounds;
- the game runs acceptably on the developer's Android test device and in a supported desktop browser;
- the game remains enjoyable without accounts, unlock pressure, or internet access after installation.

Record observations rather than inventing numeric success metrics before there are test players. A useful first test is to ask three people unfamiliar with the prototype to complete a round while the developer stays quiet and notes where they get confused.

## 6. Assumptions and unresolved decisions

| Topic        | Current decision                                                                                                                                           | Needs validation                                                                    |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Project name | “Guli & Batto” is a working label                                                                                                                          | Name, spelling, and cultural fit                                                    |
| Gulikhela    | Use an adapted version of a documented pit-and-strike description                                                                                          | Local variants; whether to offer a faithful variant and a game-friendly variant     |
| Batto        | Provisional custom mode, not represented as a verified historic ruleset                                                                                    | Ask local players/elders; verify spelling, equipment, objective, and penalties      |
| View system  | Free camera plus a shot-follow mode                                                                                                                        | Control comfort on real phones                                                      |
| Opponent     | Simple rule-based aiming. Milestone 3 plays Guli Khela as a single-side score attack with a turn limit; the AI arrives with the second mode in Milestone 4 | Whether the score attack is fun enough alone, and whether hot-seat is wanted sooner |
| Persistence  | Local save only                                                                                                                                            | Browser storage behaviour and clear/reset UX                                        |
| Rendering    | Compatibility renderer for cross-platform scope                                                                                                            | Performance and visual quality on target devices                                    |

## 7. Documentation map

- [`README_ARCHITECTURE.md`](README_ARCHITECTURE.md) — scenes, systems, dependencies, and data flow.
- [`README_CODE_STANDARDS.md`](README_CODE_STANDARDS.md) — conventions and review checklist.
- [`README_GAME_RULES.md`](README_GAME_RULES.md) — evidence, provisional rules, turn flow, and scoring.
- [`README_GAMEPLAY_FEATURES.md`](README_GAMEPLAY_FEATURES.md) — the player-facing behaviour contract.
- [`README_IMPLEMENTATION.md`](README_IMPLEMENTATION.md) — build sequence and technical acceptance checks.
- [`README_RELEASE.md`](README_RELEASE.md) — versioning, CI releases, and the marketing site.
- [`README_ROADMAP.md`](README_ROADMAP.md) — staged scope and decision gates.
- [`README_VISUAL_DESIGN.md`](README_VISUAL_DESIGN.md) — environments, camera language, UI, and performance constraints.

## 8. Research references

- Banglapedia, “Folk Games”, including the entry for Gulikhela: <https://en.banglapedia.org/index.php?title=Folk_Games>
- Godot Engine, web export documentation: <https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html>
- Godot Engine, Android export documentation: <https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html>
- Godot Engine, `RigidBody3D`: <https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html>

Research review date: 2026-10-21. Platform details can change; verify the documentation again when pinning the exact Godot version.
