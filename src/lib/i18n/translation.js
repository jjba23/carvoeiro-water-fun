import i18n from "sveltekit-i18n";

/** @type {import('sveltekit-i18n').Config} */
const config = {
  loaders: [
    {
      locale: "en",
      key: "i18n",
      loader: async () => (await import("./data/en.json")).default
    },
    {
      locale: "pt",
      key: "i18n",
      loader: async () => (await import("./data/pt.json")).default
    },
    {
      locale: "es",
      key: "i18n",
      loader: async () => (await import("./data/es.json")).default
    },
    {
      locale: "fr",
      key: "i18n",
      loader: async () => (await import("./data/fr.json")).default
    },
    {
      locale: "nl",
      key: "i18n",
      loader: async () => (await import("./data/nl.json")).default
    },
    {
      locale: "de",
      key: "i18n",
      loader: async () => (await import("./data/de.json")).default
    }
  ]
};

export const { t, locale, locales, loading, loadTranslations } = new i18n(config);

loading.subscribe(($loading) => $loading && console.log("Loading translations..."));
