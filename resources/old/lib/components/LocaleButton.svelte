<script lang="ts">
  import { locale } from "$lib/stores/ui";
  import { get } from "svelte/store";

  const updateLocale = (e: any) => {
    let l = e.target.value;
    locale.set(l);
    location.reload();
  };
  const isCurrentLocale = (opt: string) => opt == get(locale);
</script>

<div>
  <select on:change={updateLocale} class="variant-soft rounded-xl p-3 font-bold">
    <option selected={isCurrentLocale("en")} value="en">🇺🇸 English</option>
    <option selected={isCurrentLocale("pt")} value="pt">🇵🇹 Português</option>
    <option selected={isCurrentLocale("es")} value="es">🇪🇸 Español</option>
    <option selected={isCurrentLocale("nl")} value="nl">🇳🇱 Nederlands</option>
    <option selected={isCurrentLocale("de")} value="de">🇩🇪 Deutsch</option>
    <option selected={isCurrentLocale("fr")} value="fr">🇫🇷 Français</option>
  </select>
</div>
