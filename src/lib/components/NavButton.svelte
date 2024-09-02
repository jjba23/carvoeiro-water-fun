<script lang="ts">
  export let buttonText: string = "";
  export let buttonLink: string = "";
</script>

<a href={buttonLink}>
  <button
    type="button"
    class="mb-2 me-2 rounded-lg bg-gradient-to-r from-teal-200 to-lime-200 px-5 py-2.5 text-center text-sm font-bold text-gray-900 hover:bg-gradient-to-l hover:from-teal-200 hover:to-lime-200 focus:outline-none focus:ring-4 focus:ring-lime-200 dark:focus:ring-teal-700"
  >
    ➜ {buttonText}
  </button>
</a>
