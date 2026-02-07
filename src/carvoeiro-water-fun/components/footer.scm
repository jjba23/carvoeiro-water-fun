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
                  #:family '(font-serif)
                  #:size '(text-md)
                  #:weight '(font-light)))
         (div (@ (class ,(mk-class '(max-w-96))))
              ,(p (G_
                   "this page's source code is licensed under the GNU Affero General Public License v3 or newer")
                  #:family '(font-serif)
                  #:size '(text-sm)
                  #:weight '(font-light)))
         (div (@ (class ,(mk-class '(my-3 flex
                                          flex-row
                                          flex-wrap
                                          gap-3
                                          justify-center
                                          items-center
                                          align-center))))
              ,(p (G_ "find the source code here:")
                  #:size '(text-sm)
                  #:weight '(font-light))
              ,(a "codeberg.org/jjba23/carvoeiro-water-fun"
                  #:href "https://codeberg.org/jjba23/carvoeiro-water-fun"
                  #:size '(text-sm)
                  #:family '(font-serif)
                  #:weight '(font-light))))))

(define* (info-links-footer-section)
  `((div (@ (class ,(mk-class '(flex flex-col gap-2))))
         (div (@ (class ,(mk-class '(flex flex- flex-wrap gap-3 items-center))))
              ,(icon #:type 'chat-circle-dots
                     #:icon-css '(text-md text-onyx-500))
              ,(p (G_ "WhatsApp:")
                  #:weight '(font-light)
                  #:size '(text-sm))
              ,(a "wa.me/+351931933847"
                  #:href "https://wa.me/+351931933847"
                  #:size '(text-sm)))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
                                          items-center))))
              ,(icon #:type 'phone
                     #:icon-css '(text-md text-onyx-500))
              ,(p (G_ "Telephone:")
                  #:weight '(font-light)
                  #:size '(text-sm))
              ,(a "+351 931 933 847"
                  #:href "tel:+351931933847"
                  #:size '(text-sm)))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
                                          items-center))))
              ,(icon #:type 'envelope
                     #:icon-css '(text-md text-onyx-500))
              ,(p (G_ "Email:")
                  #:weight '(font-light)
                  #:size '(text-sm))
              ,(a "carvoeirowaterfun@gmail.com"
                  #:href "mailto:carvoeirowaterfun@gmail.com"
                  #:size '(text-sm))))))

(define* (footer-section)
  `(
    (div (@ (class ,(mk-class '(pt-12 pb-12
                                      flex
                                      flex-row
                                      bg-white-smoke-700/50
                                      flex-wrap
                                      gap-12
                                      justify-center
                                      align-center items-center))))
         ,(copy-footer-section)
         ,(info-links-footer-section))))
