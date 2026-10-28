;; Carvoeiro Water Fun
;;
;; SPDX-LICENSE-IDENTIFIER: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

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
