<script lang="ts">
  import type { MetaOptions } from "$lib/meta";

  export let opt: MetaOptions;
</script>

<title>{opt.title}</title>
<meta name="description" content={opt.description} />
<meta property="og:title" content={opt.title} />
<meta property="og:description" content={opt.description} />
<meta property="og:image" content={opt.imageUrl} />
