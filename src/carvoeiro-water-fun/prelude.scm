;; Carvoeiro Water Fun
;;
;; SPDX-LICENSE-IDENTIFIER: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (carvoeiro-water-fun prelude)
  #:declarative? #t
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 regex)
  #:export (setup-i18n G_))

(define (G_ msg)
  (gettext msg))

(define (setup-i18n locale)
  (catch #t
         (lambda ()
           (setlocale LC_MESSAGES
                      (format #f "~a.UTF-8" locale))
           (bindtextdomain "carvoeiro-water-fun" "./resources/locale")
           (textdomain "carvoeiro-water-fun"))
         (lambda (key . args)
           (display (format #f "error setting i18n up: ~a: ~a" key args)))))
