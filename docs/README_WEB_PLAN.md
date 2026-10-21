# Guli & Batto — Marketing Website Plan

> **Purpose:** plan the small public site in `web/`.  
> **Reference renders:** [design/web/](design/web/) holds the landing and download pages in light and dark, desktop and mobile. Values (version, size, hash) are placeholders.  
> **Status:** home, how to play, about, download and privacy are built, use the generated tokens, and are covered by lint, type-check, unit tests, a production build and a smoke test. Not yet done: the light/dark toggle (the site follows the system setting), an Open Graph image, and an accessibility and contrast pass against the renders. Deviations from this plan are noted where they apply.

## 1. Goal

**Explain the game and get people to install it.** The site is not a second product and has no backend of its own.

- **Distribution is a direct APK** hosted on GitHub Releases, so site traffic costs no bandwidth. A store listing is a later, separate decision.
- Visitors arrive mostly on a phone (a shared link) or on a desktop (who need the link on a phone). Both must be served.
- The site must feel like the same product as the game: same tokens, wordmark and rules ([README_VISUAL_DESIGN.md](README_VISUAL_DESIGN.md)).
- It must be honest about the rules in one place: the About page says where the rules come from and what the author changed ([README_ABOUT.md](README_ABOUT.md)). Pages do not label individual modes or call any rule official or authentic.

## 2. Sitemap and scope

**Launch:**

| Route                      | Purpose                                                             | Rendering                                     |
| -------------------------- | ------------------------------------------------------------------- | --------------------------------------------- |
| `/`                        | Landing: what it is, how it works, the modes, the download          | Static                                        |
| `/download`                | Install page: the APK, checksum, install steps                      | Static shell, release data revalidated hourly |
| `/how-to-play`             | Aim, power, camera, the four modes                                  | Static                                        |
| `/about`                   | About these games: the source of the rules and the author's changes | Static                                        |
| `/privacy`                 | What is and is not collected                                        | Static                                        |
| `/robots`, `/sitemap`, 404 | Generated                                                           | n/a                                           |

**After launch, only if wanted:**

| Route      | Purpose                                                                                                                                    |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `/play`    | Browser play through the game's web export (already produced by CI)                                                                        |
| `/rules`   | A place to publish the verified local variants once the research in [README_GAME_RULES.md](README_GAME_RULES.md) is done, with attribution |
| `/contact` | How to reach the developer, or to tell us how you played where you live                                                                    |

## 3. Landing page

One primary action on the page: **Download for Android**. Everything else is text or the arena illustration.

1. **Header:** wordmark; links How to play, Download, Privacy; a light/dark toggle.
2. **Hero:** a factual headline ("Line up the shot. Let the marbles roll."), one sentence of detail, the primary button, a meta line (version, size, minimum Android), and the arena illustration.
3. **How it works:** three steps, Aim, Release, Read the result.
4. **The modes:** one line each (Kep, Batto, Guli Khela, Quick Dan), no authenticity labels, then a short note and a link to the About page.
5. **The short list:** plays offline, progress stays on the device, real rolling and collisions, light and dark.
6. **Footer:** the cultural note and links.

Not on the page: taglines, testimonials, stock imagery, store badges for stores we are not on, fake review counts, a newsletter, a cookie banner.

## 4. Download page

Make a direct install feel safe and simple.

- **Primary button:** Download APK, linking to the latest release asset. A meta line shows version, size and architecture, read from the release.
- **Verify:** show the SHA-256 (short form on the page, full on the release) and the commands to check it.
- **Install steps:** download, open the file, allow installs from the browser once, open the game.
- **Good to know:** a direct download, not a store build, so Android warns; not available for iPhone; builds are signed with one fixed key so updates install over older ones.
- **Data source:** the GitHub Releases API (`GITHUB_REPOSITORY`, default `shahadathhs/GuliBatto`), revalidated hourly, with strict parsing of the response and the `.sha256` file.
- **Fallback:** if there is no release, the repository is private, or GitHub is down, show "No release available yet" with a plain link and **no download button**. A button must never point at an unverified URL. A private repository's assets cannot be downloaded anonymously, so until the repository or its releases are public this fallback is what visitors see.
- **No device detection:** show everything; layout, not user-agent sniffing, decides what matters.

## 5. Trust and privacy

- Say plainly that this is a direct install and why.
- Sign every build with the same key and publish the SHA-256 on every release.
- No tracking, no third-party scripts, no third-party fonts at runtime, no cookies, no analytics at launch.
- The privacy page states that the game collects nothing, that data stays on the device, and that the download is served by GitHub.

## 6. Technical decisions

- **Next.js, App Router, TypeScript**, in `web/`. It holds no game logic and no copy of the rules; it describes them.
- **Static first.** Pages are pre-rendered; the download page revalidates hourly.
- **No JavaScript required** for any content or for downloading. The theme follows `prefers-color-scheme`; the toggle appears only after hydration and stores an explicit choice on the device only.
- **Tokens.** The site's CSS custom properties are generated from the same token source as the game's palette. Until that exists, the values in [README_VISUAL_DESIGN.md](README_VISUAL_DESIGN.md) are copied by hand and a grep must find no other colours.
- **Illustrations** are inline SVG built from the same marble and arena shapes as the concept renders, not screenshots of the game until real captures exist.
- **SEO and sharing:** a title and description per page, an Open Graph image, sitemap and robots.
- **Performance:** no heavy images; fonts bundled and self-hosted; the landing page is HTML and SVG.
- **Accessibility:** both themes pass the contrast table; keyboard reachable with visible focus; real headings; reduced motion respected.
- **Hosting:** undecided (any static or Node host; the free tier's limits must be checked before launch).
- **Tooling:** oxlint, type-check, unit tests, build and a smoke test run in CI (and in `make check`); see [CI.md](CI.md).

## 7. Browser play (optional, later)

The release already includes the game's web export. A `/play` page would load it only after the visitor presses Play, show real loading and failure states (no WebAssembly, no WebGL 2, download error), and say it needs JavaScript. The export is single-threaded, so no special headers are needed. Expect a first-load download of tens of megabytes; measure it from the real export before promising anything, and check the host's bandwidth terms. It is a secondary "Try in your browser" link; the download stays primary.

## 8. Implementation phases (web)

1. **Skeleton:** layout, header and footer, wordmark, theme tokens, light and dark. (First version built; no tokens yet.)
2. **Landing, how to play, privacy:** content as above, responsive, no JavaScript. (First version built.)
3. **Download:** release integration with revalidation and fallback. (Built; needs a real release to verify.)
4. **Quality:** tokens and colour check, lint, tests, metadata, Open Graph image, sitemap, robots, accessibility and contrast pass, a visual pass at desktop and mobile against the renders.
5. **After launch:** `/rules` with verified variants, then optional `/play`.

### Exit criteria for launch

- A visitor on a phone goes from landing to an installed game in a few taps, following only the page.
- A visitor on a desktop can get the link onto a phone (a copyable link; a QR code is optional).
- The download button always points at the latest release; the page still works if GitHub is slow or down.
- Pages work with JavaScript disabled.
- No third-party requests, cookies or trackers.
- Both themes and both widths pass the visual checklist.

## 9. Open items

- Minimum Android version and the real APK size (the renders show placeholders).
- Whether the source repository is public, which decides the "Source" link and whether anonymous download works.
- Site hosting and domain.
- Whether release notes come from generated notes or a curated file.
- The final font (a shared decision with the game, including Bangla coverage).
- Screenshots: use real captures once the game has art; until then, illustrations.
