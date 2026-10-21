import type { MetadataRoute } from "next";
import { SITE_URL } from "@/lib/site";
import { hasPlayBuild } from "@/lib/play-build";

const PATHS = ["", "/how-to-play", "/about", "/download", "/privacy"];

export default function sitemap(): MetadataRoute.Sitemap {
  const paths = hasPlayBuild() ? [...PATHS, "/play"] : PATHS;
  return paths.map((path) => ({ url: `${SITE_URL}${path}` }));
}
