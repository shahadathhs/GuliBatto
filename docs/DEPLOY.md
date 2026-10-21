# Deploying Guli & Batto (GitHub Releases + Vercel)

> **Status: not deployed yet.** Nothing here has been set up on Vercel, and the Vercel deploy hook secret does not exist. The release half already ran once: the earlier version of the pipeline published a `v0.0.1` release with an APK and a web export on 2026-10-21, and that release was deleted when the pipeline was rebuilt to this design. Provider screens change; check each provider's current documentation and correct this file afterwards.

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
   - `SITE_URL`: the public origin, used for the sitemap, `robots.txt`, the share image and metadata (for example `https://guli-batto.vercel.app`). It defaults to `http://localhost:3000`, so set it.
   - `GITHUB_REPOSITORY`: only if the repository is not `shahadathhs/GuliBatto`.
   - `PLAY_BUILD_TAG`: only to serve the web export from a release other than `latest`.
4. Add a **Deploy Hook** for the `main` branch and store its URL as the GitHub repository secret `VERCEL_DEPLOY_HOOK`. The release job posts to it so the site rebuilds and picks up the new release and the new web export. Without the secret the job prints a notice and the site updates on its next deploy.
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
SITE=https://your-site.example
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
- **Monitoring:** nothing is monitored yet; add uptime monitoring for the site once it is live.
