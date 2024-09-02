<script lang="ts">
  export let buttonText: string = "";
  export let buttonLink: string = "";
</script>

<a href={buttonLink}>
  <button
    type="button"
    class="mb-2 me-2 rounded-lg bg-gradient-to-br from-green-400 to-blue-600 px-5 py-2.5 text-center text-sm font-extrabold text-white hover:bg-gradient-to-bl focus:outline-none focus:ring-4 focus:ring-green-200 dark:focus:ring-green-800"
  >
    {buttonText}
  </button>
</a>
