;;; Carvoeiro Water Fun
;;;
;;; SPDX-License-Identifier: MIT
;;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (maak)
  #:declarative? #t
  #:use-module (maak maak)
  #:use-module ((ice-9 rdelim) #:select (read-line))
  #:use-module (ice-9 string-fun)
  #:use-module (srfi srfi-1))

;;; ====== Maak constants ======

;;; The path to the directory where the main project files will be deployed.
(define deploy-dir
  "/srv/http/carvoeirowaterfun.com")

(define project-name
  'carvoeiro-water-fun)

(define hot-reload-file-types
  '(scm mo))

;;; The TCP port on which the development web server will listen.
(define http-port
  50065)

;;; The path to the directory where the i18n resources are located.
(define i18n-dir
  "./resources/locale")

;;; The text domain for the i18n translations.
(define i18n-textdomain
  "carvoeiro-water-fun")

(define i18n-locales
  '(en_US pt_PT))

(define default-locale
  'pt_PT)

;;; The main copyright holders of the project.
(define copyright-holders
  '("Josep Bigorra"))

;;; The veritas checkout the test suite runs against.  The framework is pre-1.0
;;; and the checkout is newer than the packaged release, so its sources are
;;; addressed directly; VERITAS_SRC moves it without editing this file.
(define veritas-src
  (or (getenv "VERITAS_SRC")
    (format #f "~a/Hacking/veritas/src" (getenv "HOME"))))

;;; ====== Maak prelude ======

;;; Specify the directory where the MO file is located
(bindtextdomain i18n-textdomain i18n-dir)
(bind-textdomain-codeset i18n-textdomain "UTF-8")
;;; Specify the domain of the MO file
(textdomain i18n-textdomain)
(define G_
  gettext)

;;; ====== Maak i18n abstractions ======

(define (i18n-compile* lang)
  "Compile the translation file (.po) into a machine-readable (.mo) format

Args: lang represents the language code (e.g., en_US, pt_PT, etc.)

Use msgfmt to compile the .po file into a .mo file for the specified language
The output .mo file will be placed in the LC_MESSAGES directory under the language's folder."
  (run (list "msgfmt" "-v" "-o"
             (~ "~a/~a/LC_MESSAGES/~a.mo" i18n-dir lang i18n-textdomain)
             (~ "~a/~a/LC_MESSAGES/~a.po" i18n-dir lang i18n-textdomain))))

(define (i18n-init* lang)
  "Initialize a new translation file from a template (.pot) for a specific language.

Args: lang represents the language code (e.g., en_US, pt_PT, etc.)

Use msginit to generate a .po file from the .pot template for the specified language
The -l option sets the language, and --no-translator means no translator is pre-filled in the .po file
The generated .po file is placed in the LC_MESSAGES directory for the given language"
  (mkdir-p (~ "~a/~a/LC_MESSAGES" i18n-dir lang))
  (run (list "msginit" "-l" (~ "~a.UTF8" lang)
             "-o" (~ "~a/~a/LC_MESSAGES/~a.po" i18n-dir lang i18n-textdomain)
             "-i" (~ "~a/~a.pot" i18n-dir i18n-textdomain)
             "--no-translator")
       #:verbose? #t))

(define (i18n-merge* lang)
  "Merge translation updates from the template (.pot) into an existing .po file.

Args: lang represents the language code (e.g., en_US, pt_PT, etc.)

Use msgmerge to update the specified language's .po file with new translations from the template (.pot)
The -U flag updates the .po file in place
This ensures the .po file stays up-to-date with the latest changes in the template"
  (run (list "msgmerge" "-U"
             (~ "~a/~a/LC_MESSAGES/~a.po" i18n-dir lang i18n-textdomain)
             (~ "~a/~a.pot" i18n-dir i18n-textdomain))))

(define* (i18n-extract* #:key (update? #t))
  "Extract translatable strings from Scheme source files using xgettext.
Args: update? represents whether we should update a template or create a new one."
  ;; The source files are globs, and xgettext expands no globs itself, so the
  ;; line is handed to the shell to name them.
  (run (append (list "xgettext"
                     (~ "--default-domain=~a" i18n-textdomain)
                     (~ "--output=~a/~a.pot" i18n-dir i18n-textdomain)
                     "--language=Scheme"
                     "--keyword=G_"
                     "--sort-by-file")
               (if update? (list "--join-existing") '())
               (list (~ "--copyright-holder=\"~a\""
                        (string-join copyright-holders ","))
                     (~ "--package-name=~a" i18n-textdomain)
                     "src/carvoeiro-water-fun/*.scm"
                     "src/carvoeiro-water-fun/components/*.scm"
                     "--from-code" "UTF-8"))
       #:expand? #t
       #:verbose? #t))

;;; ====== Maak tasks ======

(define (kill-server)
  "Kill any running HTTP server in the same port."
  ;; `fuser' exits non-zero when nothing holds the port, which is the answer
  ;; this task wants rather than a failure.
  (run (list "fuser" "-k" (~ "~a/tcp" http-port))
       #:allow-failure? #t))

(define (serve)
  "Run HTTP server serving the rendered production result of running."
  (kill-server)
  (run (list "darkhttpd" "./dist" "--port" (~ "~a" http-port))))

(define (default)
  "Default task to run, call program's help."
  (list-tasks))

(define (fmt)
  "Format Scheme source code files according to the Guix style guide."
  (run (list "find" "." "-maxdepth" "8" "-name" "*.scm" "-type" "f"
             "-exec" "guix" "style" "-f" "{}" ";")
       #:verbose? #t))

(define (repl)
  "Development REPL."
  (manifest-shell (list "guile" "-L" "./src"
                        "-c" "'((@ (ares server) run-nrepl-server))'")))

(define (build* locale output-dir)
  (mkdir-p output-dir)
  (time-machine-manifest-shell (list "guile" "-L" "./src"
                                     "-c" "'((@(carvoeiro-water-fun main) main))'"
                                     (~ "--locale ~a" locale)
                                     (~ "--output-dir ~a" output-dir)
                                     "--resources-dir" "./resources")))

(define (build)
  "Build."
  (remkdir-p "./dist")
  (build* 'en_US "./dist/en")
  (build* 'pt_PT "./dist/pt")
  (mv "dist/en/*" "dist/" #:expand? #t))

(define (test)
  "Run the test suite with veritas."
  (manifest-shell (list "guile" "-L" "./src"
                        "-L" veritas-src
                        "-L" "./test"
                        "test/run.scm")
                  #:verbose? #t))

(define (build-and-serve)
  "Build and serve."
  (build)
  (serve))

(define (deploy)
  (delete-file-recursively deploy-dir)
  (build)
  (mv "dist" deploy-dir))

(define (hot-reload)
  "Hot-reloading developer's setup."
  (time-machine-manifest-shell (list "watchexec"
                                     "--clear"
                                     "--exts"
                                     (string-join (map symbol->string
                                                       hot-reload-file-types)
                                                  ",")
                                     "--on-busy-update=restart"
                                     "--shell" "bash"
                                     "--watch" "."
                                     "--" "maak" "build-and-serve")))

(define (hr)
  "Alias to hot-reloading."
  (hot-reload))

(define (dev)
  "Developer's setup."
  (hot-reload))

(define (olive-css)
  (curl-download
   "https://codeberg.org/jjba23/olive-css/raw/branch/trunk/resources/css/carvoeiro-water-fun.olive.min.css"
   #:output "./resources/css/carvoeiro-water-fun.olive.min.css"
   #:verbose? #t))

;;; ====== Maak i18n tasks ======

(define (i18n-compile)
  "Compile the translation files for all locales."
  (for-each i18n-compile* i18n-locales))

(define (i18n-init-en)
  "Initialize a new translation file for en_US."
  (i18n-init* 'en_US))

(define (i18n-init-pt)
  "Initialize a new translation file for pt_PT."
  (i18n-init* 'pt_PT))

(define (i18n-merge)
  "Merge translation updates for all locales."
  (for-each i18n-merge* i18n-locales))

(define (i18n-new-template)
  "Create a new i18n template based on strings extracted from source code."
  (i18n-extract* #:update? #f))

(define (i18n-update-template)
  "Update the i18n template based on strings extracted from source code."
  (i18n-extract* #:update? #t))

(define (string-replace-substrings str pairs)
  (fold (lambda (s rem)
          (string-replace-substring rem
                                    (car s)
                                    (cdr s))) str pairs))

(define* (convert-to-avif file)
  (let ((destination-file (string-replace-substrings file
                                                     '((".png" . "")
                                                       (".jpg" . "")
                                                       (".jpeg" . "")))))
    (delete-file-recursively (~ "~a.avif" destination-file))
    (log-info "converting file: ~a -> ~a.avif\n" file destination-file)
    (run (list "magick" file "-quality" "40" "-define" "avif:speed=1"
               (~ "~a.avif" destination-file)))))

(define (avif-gen)
  "Generate AVIF images from others."
  (let ((original-files
         (filter (lambda (file) (not (string=? file "")))
                 (string-split
                  (string-trim-both
                   (capture (unwords (list "find" "./resources/img"
                                           "-maxdepth" "8"
                                           "-name" "'*.jpg'"
                                           "-o" "-name" "'*.jpeg'"
                                           "-o" "-name" "'*.png'"))))
                  #\newline))))
    (for-each convert-to-avif original-files)))

;; ====== Agent skills ======

;; AGENTS.md is generated, never edited by hand.  The section has two halves:
;; the data below, which is this project's, and the task itself, which is not.
;; Another repository copies the whole section and replaces the data - the
;; header, the pinned skills (repository, commit, path, licence) and the
;; practices - and `maak agents' writes its own AGENTS.md.  Regeneration is
;; deterministic: the same pins and the same text produce the same file, byte
;; for byte, and it needs nothing but curl.  The skill URLs assume GitHub, so a
;; skill hosted elsewhere needs a URL of its own.

(define ponytail-commit
  "96608e078b2d5ea607c5c3b8b5a54d1c1fba6846")

(define tdd-commit
  "22f0b463e7a5e579904dd6211a520321035526f7")

;; Name, repository, commit, the path the repository keeps the skill at and the
;; licence.  A skill arrives whole: trimming it means scanning for headings, and
;; such a scan cannot tell a heading from a `##' line inside a code fence.
(define agent-skills
  (list (list "ponytail"
              "DietrichGebert/ponytail"
              ponytail-commit
              "skills/ponytail/SKILL.md"
              "MIT")
        (list "test-driven-development"
              "obra/superpowers"
              tdd-commit
              "skills/test-driven-development/SKILL.md"
              "MIT")))

(define agent-skills-dir
  "reports/agent-skills")

(define agents-header
  "# AGENTS.md

Generated by `maak agents` from the pinned skills and the practices in
`maak.scm`; edit that task, never this file.  The pins and the text are the whole
input, so regenerating gives the same document.  The repository's own rules win
over general advice, and the narrowest rule here wins over the broadest.
")

;; Practices this project keeps.  They are short on purpose: a rule a reader
;; checks in a second is a rule that gets followed.  The pinned skills are the
;; long form of the same habits.
(define agent-practices
  (list
   "## Documentation

- Every user-visible change reaches the documentation: the page that owns the
  feature, the manual page for a flag or an environment variable, and the
  release notes under the unreleased heading.
- Keep the table of contents in step with the headings.  A section with no entry
  is a section nobody finds.
- The guide is Org: one `*` heading per page, `**` for sections, `#+TITLE` and
  `#+EMAIL` at the top, a `CUSTOM_ID` on anything linked from elsewhere, and
  `file:` links between pages.
- Explain why and when, never what: the code already says what.  A docstring's
  first line works as a summary on its own.
- Spell an identifier the way the code spells it - the exact name, not a
  description of it.
- An example must run as written, copied from a real invocation.
- No promises about the future and no changelog in the guide; history lives in
  the release notes.
"
   "## Security

- No secrets in the tree.  Tokens, keys and passwords arrive through the
  environment, and no recipe, workflow or example embeds one.
- Validate at the edge: anything from a file, a report, a path or a subprocess
  is untrusted until it has been checked.
- Never build a shell string out of data.  Tasks pass argument lists, and Guile
  calls `(system \"program\" \"arg\")` or `open-pipe*`, never a command
  assembled with `string-append`.
- Do not `eval` or `read` input you did not write; parse with `(json)` or a
  reader built for the format.
- Escape what leaves the process: a name that came from input is escaped when
  it is written to XML, HTML or a data file.
- Fail closed.  A file that cannot be read is an error, not an empty result.
- Input never chooses the path of a written file; writes stay inside the
  directory reserved for them.
- A dependency is a security decision: it must be needed, MIT compatible and
  pinned.
- Report a vulnerability privately, not in a public issue.
"
   "## Performance

- Measure first.  A before and after belongs in the benchmark, and a speedup
  claimed without a number is not a speedup.
- Prefer not doing the work: cache it, skip it, batch it, or delete the call,
  before making the call faster.
- Then the algorithm, then the data structure (hash table, vector), then the
  micro-optimisation.  In that order, for that reason.
- Guile specifics: keep module resolution and long `assoc` chains out of loops,
  use `#:declarative?` modules and compiled `.go` files at startup, and reach
  for `statprof` instead of guessing where the time goes.
- A shortcut that buys speed costs clarity; it gets a measurement and a
  `shortcut:` comment saying what it costs and when to revisit it.
- Coverage instrumentation is slow by design: iterate without it, and measure
  before finishing.
"
   "## Architecture decisions

- A decision that is expensive to reverse gets a short record: the context, the
  decision, the consequences, and the alternatives that lost.  A small decision
  belongs in the commit body instead.
- Two paragraphs beat a design document; record the choice while it is still a
  choice, not after it has become a fact.
- An accepted record is not rewritten.  Supersede it with a new one and link the
  two directions.
- The record lives next to its subject: the documentation for anything a user
  would notice, the release notes for the release-level result.
- Changes to the public API, a file format, the pipeline or the licence get this
  treatment at a minimum in the commit body.
"
   "## Semantic versioning

- The project follows SemVer 2.0.0 for its public API: the exported functions,
  the CLI flags and environment variables, and the shape of its file formats.
- A breaking change bumps MAJOR, a new feature MINOR, a fix PATCH.  A new export
  is MINOR; removing or changing one is MAJOR.
- One version string, named everywhere it appears: the source, the build
  recipes, the manual page and the packaging.
- A release is a dated release-notes section, an annotated `vX.Y.Z` tag on the
  release commit, and a packaging checksum updated afterwards from the published
  archive.
"
   "## Conventional commits

- `type(scope): summary`, imperative, lower case, no full stop, about seventy
  characters.
- Types in use: `feat`, `fix`, `perf`, `refactor`, `test`, `docs`, `build`, `ci`,
  `chore`.  A `!` after the type or a `BREAKING CHANGE:` footer marks a MAJOR
  change, and says what breaks.
- The subject says what changed.  The body says why, and what was rejected.
- One logical change per commit: a refactor and a fix travel apart, so either
  can be reverted alone.
- Run the full validation task before committing, and never commit a red suite
  without saying so in the message.
- Reference the issue in the footer - `Closes #12` - not in the subject.
"
   "## Functional programming and immutability

- Pure functions in the core, effects at the edges.  Whatever touches the file
  system or the clock sits at the edge; the core does not.
- Prefer `let` and new values to `set!`.  Build results with `map`, `filter`,
  `fold` and named `let`, not with index loops that push into a list.
- A record is a value: construct a new one instead of mutating a shared one, and
  pass configuration as arguments or parameters rather than as globals.
- Handle an exception at the boundary: catch it there, turn it into a result
  record, and let the caller decide what it means.
- A function that both computes and prints is two functions.
- Temporary effects - a changed directory, a bound environment variable - go
  through `dynamic-wind`.
- Prefer the expression style: `if` and `cond` that return a value, not a branch
  that assigns one.
"
   "## Do not reinvent the wheel

- Guile's standard library first: `(ice-9 ...)` for the runtime, `(srfi srfi-1)`
  for lists, `(srfi srfi-9)` for records, `(srfi srfi-13)` for strings, `(json)`
  for JSON.  The project already depends on all of them.
- Then this codebase: read the existing modules before writing a helper, and use
  the one that is nearly right instead of adding a second one.
- A new dependency needs a reason the standard library cannot meet, a licence
  the project can carry, and a paragraph in the commit body.
- Prefer deleting a special case to writing code that handles it.
- The best diff removes lines and keeps the behaviour; the second best is a
  small diff that is obvious a year later.
"))

(define (slurp path)
  "Return the whole of @var{path} as a string."
  (call-with-input-file path
    (lambda (port)
      (let loop ((lines '())
                 (line (read-line port)))
        (if (eof-object? line)
            (string-concatenate-reverse lines)
            (loop (cons (string-append line "\n") lines)
                  (read-line port)))))))

(define (fetch-skill name repository commit path)
  "Download one skill pinned at @var{commit}, into the reports tree.

  Returns the skill's text."
  (let ((target (~ "~a/~a.md" agent-skills-dir name))
        (url (~ "https://raw.githubusercontent.com/~a/~a/~a"
                repository commit path)))
    (run (list "curl" "--fail" "--silent" "--show-error" "--location"
               "--output" target url)
         #:verbose? #t)
    (slurp target)))

(define (agents)
  "Regenerate AGENTS.md from the pinned skills and the practices."
  (run (list "mkdir" "-p" agent-skills-dir))
  ;; Every download happens before the file is opened, so a fetch that fails
  ;; leaves the previous AGENTS.md in place rather than a half-written one.
  (let ((skills (map (lambda (skill)
                       (append skill
                               (list (fetch-skill (list-ref skill 0)
                                                  (list-ref skill 1)
                                                  (list-ref skill 2)
                                                  (list-ref skill 3)))))
                     agent-skills)))
    (call-with-output-file "AGENTS.md"
      (lambda (port)
        (display agents-header port)
        (for-each (lambda (skill)
                    (format port
                            "~%## ~a~%~%`~a` at `~a`, `~a`, ~a licensed.~%~%"
                            (list-ref skill 0)
                            (list-ref skill 1)
                            (list-ref skill 2)
                            (list-ref skill 3)
                            (list-ref skill 4))
                    (display (list-ref skill 5) port))
                  skills)
        (for-each (lambda (practice)
                    (newline port)
                    (display practice port))
                  agent-practices)))))
