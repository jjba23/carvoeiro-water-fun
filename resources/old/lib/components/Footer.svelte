<script lang="ts">
  import Map from "$lib/components/Map.svelte";
  import { t } from "$lib/i18n/translation";
  import ContactUs from "./ContactUs.svelte";
  import OpeningHours from "./OpeningHours.svelte";
</script>

<div class="align-center flex flex-col justify-center p-4">
  <div class="flex flex-wrap">
    <ContactUs />
    <OpeningHours />
  </div>
  <div class="my-8"><Map /></div>
  <div class="my-8 p-6">
    <h3 class="h3">{$t("i18n.review-us")}</h3>
    <p class="my-4">{$t("i18n.review-us-intro")}</p>
    <div class="flex flex-wrap items-center justify-center gap-6 p-6">
      <a href="https://maps.app.goo.gl/JcTNKNRXK37bx69W6"
        ><button class="variant-soft btn font-bold">🔗 {$t("i18n.review-us")}</button></a
      >
      <img
        src="/img/qr-maps-review.jpeg"
        width="200"
        height="200"
        alt="Leave a review for Carvoeiro Water Fun"
      />
    </div>
  </div>

  <div class="align-center my-6 flex flex-row flex-wrap justify-center gap-10">
    <div>
      <h3 class="h3">{$t("i18n.about-us-insurance")}</h3>

      <div class="justify-left mt-4 flex flex-col">
        <span><em>Proceedings from the Municipal Chamber of Lagoa E/8399/2023 date of 2023-03-13.</em></span>
        <span class="mt-2"
          >Civil Liability Insurance Policy No. 85/25935 Maritime Tourism €50,000.00 Death or Permanent</span
        >
        <span>Disability €1,120,000.00</span>
        <span>Treatment and Repatriation Expenses €196,000.00</span>
      </div>
    </div>
  </div>
  <hr />
  <p class="align-center my-6 text-center">
    {new Date().getFullYear()} &copy; {$t("i18n.copyright")}
  </p>
  <div class="align-center flex flex-col justify-center text-center">
    <small><em>{$t("i18n.code-license")}</em></small>
    <small>
      {$t("i18n.see-source-code")}
      <a class="font-bold text-primary-500" href="https://gitlab.com/jjba-projects/ss-carvoeiro"
        >{$t("i18n.here")}</a
      >
    </small>
  </div>
</div>
