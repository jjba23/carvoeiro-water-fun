;;; Carvoeiro Water Fun

;; Copyright © Josep Jesus Bigorra Algaba

;; carvoeiro-water-fun is free software: you can redistribute it and/or modify
;; it under the terms of the GNU Affero General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; carvoeiro-water-fun is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Affero General Public License for more details.

;; You should have received a copy of the GNU Affero General Public License
;; along with carvoeiro-water-fun. If not, see <https://www.gnu.org/licenses/>.

(define-module (maak)
  #:use-module (maak maak)
  #:declarative? #t)

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
  ($ (list (~ "msgfmt -v -o ~a/~a/LC_MESSAGES/~a.mo" i18n-dir lang
              i18n-textdomain)
           (~ "~a/~a/LC_MESSAGES/~a.po" i18n-dir lang i18n-textdomain))))

(define (i18n-init* lang)
  "Initialize a new translation file from a template (.pot) for a specific language.

Args: lang represents the language code (e.g., en_US, pt_PT, etc.)

Use msginit to generate a .po file from the .pot template for the specified language
The -l option sets the language, and --no-translator means no translator is pre-filled in the .po file
The generated .po file is placed in the LC_MESSAGES directory for the given language"
  (mkdir-p (~ "~a/~a/LC_MESSAGES" i18n-dir lang))
  ($ (list (~ "msginit -l ~a.UTF8 -o" lang)
           (~ "~a/~a/LC_MESSAGES/~a.po" i18n-dir lang i18n-textdomain)
           (~ "-i ~a/~a.pot --no-translator" i18n-dir i18n-textdomain))
     #:verbose? #t))

(define (i18n-merge* lang)
  "Merge translation updates from the template (.pot) into an existing .po file.

Args: lang represents the language code (e.g., en_US, pt_PT, etc.)

Use msgmerge to update the specified language's .po file with new translations from the template (.pot)
The -U flag updates the .po file in place
This ensures the .po file stays up-to-date with the latest changes in the template"
  ($ (list "msgmerge -U"
           (~ "~a/~a/LC_MESSAGES/~a.po" i18n-dir lang i18n-textdomain)
           (~ "~a/~a.pot" i18n-dir i18n-textdomain))))

(define* (i18n-extract* #:key (update? #t))
  "Extract translatable strings from Scheme source files using xgettext.
Args: update? represents whether we should update a template or create a new one."
  ($ (list (~ "xgettext --default-domain=~a" i18n-textdomain)
           (~ "--output=~a/~a.pot" i18n-dir i18n-textdomain)
           "--language=Scheme --keyword=G_"
           "--sort-by-file"
           (if update? "--join-existing" "")
           (~ "--copyright-holder=\"~a\""
              (string-join copyright-holders ","))
           (~ "--package-name=~a" i18n-textdomain)
           "src/carvoeiro-water-fun/*.scm"
           "--from-code UTF-8")
     #:verbose? #t))

;; ====== Maak tasks ======

(define (kill-server)
  "Kill any running HTTP server in the same port."
  ($ (list (~ "fuser -k ~a/tcp || true" http-port))))

(define (serve)
  "Run HTTP server serving the rendered production result of running."
  (kill-server)
  ($ (list (~ "darkhttpd ./dist --port ~a" http-port))))

(define (default)
  "Default task to run, call program's help."
  (list-tasks))

(define (fmt)
  "Format Scheme source code files according to the Guix style guide."
  ($ '("find . -maxdepth 8 -name '*.scm'" "-type f -exec guix style -f {} \\;")
     #:verbose? #t))

(define (repl)
  "Development REPL."
  (manifest-shell '("guile -L ./src"
                    "-c '((@ (ares server) run-nrepl-server))'")))

(define (build* locale output-dir)
  (mkdir-p output-dir)
  (time-machine-manifest-shell (list "guile -L"
                                "./src"
                                "-c '((@(carvoeiro-water-fun main) main))'"
                                (~ "--locale ~a" locale)
                                (~ "--output-dir ~a" output-dir)
                                "--resources-dir ./resources")))

(define (build)
  "Build."
  (remkdir-p "./dist")
  (build* 'en_US "./dist/en")
  (build* 'pt_PT "./dist/pt")
  (mv "dist/en/*" "dist/"))

(define (build-and-serve)
  "Build and serve."
  (build)
  (serve))

(define (deploy)
  (delete-file-recursively deploy-dir)
  (build-en)
  (mv "dist" deploy-dir)
  (build-pt)
  (mv "dist"
      (~ "~a/pt" deploy-dir)))

(define (hot-reload)
  "Hot-reloading developer's setup."
  (time-machine-manifest-shell (list "watchexec"
                                     "--clear"
                                     (~ "--exts ~a"
                                        (string-join (map symbol->string
                                                      hot-reload-file-types)
                                                     ","))
                                     "--on-busy-update=restart"
                                     "--shell bash"
                                     "--watch . --"
                                     "maak build-and-serve")))

(define (hr)
  "Alias to hot-reloading."
  (hot-reload))

(define (dev)
  "Developer's setup."
  (hot-reload))

(define (olive-css)
  ($ '("curl --verbose --output \"./resources/css/carvoeiro-water-fun.olive.min.css\""
       "\"https://codeberg.org/jjba23/olive-css/raw/branch/trunk/resources/css/carvoeiro-water-fun.olive.min.css\"")))

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
