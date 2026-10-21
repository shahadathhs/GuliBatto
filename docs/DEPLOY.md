# Deploying Guli & Batto (GitHub Releases + Vercel)

> **Status: live.** The site is deployed at <https://playgulibatto.vercel.app> and serves the home page, how to play, about, download, privacy and play pages, the web export at `/play`, `robots.txt` and `sitemap.xml` (checked 2026-10-21). The Vercel deploy hook is stored as the GitHub secret `VERCEL_DEPLOY_HOOK`. The release `v0.0.1` was published by the pipeline on 2026-10-21 with an APK, Windows, macOS and Linux builds, the web export and checksums. Provider screens change; check each provider's current documentation and correct this file afterwards.

## Overview

| Piece                         | Host            | Notes                                                                                                                    |
| ----------------------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Website (`web/`)              | Vercel          | Static pages, plus the browser game served at `/play`                                                                    |
| Game files for every platform | GitHub Releases | Android APK, Windows, macOS and Linux builds, the web export, and checksums. Direct downloads; there is no store listing |
| API, database                 | none            | The game is offline and private; there is no backend                                                                     |

The site never builds the game. CI builds every platform and attaches the files to a release; the site reads the latest release when it builds and fetches the browser export from it.

> **The repository, or at least its releases, must be public** for visitors to download the files. Anonymous visitors cannot download assets from a private repository's releases, and the site's download page falls back to "No release available yet" with no button.

## 1. The website (Vercel)

1. Import the repository. Set the root directory to `web` with the workspace install (the repo is a pnpm workspace).
2. Leave the build command as the project default. `pnpm build` in `web/` runs `scripts/fetch-play-build.mjs` first, which downloads the web export from the release (default: the rolling `latest`) into `public/play-build`, and then `next build`. A failed fetch never fails the build; `/play` then says the browser version is unavailable.
3. Set environment variables:
   - `SITE_URL`: optional. The sitemap, `robots.txt`, the share image and the metadata use it. When it is unset the site uses the production address Vercel provides for the project (`VERCEL_PROJECT_PRODUCTION_URL`), which is `https://playgulibatto.vercel.app` here, and falls back to `http://localhost:3000` in development. Set it only for a custom domain. (Before this fallback existed, the live site listed `localhost` in its sitemap and share image.)
   - `GITHUB_REPOSITORY`: only if the repository is not `shahadathhs/GuliBatto`.
   - `PLAY_BUILD_TAG`: only to serve the web export from a release other than `latest`.
4. Add a **Deploy Hook** for the `main` branch (project **Settings**, **Git**, **Deploy Hooks**) and store its URL as the GitHub repository secret `VERCEL_DEPLOY_HOOK` (`gh secret set VERCEL_DEPLOY_HOOK --repo shahadathhs/GuliBatto`). Done for this project. The release job posts to it so the site rebuilds and picks up the new release and the new web export. Without the secret the job prints a notice and the site updates on its next deploy.
5. Confirm that public pages render without JavaScript, that `robots.txt` and `sitemap.xml` answer, and that `/play` loads the game.

## 2. Releases

```sh
make version v=0.2.0     # write the version into every file that carries it (no git)
make release v=0.2.0     # the same, then commit and push (you run this; nothing runs it automatically)
```

When that commit reaches `main`, CI builds every platform and publishes `Guli & Batto vX.Y.Z` as the latest release, and refreshes the rolling `latest` build. See [CI.md](CI.md) for the files and the secrets.

**Android signing key.** For builds that install over each other, store one fixed debug key as a secret, once:

```sh
make -s android-key | gh secret set ANDROID_DEBUG_KEYSTORE_BASE64
```

Changing the secret changes the signing key, and phones will refuse to update over a build signed with the old one.

## 3. Smoke test

```sh
SITE=https://playgulibatto.vercel.app
curl -s $SITE/ | grep -c "Line up the shot"       # the home page renders
curl -s $SITE/download | grep -o "No release is published yet\|Download APK"
curl -sI $SITE/play-build/index.wasm | head -3      # the web export is served
curl -s $SITE/robots.txt
```

Then open `/play`, press Play, and toss a marble. Download one file from the release and check it against `SHA256SUMS`.

## Operations

- **New app version:** `make release v=X.Y.Z`, merge to `main`, and let CI publish. The deploy hook rebuilds the site.
- **Roll back the site:** promote an earlier deployment in Vercel.
- **Remove a bad release:** `gh release delete vX.Y.Z --cleanup-tag --yes`, then bump to a new version.
- **Rotate the Android key:** see above; expect a one-time reinstall for users.
- **Monitoring:** nothing is monitored yet; add uptime monitoring now that the site is live.
- **Test the hook:** `curl -fsS -X POST "<hook url>"` triggers a rebuild without a release.
