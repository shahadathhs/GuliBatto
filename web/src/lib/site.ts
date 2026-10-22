// The public address of the site, for the sitemap, robots, the share image and metadata.
// Order: SITE_URL (set it for a custom domain), then the production address Vercel provides for
// the project, then localhost for development.
export function resolveSiteUrl(env: Record<string, string | undefined>): string {
  const vercel = env.VERCEL_PROJECT_PRODUCTION_URL;
  const raw = env.SITE_URL || (vercel ? `https://${vercel}` : "http://localhost:3000");
  return raw.replace(/\/+$/, "");
}

export const SITE_URL = resolveSiteUrl(process.env);
