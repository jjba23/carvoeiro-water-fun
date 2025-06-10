<script lang="ts">
  export let inputLabel = "";
  export let inputRequired = false;
  export let inputType = "text";
  export let inputId = "";
  export let inputPlaceholder = "";
</script>

<div class="mb-5">
  <label for={inputId} class="mb-2 block text-xl font-bold">{inputLabel}</label>
  <input
    type={inputType}
    required={inputRequired}
    id={inputId}
    name={inputId}
    placeholder={inputPlaceholder}
    class="input p-3 text-xl"
  />
</div>
