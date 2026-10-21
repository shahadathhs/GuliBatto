// Reads the latest GitHub release into what the download page shows. Pure and strict: anything
// unexpected yields null, so the page falls back to "no release yet" and never to a bad link.

export type Release = {
  version: string;
  notesUrl: string;
  apk: { url: string; sizeMb: number };
  checksumUrl: string | null;
};

const isRecord = (v: unknown): v is Record<string, unknown> => typeof v === "object" && v !== null;
const isHttps = (v: unknown): v is string => typeof v === "string" && v.startsWith("https://");

export function parseRelease(json: unknown): Release | null {
  if (!isRecord(json) || typeof json.tag_name !== "string" || !isHttps(json.html_url)) return null;
  if (!/^v\d+\.\d+\.\d+$/.test(json.tag_name) || !Array.isArray(json.assets)) return null;

  const assets = json.assets.filter(isRecord);
  const apk = assets.find((a) => typeof a.name === "string" && a.name.endsWith(".apk"));
  if (!apk || !isHttps(apk.browser_download_url) || typeof apk.size !== "number" || apk.size <= 0)
    return null;

  const sum = assets.find((a) => typeof a.name === "string" && a.name.endsWith(".apk.sha256"));
  return {
    version: json.tag_name.slice(1),
    notesUrl: json.html_url,
    apk: { url: apk.browser_download_url, sizeMb: Math.round(apk.size / 1e6) },
    checksumUrl: sum && isHttps(sum.browser_download_url) ? sum.browser_download_url : null,
  };
}
