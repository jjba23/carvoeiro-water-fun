<script lang="ts">
  import { fade } from "svelte/transition";
  import type { PageData } from "./$types";
  import type { MetaOptions } from "$lib/meta";
  import { t } from "$lib/i18n/translation";
  import Meta from "$lib/components/Meta.svelte";

  export let data: PageData;

  let opt: MetaOptions = {
    title: t.get("i18n.title-booking"),
    description: t.get("i18n.description"),
    imageUrl: "https://www.carvoeirowaterfun.com/img/barco-scaled.jpg"
  };
</script>

<svelte:head>
  <Meta {opt} />
</svelte:head>
<section class="mt-8" transition:fade={{ delay: 180, duration: 300 }}></section>
