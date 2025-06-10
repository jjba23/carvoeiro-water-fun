<script lang="ts">
  import { t } from "$lib/i18n/translation";
  import { getDrawerStore } from "@skeletonlabs/skeleton";
  import LocaleButton from "./LocaleButton.svelte";

  const drawerStore = getDrawerStore();

  function drawerClose(): void {
    console.log(drawerStore);
    drawerStore.close();
  }
</script>

<nav class="list-nav p-4" aria-label="main navigation">
  <ul>
    <li>
      <a on:click={drawerClose} class="font-bold" href="/">{$t("i18n.home")}</a>
    </li>
    <li>
      <a on:click={drawerClose} class="font-bold" href="/services/speedboat">{$t("i18n.about-boat-tour")}</a>
    </li>
    <li>
      <a on:click={drawerClose} class="font-bold" href="/request-reservation/boat-tour"
        >{$t("i18n.book-now")}</a
      >
    </li>
    <li><LocaleButton /></li>
        <li>
      <a on:click={drawerClose} class="font-bold" href="https://maps.app.goo.gl/JcTNKNRXK37bx69W6"
        >{$t("i18n.review-us")}</a
      >
    </li>    
  </ul>
</nav>
