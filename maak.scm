;; Carvoeiro Water Fun
;;
;; SPDX-LICENSE-IDENTIFIER: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (maak)
  #:declarative? #t
  #:use-module (maak maak)
  #:use-module (ice-9 string-fun)
  #:use-module (srfi srfi-1))

;; ====== Maak constants ======

;; The path to the directory where the main project files will be deployed.
(define deploy-dir
  "/srv/http/carvoeirowaterfun.com")

(define project-name
  'carvoeiro-water-fun)

(define hot-reload-file-types
  '(scm mo))

;; The TCP port on which the development web server will listen.
(define http-port
  50065)

;; The path to the directory where the i18n resources are located.
(define i18n-dir
  "./resources/locale")

;; The text domain for the i18n translations.
(define i18n-textdomain
  "carvoeiro-water-fun")

(define i18n-locales
  '(en_US pt_PT))

(define default-locale
  'pt_PT)

;; The main copyright holders of the project.
(define copyright-holders
  '("Josep Bigorra"))

;; The veritas checkout the test suite runs against.  The framework is pre-1.0
;; and the checkout is newer than the packaged release, so its sources are
;; addressed directly; VERITAS_SRC moves it without editing this file.
(define veritas-src
  (or (getenv "VERITAS_SRC")
      (format #f "~a/Hacking/veritas/src" (getenv "HOME"))))

;; ====== Maak prelude ======

;; Specify the directory where the MO file is located
(bindtextdomain i18n-textdomain i18n-dir)
(bind-textdomain-codeset i18n-textdomain "UTF-8")
;; Specify the domain of the MO file
(textdomain i18n-textdomain)
(define G_
  gettext)

;; ====== Maak i18n abstractions ======

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

;; ====== Maak tasks ======

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

;; ====== Maak i18n tasks ======

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
  (let* ((destination-file (string-replace-substrings file
                                                      '((".png" . "")
                                                        (".jpg" . "")
                                                        (".jpeg" . "")))))
    (delete-file-recursively (~ "~a.avif" destination-file))
    (log-info "converting file: ~a -> ~a.avif\n" file destination-file)
    (run (list "magick" file "-quality" "40" "-define" "avif:speed=1"
               (~ "~a.avif" destination-file)))))

(define (avif-gen)
  "Generate AVIF images from others."
  (let* ((original-files
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
