# Vision

Carvoeiro Water Fun is a real boat-tour business in the Algarve, and this repository
is its website: one page, written as SXML in Guile, rendered into English at the root
and Portuguese under `/pt`, with self-hosted fonts, AVIF photographs and no JavaScript
framework. It is a static site with a small program behind it, and the interesting
question is not how the page is built but what a page has to do for a business that
sells two-hour trips to a cave.

## Where carvoeiro-water-fun is today

The program is about 1,280 lines of Guile: `html.scm` (750, which is the page), `sxml.scm`
(240, the tag helpers), `components/footer.scm` (163), `renderer.scm`, `main.scm` and a
prelude that re-exports what the page uses from hygguile and the kracht prelude. The build
is a handful of `maak` tasks, the tests are veritas suites under
`test/carvoeiro-water-fun/unit/`, and the site is deployed by a `maak-deploy` job that the
GitHub workflow hands to Byggsteg.

What exists, concretely:

- **Two locales, one page.** `maak build` renders `en_US` into `./dist/en` and `pt_PT` into
  `./dist/pt`, then moves the English tree into the root of `dist/` — so English is at `/`
  and Portuguese at `/pt`, which is exactly what the language switcher links to. The
  catalogs are ordinary gettext: a `carvoeiro-water-fun.pot` extracted by `xgettext
  --language=Scheme --keyword=G_`, one `.po` per locale, compiled with `msgfmt`.
- **A page that is a Scheme program.** The hero, a carousel, a drag-to-scrub panorama with
  one tab per view, a native `<dialog>` lightbox, and sections for the tour, insurance, the
  review, where to find us, the map, the contact details and the footer — each a function
  returning SXML, composed into one document. A layout change is a refactor of a list,
  not an edit to a template language.
- **Self-hosted everything.** Work Sans, Source Serif 4 and JuliaMono are declared in an
  inlined `@font-face` block and copied into each built site, so the page asks no font
  service for its type; photographs ship as AVIF with a JPEG fallback; the map is the only
  third-party request on the page, and it is a `loading="lazy"` iframe.
- **Motion that degrades.** `data-reveal`, `data-carousel`, `data-tilt` and the panorama
  are progressive: the markup is complete in the first response, and 810 lines of vanilla
  JavaScript in `resources/js/maritime.js` add the behaviour. A `speculationrules` block
  asks the browser to prerender what a visitor is likely to click.
- **Tests over the markup.** Seven veritas suites — document, asset, motion, theme,
  stylesheet, script and serializer — assert the shape of the page, the presence of the
  assets, and the invariants the stylesheet and the script depend on, so a section that
  loses its heading or an image that loses its height fails a test.
- **A defensible delivery.** Deployment is `rsync`-less and static: the build is copied to
  `/srv/http/carvoeirowaterfun.com` and served by `darkhttpd`; the toolchain is pinned in a
  Guix manifest and the build runs through `guix time-machine`.

Two decisions constrain what comes next. The first is that **the renderer knows nothing
about the web**: it writes one `index.html` per locale into a directory and copies four
asset directories beside it, and the mapping from locale to public path lives in `maak`
as a `mv`. The second is that **the content is code**: prices, times and sentences are
prose inside `html.scm`, translated through gettext but not modelled anywhere a machine
can read.

Three things a site like this one normally has are absent, and their absence is the
substance of this document: a sitemap, structured data, and any way to book.

## The vision

1. **The business is described once, and the page reads the description.** Opening hours,
   the two-hour duration, the departure point, the languages spoken and the price live in
   one datum; the visible sections, the metadata and the machine-readable markup are all
   rendered from it, so they cannot come to disagree.

2. **The site is findable by somebody planning a holiday.** A sitemap with both locales,
   `hreflang` alternates between `/` and `/pt`, canonical URLs, and JSON-LD describing the
   tour as a `Product` with an `Offer` and the place as a `TouristAttraction` — all
   generated, none of it typed twice.

