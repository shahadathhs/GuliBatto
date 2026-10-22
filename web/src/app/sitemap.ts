import type { MetadataRoute } from "next";
import { GAMES } from "@/lib/content";
import { SITE_URL } from "@/lib/site";
import { hasPlayBuild } from "@/lib/play-build";

const PATHS = ["", "/games", "/how-to-play", "/about", "/contact", "/download", "/privacy"];

export default function sitemap(): MetadataRoute.Sitemap {
  const paths = [...PATHS, ...GAMES.map((g) => `/games/${g.slug}`)];
  if (hasPlayBuild()) paths.push("/play");
  return paths.map((path) => ({ url: `${SITE_URL}${path}` }));
}
