<script lang="ts">
  import { t } from "$lib/i18n/translation";
  import { fade } from "svelte/transition";
</script>

<div transition:fade={{ delay: 180, duration: 300 }}>
  <h2 class="h2 my-4 text-center">{$t("i18n.book-boat-title")} 🚤</h2>
  <p class="my-4 text-lg">{$t("i18n.duration")}:<strong class="mx-2"> 2 h</strong></p>
  <p class="my-4 text-lg">
    {$t("i18n.boat-location")}: <strong class="font-bold">Praia do Carvoeiro</strong>
  </p>
  <div class="flex flex-row flex-wrap">
    <div class="w-full md:w-1/2">
      <div class="flex justify-center text-center">
        <a href="/request-reservation/boat-tour">
          <button class="variant-soft-success btn mt-4 text-lg font-bold">📅 {$t("i18n.book-now")}</button></a
        >
      </div>

      <p class="mt-4 text-lg">
        {$t("i18n.boat-dive")}
      </p>

      <p class="mt-4 text-lg">
        {$t("i18n.boat-catchy-1")}
      </p>

      <p class="mt-4"></p>
    </div>
    <div class="w-full p-6 md:w-1/2">
      <img class="h-auto max-w-full rounded-lg" src="/img/barco-scaled.jpg" alt="Carvoeiro Water Fun" />
    </div>
  </div>

  <p class="mt-4 text-lg">
    {$t("i18n.boat-catchy-2")}
  </p>

  <p class="mt-4 text-lg">
    {$t("i18n.boat-catchy-3")}
  </p>

  <p class="mt-4 text-lg">{$t("i18n.boat-catchy-4")}</p>

  <hr class="my-6" />

  <h4 class="h4 my-6">{$t("i18n.restrictions-title")}</h4>
  <p class="mt-4 text-lg">
    {$t("i18n.restrictions-body-1")}
  </p>

  <h4 class="h4 my-6">{$t("i18n.included-title")}</h4>
  <p class="mt-4 text-lg">
    {$t("i18n.included-body-1")}
  </p>

  <h4 class="h4 my-6">{$t("i18n.not-included-title")}</h4>
  <p class="mt-4 text-lg">
    {$t("i18n.not-included-body-1")}
  </p>

  <h4 class="h4 my-6">{$t("i18n.cancellation-policy-title")}</h4>
  <p class="mt-4 text-lg">
    {$t("i18n.cancellation-policy-body-1")}
  </p>
</div>

<hr class="my-6" />
