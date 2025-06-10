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
  (log-info "Start rendering with settings:")
  (log-info "\tlocale: ~a" locale)
  (log-info "\tresources-dir: ~a" resources-dir)
  (log-info "\toutput-dir: ~a" output-dir)

  ;; choose person to generate curriculum vitae for
  (load persona-file)

  (let* ((clean-dist-cmd (format #f "rm -rfv ~a" output-dir ))
         (mkdir-dist-cmd (format #f "mkdir -p ~a/js" output-dir))
         (cp-to-dist-cmd (format #f
                          "cp -rfv ~a/js/tailwind.js ~a/js/tailwind.js"
                          resources-dir output-dir))
         ;; build a persona by blending defaults and user settings
         (persona `((display-name unquote
                                  (get-setting 'display-name))
                    (job-title unquote
                               (get-setting 'job-title))
                    (personal-contact unquote
                                      (get-setting 'personal-contact))
                    (personal-links unquote
                                    (get-setting 'personal-links))
                    (address-lines unquote
                                   (get-setting 'address-lines))
                    (driver-licenses unquote
                                     (get-setting 'driver-licenses))
                    (interests-hobbies unquote
                                       (get-setting 'interests-hobbies))
                    (languages unquote
                               (get-setting 'languages))
                    (education unquote
                               (get-setting 'education))
                    (titles unquote
                            (get-setting 'titles))
                    (short-intro unquote
                                 (get-setting 'short-intro))
                    (jobs unquote
                          (get-setting 'jobs))
                    (font unquote
                          (get-setting 'font))
                    (palette unquote
                             (get-setting 'palette)))))
    (log-info "executing: ~a" clean-dist-cmd)
    (syscall clean-dist-cmd)

    (log-info "executing: ~a" mkdir-dist-cmd)
    (syscall mkdir-dist-cmd)

    (log-info "executing: ~a" cp-to-dist-cmd)
    (syscall cp-to-dist-cmd)

    (with-output-to-file (format #f "~a/index.html" output-dir)
      (lambda ()
        (display (carvoeiro-water-fun #:locale locale))))
    (log-info "Completed rendering of page")))
