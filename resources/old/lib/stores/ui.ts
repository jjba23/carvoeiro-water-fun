import { writable } from "svelte/store";
import { browser } from "$app/environment";

const lStored = () => {
  try {
    if (browser) {
      if (window) {
        return window.localStorage.locale;
      }
    }
  } catch (e) {
    console.error(e);
    return "en";
  }
};

export const locale = writable(lStored() ?? "en");

locale.subscribe((value: string) => {
  try {
    if (browser) {
      if (window) {
        window.localStorage.locale = value;
      }
    }
  } catch (e) {
    console.error(e);
  }
});
