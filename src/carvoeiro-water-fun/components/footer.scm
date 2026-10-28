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

(define* (footer-brand-section)
  `((div (@ (class "footer-brand"))
         (div (@ (class "footer-mark"))
              ,(icon #:type 'anchor #:icon-css '(text-2xl)))
         (div (@ (class "footer-name"))
              ,(G_ "Carvoeiro Water Fun"))
         ,(p (G_ "Boat tours, dolphins and the sea caves of the Algarve.")
             #:size '(text-sm)
             #:weight '(font-light)))))

(define* (footer-nav-section)
  `((nav (@ (class "footer-nav")
            (aria-label "Footer"))
         (div (@ (class "footer-col__title"))
              ,(G_ "Explore"))
         ,(a (G_ "About the boat tour")
             #:href "#about-boat-tour-section"
             #:extra-classes '(link-lux))
         ,(a (G_ "Book your experience")
             #:href "#contact-us-section"
             #:extra-classes '(link-lux))
         ,(a (G_ "Reviews on Google Maps")
             #:href "https://maps.app.goo.gl/evwhXe4U8YWzJuDe6"
             #:extra-classes '(link-lux))
         ,(a (G_ "Contact us")
             #:href "#contact-us-section"
             #:extra-classes '(link-lux)))))

(define* (footer-contact-section)
  `((div (@ (class "footer-contact"))
         (div (@ (class "footer-col__title"))
              ,(G_ "Contact"))
         (div (@ (class "footer-contact__row"))
              ,(icon #:type 'chat-circle-dots
                     #:icon-css '(text-md text-onyx-500))
              ,(a "wa.me/+351931933847"
                  #:href "https://wa.me/+351931933847"
                  #:extra-classes '(link-lux)))
         (div (@ (class "footer-contact__row"))
              ,(icon #:type 'phone
                     #:icon-css '(text-md text-onyx-500))
              ,(a "+351 931 933 847"
                  #:href "tel:+351931933847"
                  #:extra-classes '(link-lux)))
         (div (@ (class "footer-contact__row"))
              ,(icon #:type 'envelope
                     #:icon-css '(text-md text-onyx-500))
              ,(a "carvoeirowaterfun@gmail.com"
                  #:href "mailto:carvoeirowaterfun@gmail.com"
                  #:extra-classes '(link-lux))))))

(define* (footer-legal-section)
  `((div (@ (class "footer-legal"))
         ,(p (G_ "Copyright © Carvoeiro Water Fun - All rights reserved")
             #:family '(font-sans)
             #:size '(text-sm)
             #:weight '(font-light))
         (div (@ (class "footer-legal__links"))
              ,(a (G_ "this page's source code is licensed under the MIT License")
                  #:href "https://opensource.org/license/mit"
                  #:size '(text-sm)
                  #:family '(font-sans)
                  #:weight '(font-light)
                  #:extra-classes '(link-lux))
              (span (@ (class "footer-legal__dot")) "·")
              ,(a (G_ "source code")
                  #:href "https://github.com/jjba23/carvoeiro-water-fun"
                  #:size '(text-sm)
                  #:family '(font-sans)
                  #:weight '(font-light)
                  #:extra-classes '(link-lux))))))

;; The cave and Ferragudo photographs are borrowed under CC licences, so their
;; authors and terms live in one quiet line at the foot of the page.
(define* (footer-credit-section)
  `((div (@ (class "footer-credit"))
         ,(p (G_ "Photographs:")
             #:family '(font-sans)
             #:size '(text-sm)
             #:weight '(font-light))
         ,(a "Joseolgon"
             #:href "https://commons.wikimedia.org/wiki/User:Joseolgon"
             #:size '(text-sm)
             #:family '(font-sans)
             #:weight '(font-light))
         (span (@ (class "footer-legal__dot")) "·")
         ,(a "CC BY-SA 4.0"
             #:href "https://creativecommons.org/licenses/by-sa/4.0/"
             #:size '(text-sm)
             #:family '(font-sans)
             #:weight '(font-light))
         (span (@ (class "footer-legal__dot")) "·")
         ,(a "muffinn"
             #:href "https://www.flickr.com/people/26445715@N00"
             #:size '(text-sm)
             #:family '(font-sans)
             #:weight '(font-light))
         (span (@ (class "footer-legal__dot")) "·")
         ,(a "CC BY 2.0"
             #:href "https://creativecommons.org/licenses/by/2.0/"
             #:size '(text-sm)
             #:family '(font-sans)
             #:weight '(font-light))
         (span (@ (class "footer-legal__dot")) "·")
         ,(a "Enric Rubio Ros"
             #:href "https://www.flickr.com/photos/windenric1/51844729713/"
             #:size '(text-sm)
             #:family '(font-sans)
             #:weight '(font-light))
         (span (@ (class "footer-legal__dot")) "·")
         ,(a "CC BY 2.0"
             #:href "https://creativecommons.org/licenses/by/2.0/"
             #:size '(text-sm)
             #:family '(font-sans)
             #:weight '(font-light))
         (span (@ (class "footer-legal__dot")) "·")
         ,(a "Vitor Oliveira"
             #:href "https://www.flickr.com/photos/vitor107/16247829346/"
             #:size '(text-sm)
             #:family '(font-sans)
             #:weight '(font-light))
         (span (@ (class "footer-legal__dot")) "·")
         ,(a "CC BY-SA 2.0"
             #:href "https://creativecommons.org/licenses/by-sa/2.0/"
             #:size '(text-sm)
             #:family '(font-sans)
             #:weight '(font-light)))))

(define* (footer-section)
  `((div (@ (class "footer-glass"))
         (div (@ (class "footer-grid"))
              ,(footer-brand-section)
              ,(footer-nav-section)
              ,(footer-contact-section))
         ,(footer-legal-section)
         ,(footer-credit-section))))
