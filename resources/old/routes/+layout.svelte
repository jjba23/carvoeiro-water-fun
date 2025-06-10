<script lang="ts">
  import Footer from "$lib/components/Footer.svelte";
  import Navigation from "$lib/components/Navigation.svelte";
  import { t } from "$lib/i18n/translation";
  import { AppBar, AppShell, Drawer, getDrawerStore, initializeStores } from "@skeletonlabs/skeleton";
  import { Toaster } from "svelte-sonner";
  import "../app.pcss";

  initializeStores();

  const drawerStore = getDrawerStore();

  function drawerOpen(): void {
    drawerStore.open({});
  }
</script>

<Drawer>
  <h2 class="h4 p-4">🌊 {$t("i18n.sea-sports-carvoeiro")}</h2>
  <hr />
  <Navigation />
</Drawer>

<AppShell slotSidebarLeft="bg-surface-500/5 w-0 lg:w-64">
  <svelte:fragment slot="header">
    <AppBar>
      <svelte:fragment slot="lead">
        <div class="flex items-center">
          <button class="btn btn-sm mr-4 lg:hidden" on:click={drawerOpen}>
            <span>
              <svg viewBox="0 0 100 80" class="fill-token h-4 w-4">
                <rect width="100" height="20" />
                <rect y="30" width="100" height="20" />
                <rect y="60" width="100" height="20" />
              </svg>
            </span>
          </button>
          <h3 class="h3"><a href="/">🌊 {$t("i18n.sea-sports-carvoeiro")}</a></h3>
        </div>
      </svelte:fragment>
      <svelte:fragment slot="headline" />
    </AppBar>
  </svelte:fragment>
  <svelte:fragment slot="pageHeader">
    <Toaster richColors position="bottom-center" closeButton toastOptions={{ class: "text-xl" }} />
  </svelte:fragment>
  <svelte:fragment slot="sidebarLeft"><Navigation /></svelte:fragment>
  <div class="p-4">
    <slot />
  </div>
  <svelte:fragment slot="pageFooter"><Footer /></svelte:fragment>
</AppShell>
