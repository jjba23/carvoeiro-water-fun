;;; Carvoeiro Water Fun
;;;
;;; SPDX-License-Identifier: MIT
;;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;;; Commentary:
;;;
;;; The program: read the options, render one page, and put the assets the page
;;; asks for beside it.
;;;
;;; `main' takes no positional arguments.  `maak build' calls it once per locale
;;; with the three settings a build decides -- the locale the page is written
;;; in, the directory the result goes to, and where the resources are read from
;;; -- and hands everything else to `(carvoeiro-water-fun renderer)'.
;;;
;;; ```mermaid
;;; flowchart LR
;;;   cli["maak build"] --> main["main<br/>--locale --output-dir --resources-dir"]
;;;   main --> render["render-page<br/>(carvoeiro-water-fun renderer)"]
;;;   render --> i18n["setup-i18n<br/>(carvoeiro-water-fun prelude)"]
;;;   render --> page["carvoeiro-water-fun<br/>(carvoeiro-water-fun html)"]
;;;   render --> assets["resources/css, js, fonts and img"]
;;;   page --> dist["output-dir/index.html"]
;;;   assets --> dist
;;; ```
;;;
;;; Code:

(define-module (carvoeiro-water-fun main)
  #:declarative? #t
  #:use-module (ice-9 getopt-long)
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
