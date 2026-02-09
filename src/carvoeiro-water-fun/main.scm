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

(define-module (carvoeiro-water-fun main)
  #:declarative? #t
  #:use-module (ice-9 getopt-long)
  #:use-module (carvoeiro-water-fun prelude)
  #:use-module (carvoeiro-water-fun renderer)
  #:use-module (kracht prelude)
  #:export (main))

(define* (main #:key (args (command-line)))
  (let* ((option-spec '((locale (single-char #\l)
                                (value #t))
                        (output-dir (single-char #\o)
                                    (value #t))
                        (resources-dir (single-char #\r)
                                       (value #t))))
         
         (options (getopt-long args option-spec))
         (output-dir (option-ref options
                                 'output-dir "./dist"))
         (resources-dir (option-ref options
                                    'resources-dir #f))
         (locale (string->symbol (option-ref options
                             'locale "en_US"))))
    (log-info "Carvoeiro Water Fun:")
    (render-page #:locale locale
                 #:output-dir output-dir
                 #:resources-dir resources-dir)))