3. **A booking is one tap, and truthful.** A visitor on a phone on the beach can send a
   request that reaches the operator's phone, and the page never claims an availability it
   has not been told.

4. **The page is fast on the phone it will actually be read on.** A weight budget per
   locale, asserted by the test suite, with the panorama and the carousel lazy beyond the
   fold — because a guest is standing in the sun on hotel wifi.

5. **The operator can change the words and the photographs without a Guile developer.**
   The catalogs already exist; what is missing is a workflow — and a rule about what is
   content and what is layout — that makes editing the site a task for the person who runs
   the boat.

## Features that are in scope and not built yet

- **`sitemap.xml` and `robots.txt`.** Nothing in the build writes either, and a static site
  is precisely where they are free. The hard part is that the renderer has no idea what
  the public origin is: `--output-dir` is a filesystem path, so the origin has to become
  configuration before a URL can be absolute.
- **`hreflang` and canonical links.** Both locales exist and the switcher already points at
  `/` and `/pt`, but the mapping from a locale to a public path happens in `maak build` as
  a `mv` of the English tree into the root. The hard part is moving that knowledge into the
  renderer, or the alternates will describe a directory layout rather than the site.
- **JSON-LD structured data.** A page about a named tour with a fixed duration, a
  departure beach and a price is the clearest possible candidate for `Product` and `Offer`
  markup. The hard part is truthfulness: departure times and prices today live as prose,
  and markup generated from prose will eventually lie to a search engine.
- **A departure and price datum.** The vision's first statement needs a shape — a
  `(define boat-tours ...)` the page and the markup both fold over. The hard part is not
  the data, it is deciding what is stable enough to promise: a price that changes in July
  must not require a code review.
- **Per-locale social metadata.** `og:image` and `og:title` exist and are shared; a
  Portuguese visitor sharing the page should share a Portuguese card. The hard part is that
  the images are photographs with text baked in, so this is an asset question before it is
  a markup question.
- **A booking request that survives a static host.** The page offers WhatsApp, a telephone
  number and an email address. A form needs somewhere to post to, and the hard part is
  that the honest options are a third-party endpoint, a mailto fallback, or a tiny service
  of the operator's own — three different privacy answers.
- **A weight budget.** The asset suite asserts that the assets are there; it does not
  measure what a page costs to load. The hard part is stable measurement: transfer size,
  compressed and per locale, with the photographs counted honestly.

## New features that would be worth having

- **A sea-state note.** The trip is weather-dependent and the page says nothing about it.
  A short line — "today's sea is calm", "we are not sailing this afternoon" — maintained by
  the operator through the same data the tour is described in, is the most useful thing a
  boat-tour site can say and the hardest to keep current.
- **Reviews that refresh themselves.** The page asks a departing guest to leave a Google
  review and links to the listing. Pulling the rating and three recent reviews at build time
  would need an API key and a policy about caching somebody else's words — worth it for a
  business whose reputation is its whole funnel.
- **A responsive `srcset` per photograph.** AVIF and JPEG already ship side by side; the
  widths do not, and generating three of them at build time is mechanical.
- **Locale coverage for the map.** The Google Maps embed URL carries `nl` where a locale
  appears, so the map labels the coast in Dutch on both pages. One parameter, once the embed
  is generated rather than pasted.
- **A printed page.** A one-page PDF of the tour, the meeting point and the contact details
  would be what the guest shows the taxi driver; a print stylesheet is the cheap half.
- **An offline-first shell** (speculative): a service worker would let a page that has been
  opened once be reopened on a boat with no signal. Speculative because it is a second
  caching policy to reason about, for a page that is already static.

## Contributions that would move the needle

1. **`sitemap.xml`, `robots.txt` and canonical links from one origin setting.** The
   smallest change that makes the site discoverable as two locales rather than one, and it
   forces the origin into configuration, which everything else here wants anyway.
2. **JSON-LD for the tour.** A `Product` with an `Offer`, a `TouristAttraction` for the
   cave, and the address and hours that are already written on the page. It is the single
   highest-leverage markup for a small operator.
