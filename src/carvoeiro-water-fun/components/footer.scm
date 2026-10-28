;; Carvoeiro Water Fun
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (carvoeiro-water-fun components footer)
  #:declarative? #t
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (ice-9 regex)
  #:use-module (sxml ssax input-parse)
  #:use-module (sxml ssax)
  #:use-module (sxml transform)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 time)
  #:use-module (hygguile hygguile)
  #:use-module (kracht prelude)
  #:use-module (carvoeiro-water-fun prelude)
  #:use-module (carvoeiro-water-fun sxml)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 threads)
  #:export (footer-section))

(define* (copy-footer-section)
  `((div (@ (class ,(mk-class '(flex flex-col
                                     gap-3
                                     text-center
                                     align-center
                                     items-center
                                     px-4
                                     md:px-6
                                     lg:px-8))))
         (div (@ (class ,(mk-class '(max-w-128))))
              ,(p (G_ "Copyright © Carvoeiro Water Fun - All rights reserved")
                  #:family '(font-sans)
                  #:size '(text-md)
                  #:weight '(font-light)))
         (div (@ (class ,(mk-class '(max-w-96))))
              ,(p (G_
                   "this page's source code is licensed under the GNU Affero General Public License v3 or newer")
                  #:family '(font-sans)
                  #:size '(text-sm)
                  #:weight '(font-light)))
         (div (@ (class ,(mk-class '(my-3 flex
                                          flex-row
                                          flex-wrap
                                          gap-3
                                          justify-center
                                          items-center
                                          align-center))))
              ,(p (G_ "find here the:")
                  #:size '(text-sm)
                  #:weight '(font-light))
              ,(a "source code"
                  #:href "https://codeberg.org/jjba23/carvoeiro-water-fun"
                  #:size '(text-sm)
                  #:family '(font-sans)
                  #:weight '(font-light))))))

(define* (info-links-footer-section)
  `((div (@ (class ,(mk-class '(flex flex-col gap-3 md:gap-4))))
         (div (@ (class ,(mk-class '(flex flex-col
                                          sm:flex-row
                                          flex-wrap
                                          gap-1
                                          sm:gap-3
                                          items-center))))
              ,(icon #:type 'chat-circle-dots
                     #:icon-css '(text-md text-onyx-500))
              ,(p (G_ "WhatsApp:")
                  #:weight '(font-light)
                  #:size '(text-md))
              ,(a "wa.me/+351931933847"
                  #:href "https://wa.me/+351931933847"
                  #:size '(text-md)))
         (div (@ (class ,(mk-class '(flex flex-col
                                          sm:flex-row
                                          flex-wrap
                                          gap-1
                                          sm:gap-3
                                          items-center))))
              ,(icon #:type 'phone
                     #:icon-css '(text-md text-onyx-500))
              ,(p (G_ "Telephone:")
                  #:weight '(font-light)
                  #:size '(text-md))
              ,(a "+351 931 933 847"
                  #:href "tel:+351931933847"
                  #:size '(text-md)))
         (div (@ (class ,(mk-class '(flex flex-col
                                          sm:flex-row
                                          flex-wrap
                                          gap-1
                                          sm:gap-3
                                          items-center))))
              ,(icon #:type 'envelope
                     #:icon-css '(text-md text-onyx-500))
              ,(p (G_ "Email:")
                  #:weight '(font-light)
                  #:size '(text-md))
              ,(a "carvoeirowaterfun@gmail.com"
                  #:href "mailto:carvoeirowaterfun@gmail.com"
                  #:size '(text-md))))))

(define* (footer-section)
  `((div (@ (class ,(mk-class '(footer-glass pt-12 pb-12
                                            flex
                                            flex-row
                                            flex-wrap
                                            gap-12
                                            justify-center
                                            align-center
                                            items-center))))
         ,(copy-footer-section)
         ,(info-links-footer-section))))
