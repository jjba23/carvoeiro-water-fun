import { locale } from "$lib/stores/ui";
import { get } from "svelte/store";

export const l = get(locale) ?? "en";