3. **The tour datum.** One alist — duration, departure point, price, languages — read by
   the visible page, the metadata and the markup. It is the difference between a page that
   is maintained and one that drifts.
4. **A weight budget in the asset suite.** The suites already exist and already fail a
   build; measuring the page is a few more assertions and a policy that survives releases.
5. **The locale-to-path mapping in the renderer.** It removes the `mv` in `maak build`,
   makes the two locales symmetrical, and is a prerequisite for `hreflang` being true.
6. **Localising the map embed**, which is a parameter and a test.
7. **Documenting the editing workflow** for the operator: which `.po` file, which
   photographs, which sections — and what a change costs in a rebuild.

## Compared to related projects

| Project | What it is | Where carvoeiro-water-fun differs |
| --- | --- | --- |
| Haunt | A static site generator written in Guile Scheme, with posts, templates and an SXML DSL | This is not a generator: it is one site's source. There is no content model, no file-based posts and no theme — the page is a function, and the "templates" are Scheme you can refactor |
| Hugo | A Go site generator with a content tree, taxonomies, themes and a sitemap out of the box | Hugo would need a theme and a content directory for one page; it also ships the sitemap, robots and structured data that this project still has to write |
| Eleventy / Astro | JavaScript generators with template languages and islands of interactivity | No Node toolchain at all; the interactivity here is 810 lines of vanilla JavaScript, and the build is a Guile program pinned in a manifest |
| Zola | A Rust generator with its own template language and built-in taxonomies | The same trade in reverse: a template language against SXML, and a built-in sitemap against one that has to be written — but far less to learn for a non-Lisp contributor |
| WordPress with a booking plugin | A CMS, a database, a PHP runtime and an extension ecosystem | A directory of files served by `darkhttpd`, with no runtime, no database and no update treadmill — and no admin interface for the operator |
| FareHarbor, Bokun, Rezdy | Hosted booking engines embedded in an operator's site | They own availability, payment and the customer record. This site deliberately routes a booking through a phone and a WhatsApp link, which is cheaper and more human, and cannot take a deposit |

What the others do that this project could still add is on two axes. The generators —
Hugo, Zola, Eleventy — ship a sitemap, robots, canonical links and often structured data
without being asked, which is the clearest argument for contributions one and two. The
booking platforms own the one thing this site cannot do at all, and the honest position is
that a hosted engine is an integration to consider rather than a feature to build. WordPress
has the thing the operator would actually miss: a form to edit the words.

Where this project is ahead and should stay ahead: no runtime, no database and no update
treadmill; not one third-party script; fonts served from its own host; AVIF photographs
with real dimensions; a page that renders completely before any JavaScript runs; two
languages through ordinary gettext catalogs; and a test suite that fails when the markup
loses a heading. Almost none of the alternatives can say all of that about a page this
small, and none of them can say it about a page that a Scheme programmer can refactor.

## In the long run

The first bet is that **the page stays a program and the content leaves it**. Layout as
SXML is why the site can be changed cheaply; prices and times as prose is why it cannot yet
be trusted by a search engine. Moving the second without losing the first is the whole
trick, and the tour datum is how it starts.

The second is **discoverability as the growth engine**. A tour business on the Algarve
coast is found by people searching for a cave, a beach and a boat — which is structured
data, a sitemap and honest photographs, not a redesign.

The third is that **the human booking is a feature, not a gap**. Two-hour trips sold over
WhatsApp are how this business actually works; an integration should make that faster, not
replace it with a checkout.

## What would make this document wrong

If the operator's business grows past what a phone can book, the booking item moves from
"consider an integration" to "the site's main job", and the static-only bet is worth
re-examining. If a hosted platform ever offers this page's weight and speed with an editor
the operator likes, the argument for a Guile program weakens — though the tests, the two
locales and the manifest would still be the reason to keep it.

*A vision describes intent, not commitments: nothing here is promised for a release.*
