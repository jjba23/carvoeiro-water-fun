;;; Carvoeiro Water Fun

;; Copyright © Josep Jesus Bigorra Algaba

;; carvoeiro-water-fun is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; carvoeiro-water-fun is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with carvoeiro-water-fun. If not, see <https://www.gnu.org/licenses/>.


(define-module (carvoeiro-water-fun renderer)
  #:declarative? #f
  #:use-module (carvoeiro-water-fun html)
  #:use-module (carvoeiro-water-fun prelude)
  #:export (render-page))

(define* (render-page #:key locale output-dir resources-dir)
  (setup-i18n locale)
  (log-info "Start rendering with settings:")
  (log-info "\tlocale: ~a" locale)
  (log-info "\tresources-dir: ~a" resources-dir)
  (log-info "\toutput-dir: ~a" output-dir)

  (let* ((clean-dist-cmd (format #f "rm -rfv ~a" output-dir ))
         (mkdir-dist-cmd (format #f "mkdir -p ~a/js" output-dir))
         (cp-to-dist-cmd (format #f
                          "cp -rfv ~a/js/tailwind.js ~a/js/tailwind.js"
                          resources-dir output-dir)))
    (log-info "executing: ~a" clean-dist-cmd)
    (syscall clean-dist-cmd)

    (log-info "executing: ~a" mkdir-dist-cmd)
    (syscall mkdir-dist-cmd)

    (log-info "executing: ~a" cp-to-dist-cmd)
    (syscall cp-to-dist-cmd)

    (with-output-to-file (format #f "~a/index.html" output-dir)
      (lambda ()
        (display (carvoeiro-water-fun))))
    (log-info "Completed rendering of page")))
