<script lang="ts">
  import { t } from "$lib/i18n/translation";
</script>

<div class="w-full p-4 md:w-1/2">
  <h2 class="h2">{$t("i18n.contact-us")}</h2>
  <div class="justify-left mt-4 flex flex-col text-lg">
    <p class="my-2">
      {$t("i18n.contact-us-header")}
    </p>
    <span
      >📞 Telephone: <a
        class="font-bold text-primary-500 underline"
        href="tel:+351931933847"
        itemprop="telephone">+351 931 933 847</a
      ></span
    >
    <span class="font-bold"
      >📞 WhatsApp:
      <a class="font-bold text-emerald-500 underline" href="https://wa.me/+351931933847">+351 931 933 847</a
      ></span
    >
    <span
      >📨 Email: <a href="mailto:carvoeirowaterfun@gmail.com" class="font-bold text-primary-500 underline"
        >carvoeirowaterfun@gmail.com</a
      ></span
    >
    <span class="mt-4">{$t("i18n.call-costs")}</span>
    <span class="mt-4">
      <b class="font-bold">{$t("i18n.address")}</b>:
      <span itemprop="address">Rua do Casino, 29 A, Carvoeiro, 8400-515 Praia do Carvoeiro</span>
    </span>
  </div>
</div>
