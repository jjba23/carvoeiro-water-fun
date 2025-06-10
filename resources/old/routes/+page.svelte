<script lang="ts">
  import { t } from "$lib/i18n/translation";
  import { fade } from "svelte/transition";
  // @ts-ignore
  import Carousel from "svelte-carousel";
  import { browser } from "$app/environment";
  import LocaleButton from "$lib/components/LocaleButton.svelte";
  import Meta from "$lib/components/Meta.svelte";
  import type { MetaOptions } from "$lib/meta";
  let carousel: Carousel; // for calling methods of the carousel instance
  const handleNextClick = () => {
    carousel.goToNext();
  };
  const handlePrevClick = () => {
    carousel.goToPrev();
  };
  let imgs = [
    { src: "/img/alg2.jpg", alt: "Carvoeiro Water Fun" },
    { src: "/img/FB_IMG_1719434125429.jpg", alt: "Carvoeiro Water Fun" },
    { src: "/img/FB_IMG_1685656771764(1).jpg", alt: "Carvoeiro Water Fun" },
    { src: "/img/car1-e1685666854978.jpg", alt: "Carvoeiro Water Fun" },
    { src: "/img/IMG_20230629_133333_1(1).jpg", alt: "Carvoeiro Water Fun" },
    { src: "/img/IMG_20230629_133209_1(1).jpg", alt: "Carvoeiro Water Fun" },
    { src: "/img/FB_IMG_1685657047621(1).jpg", alt: "Carvoeiro Water Fun" }
  ];
  let initImgs = [
    { src: "/img/FB_IMG_1719434096367.jpg", alt: "Carvoeiro Water Fun" },
    { src: "/img/barco-scaled.jpg", alt: "Carvoeiro Water Fun" },
    { src: "/img/car2.jpeg", alt: "Carvoeiro Water Fun" }
  ];
  let opt: MetaOptions = {
    title: t.get("i18n.title-home"),
    description: t.get("i18n.description"),
    imageUrl: "https://www.carvoeirowaterfun.com/img/barco-scaled.jpg"
  };
</script>

<svelte:head>
  <Meta {opt} />
</svelte:head>
<div transition:fade={{ delay: 180, duration: 300 }}>
  <h1 class="h1 mt-4 text-center">
    Carvoeiro <span class="bg-gradient-to-r from-sky-600 to-blue-500 bg-clip-text font-black text-transparent"
      >Water Fun</span
    >
  </h1>
  <h2 class="h1 my-4 text-center">⚓️</h2>
  <div class="my-6">
    <p class="my-4 text-center text-lg">
      {$t("i18n.catchy-header-1")}
    </p>

    <p class="text-center text-lg">
      {$t("i18n.catchy-header-2")}
    </p>

    <div class="align-center mt-4 flex flex-wrap items-center justify-center gap-2 text-center">
      <a href="/request-reservation/boat-tour">
        <button class="variant-soft-success btn text-lg font-bold">📅 {$t("i18n.book-now")}</button></a
      >
      <a href="/services/speedboat">
        <button class="variant-soft btn text-lg font-bold">🌊 {$t("i18n.about-boat-tour")}</button></a
      >
      <LocaleButton />
    </div>
  </div>

  <section class="grid grid-cols-1 items-center gap-4 p-6 sm:grid-cols-3 md:grid-cols-3">
    {#each initImgs as img}
      <div>
        <picture>
          <source srcset={img.src} />
          <img class="h-auto max-w-full rounded-xl" alt={img.alt} src={img.src} />
        </picture>
      </div>
    {/each}
  </section>

  <div class="align-center my-6 flex flex-wrap items-center justify-center p-4">
    <div class="w-full lg:w-2/5">
      <section class="my-8">
        <h2 class="h2">{$t("i18n.enjoy-algarve-coast")}</h2>
        <p class="mt-3 text-lg">
          {$t("i18n.enjoy-1")}
        </p>
        <p class="mt-3 text-lg">
          🐬 {$t("i18n.enjoy-2")}
        </p>
        <p class="mt-3 text-lg">
          {$t("i18n.enjoy-3")}
        </p>
      </section>
    </div>

    <div class="w-full lg:w-3/5">
      <div class=" ">
        <div class="p-1 md:p-6">
          {#if browser}
            <Carousel autoplay autoplayDuration={2000} bind:this={carousel}>
              {#each imgs as img}
                <div class="">
                  <picture>
                    <source srcset={img.src} />
                    <img loading="lazy" class="h-auto max-w-full rounded-xl" src={img.src} alt={img.alt} />
                  </picture>
                </div>
              {/each}
            </Carousel>
          {/if}
        </div>
      </div>
    </div>
  </div>
</div>

<hr class="my-6" />
