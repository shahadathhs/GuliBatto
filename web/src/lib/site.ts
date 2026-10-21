// The public address of the site, for the sitemap and robots. Set SITE_URL in the host's settings.
export const SITE_URL = (process.env.SITE_URL ?? "http://localhost:3000").replace(/\/$/, "");
