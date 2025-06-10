import { l } from "$lib/i18n/i18n";
import { loadTranslations } from "$lib/i18n/translation";

export const prerender = false;
export const ssr = false;
export const csr = true;

/** @type {import('./$types').PageLoad} */
export async function load({ url }: { url: any }) {
  await loadTranslations(l);

  return {};
}
