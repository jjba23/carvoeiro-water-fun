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
  '(scm))

;; The TCP port on which the development web server will listen.
(define http-port
  50065)

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

(define (build locale)
  (time-machine-manifest-shell (list "guile -L"
                                "./src"
                                "-c '((@(carvoeiro-water-fun main) main))'"
                                (~ "--locale ~a" locale)
                                "--output-dir ./dist"
                                "--resources-dir ./resources")))

(define (build-en)
  "Build English version of the project."
  (build "en_US"))

(define (build-pt)
  "Build Portuguese version of the project."
  (build "pt_PT"))

(define (deploy)
  (build-pt)
  ;; Deploy
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
                                     "maak build-en && maak serve")))

(define (hr)
  "Alias to hot-reloading."
  (hot-reload))

(define (dev)
  "Developer's setup."
  (hot-reload))

(define (olive-css)
  ($ '("curl --verbose --output \"./resources/css/carvoeiro-water-fun.olive.min.css\""
       "\"https://codeberg.org/jjba23/olive-css/raw/branch/trunk/resources/css/carvoeiro-water-fun.olive.min.css\"")))
