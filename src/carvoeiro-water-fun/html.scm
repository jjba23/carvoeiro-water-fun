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

(define-module (carvoeiro-water-fun html)
  #:declarative? #t
  #:use-module (web server)
  #:use-module (web request)
  #:use-module (web response)
  #:use-module (web uri)
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
  #:export (carvoeiro-water-fun carvoeiro-water-fun-main-body asset-library
                                footer-section
                                carvoeiro-water-fun-html-template))

(define* (carvoeiro-water-fun-html-template #:key title body)
  `(html (head (title ,title)
               ,(hygguile-recommended-meta)
               ,(hygguile-recommended-resources)
               (link (@ (rel stylesheet)
                        (href "/css/carvoeiro-water-fun.olive.min.css")) "")
               (script (@ (type speculationrules))
                       "
{
  \"prerender\": [
    {
      \"where\": {
        \"selector_matches\": \"a\"
      }
    }
  ]
}
"))
         (body (@ (class ,(mk-class '(break-words bg-white-smoke-300))))
               (div (@ (class ,(mk-class '(py-8))))
                    ,@body
                    ,(footer-section)))))

(define* (footer-section)
  `(,(hr) (div (@ (class ,(mk-class '(flex flex-col
                                           gap-3
                                           text-center
                                           align-center
                                           items-center
                                           px-4
                                           md:px-6
                                           lg:px-8))))

               (div (@ (class ,(mk-class '(max-w-128))))
                    ,(p (G_
                         "Copyright © Carvoeiro Water Fun - All rights reserved")
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
                    ,(a "https://codeberg.org/jjba23/carvoeiro-water-fun"
                        #:size '(text-sm)
                        #:family '(font-serif)
                        #:weight '(font-light))))))

(define* (mk-header-img src)
  `((img (@ (class ,(mk-class '(h-auto max-w-full shadow-2xl rounded-2xl)))
            (src ,src)))))

(define* (carvoeiro-water-fun-main-body)
  `((div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2 slide-from-right
                                     justify-center))))
         ,(h1 (G_ "Carvoeiro")
              #:weight '(font-light)
              #:size '(text-16))
         (span (@ (class ,(mk-class '(text-16)))) "⚓")
         ,(h1 (G_ "Water Fun")
              #:color '(text-jeans-blue-300)
              #:weight '(font-light)
              #:size '(text-16)))
    (div (@ (class ,(mk-class '(py-12 px-4
                                      md:px-6
                                      lg:px-8
                                      flex
                                      flex-row
                                      flex-wrap
                                      justify-center
                                      w-full))))
         (div (@ (class ,(mk-class '(max-w-prose text-center flex flex-col
                                                 gap-8))))
              ,(p (G_
                   "Book a boat tour around the beautiful cliffs and caves or rent some nautical equipment for a fun beach day in the Algarve.")
                  #:weight '(font-light)
                  #:family '(font-serif)
                  #:size '(text-lg))
              (div (@ (class ,(mk-class '(my-3 flex flex-row flex-wrap gap-4
                                               justify-center))))
                   ,(a (icon-button #:icon 'sailboat
                                    #:content (G_ "About the Boat Tour")
                                    #:background '(bg-stone-300)
                                    #:icon-css '(text-onyx-300 text-xl)
                                    #:color '(text-onyx-300)
                                    #:weight '(font-light)
                                    #:hover-background '(hover:bg-teal-900))
                       #:href "#")
                   ,(a (icon-button #:icon 'calendar
                                    #:content (G_ "Book Now - Contact")
                                    #:background '(bg-jeans-blue-500)
                                    #:color '(text-white-smoke-300)
                                    #:icon-css '(text-white-smoke-100 text-xl)
                                    #:weight '(font-light)
                                    #:hover-background '(hover:bg-green-900))
                       #:href "#contact-us-section"))
              (div ,(em (G_ "Enjoy the best of")
                        #:weight '(font-light)
                        #:size '(text-lg))
                   ,(em (G_ " Carvoeiro & Benagil ")
                        #:weight '(font-bold)
                        #:color '(text-onyx-100)
                        #:size '(text-lg))
                   ,(em (G_ "from the beautiful ocean.")
                        #:weight '(font-light)
                        #:size '(text-lg)))))

    (div (@ (class ,(mk-class '(px-3))))
         ,(carousel #:id 'first-carousel
                    #:item-width '(w-96)
                    #:item-height '(h-auto)
                    #:fragments (list (mk-header-img
                                       "/img/FB_IMG_1719434026784.jpg")
                                      (mk-header-img
                                       "/img/FB_IMG_1719434185151.jpg")
                                      (mk-header-img "/img/barco-scaled.jpg")
                                      (mk-header-img "/img/car2.jpeg"))
                    #:carousel-button-css '(absolute bottom-1/2
                                                     w-14
                                                     h-14
                                                     bg-stone-500/75
                                                     p-1
                                                     rounded-3xl
                                                     text-onyx-500
                                                     cursor-pointer
                                                     font-bold
                                                     text-3xl)
                    #:carousel-list-css '(flex gap-16
                                               p-4
                                               list-none
                                               overflow-x-scroll
                                               snap-x
                                               bg-stone-300/75
                                               rounded-xl
                                               shadow-md
                                               my-6)))

    ,(enjoy-algarve-section)
    (div (@ (class ,(mk-class '(flex flex-row
                                     flex-wrap
                                     gap-10
                                     items-center
                                     justify-center
                                     px-4
                                     md:px-6
                                     lg:px-8
                                     py-12
                                     bg-white-smoke-500/75))))
         ,(contact-us-section)
         ,(where-to-find-us-section))

    (div (@ (class ,(mk-class '(py-8 px-4
                                     md:px-6
                                     lg:px-8
                                     flex
                                     flex-row
                                     flex-wrap
                                     gap-4
                                     justify-center))))
         ,(leave-a-review-section)
         ,(insurance-section))

    ))

(define* (enjoy-algarve-section)
  `((div (@ (class ,(mk-class '(py-6 px-4 md:px-6 lg:px-8 bg-white shadow-xl))))
         ,(h3 `(div ,(icon #:type 'island
                           #:icon-css '(text-xl text-onyx-600 mr-2))
                    ,(G_ "Enjoy Algarve's spectacular coast")))
         (div (@ (class ,(mk-class '(flex flex-row
                                          flex-wrap
                                          gap-6
                                          justify-between
                                          align-center
                                          items-center))))
              (div (@ (class ,(mk-class '(my-3 md:max-w-128 lg:max-w-196 flex
                                               flex-col gap-3))))
                   ,(p (G_
                        "Take a boat tour with us, or row in a kayak, and make your way to the many beautiful caves in the Algarve's coastline.")
                       #:weight '(font-light))
                   ,(p (G_
                        "🐬 Corvine and other kinds of dolphins and wildlife are common sight in our coasts, and add to the magical experience of a great holiday here.")
                       #:weight '(font-light))
                   ,(p (G_
                        "The Algarve’s coastline is known for its beautiful cliffs, rock formations, grottos, and many sea caves.")
                       #:weight '(font-light))
                   ,(p (G_
                        "While it’s possible to enjoy the beauty of the coast from land, seeing it from the sea is a unique experience.")
                       #:weight '(font-light)))
              (div (img (@ (class ,(mk-class '(h-auto md:max-w-96 lg:max-w-128
                                                      shadow-2xl rounded-2xl)))
                           (src "/img/FB_IMG_1685655800663(1).jpg"))))))))

(define* (insurance-section)
  `((div (@ (class ,(mk-class '(px-4 md:px-6
                                     lg:px-8
                                     max-w-128
                                     flex
                                     flex-col
                                     gap-2))))
         ,(h4 (G_ "About us - Insurance"))
         ,(em (G_
               "Proceedings from the Municipal Chamber of Lagoa E/8399/2023 date of 2023-03-13.")
              #:size '(text-sm))
         ,(p (G_
              "Civil Liability Insurance Policy No. 85/25935 Maritime Tourism €50,000.00")
             #:weight '(font-light)
             #:size '(text-sm))
         ,(p (G_ "Death or Permanent Disability €1,120,000.00")
             #:weight '(font-light)
             #:size '(text-sm))
         ,(p (G_ "Treatment and Repatriation Expenses €196,000.00")
             #:weight '(font-light)
             #:size '(text-sm)))))

(define* (leave-a-review-section)
  `((div (@ (class ,(mk-class '(flex flex-col gap-3))))
         ,(h4 (G_ "Leave a review"))
         ,(em (G_
               "You can read more reviews, and we are thankful if you write us one."))
         (a (@ (href "https://maps.app.goo.gl/evwhXe4U8YWzJuDe6")
               (target _blank))
            ,(icon-button #:icon 'link
                          #:content (G_ "Reviews on Google Maps")
                          #:size '(text-sm)))
         (div (img (@ (class ,(mk-class '(h-auto max-h-80
                                                 max-w-full
                                                 w-full
                                                 sm:w-1/2
                                                 md:w-1/3
                                                 lg:w-1/4
                                                 rounded-xl)))
                      (src "/img/carvoeiro-water-fun-review.png")))))))

(define* (carvoeiro-water-fun)
  (with-output-to-string (lambda ()
                           (sxml->xml (carvoeiro-water-fun-html-template
                                       #:title "Carvoeiro Water Fun"
                                       #:body (carvoeiro-water-fun-main-body))))))

(define* (where-to-find-us-section)
  `((div (@ (class ,(mk-class '(lg:w-1/3 max-w-prose flex flex-col gap-2))))
         ,(h3 `(div ,(icon #:type 'map-pin
                           #:icon-css '(text-xl text-onyx-600 mr-2))
                    ,(G_ "Where to find us?")))
         (div (@ (class ,(mk-class '(my-3))))
              ,(em (G_ "Open daily from 09:00AM until 06:00PM.")))
         ,(p (G_
              "You can find us daily, right on Carvoeiro's beach sands, and feel free to approach our co-workers.")
             #:weight '(font-light)
             #:size '(text-md))
         ,(p (G_
              "We really appreciate it if you can book our services in advance.")
             #:weight '(font-light))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
                                          items-center my-4))))
              ,(p (G_ "Our address:")
                  #:weight '(font-light)
                  #:size '(text-md))
              ,(p
                "Rua do Casino, 29 A, Carvoeiro, 8400-515 Praia do Carvoeiro"
                #:size '(text-md))))))

(define* (contact-us-section)
  `((div (@ (id contact-us-section)
            (class ,(mk-class '(lg:w-1/3 flex flex-col gap-3 max-w-prose))))
         ,(h3 `(div ,(icon #:type 'phone-transfer
                           #:icon-css '(text-xl text-onyx-600 mr-2))
                    ,(G_ "Contact us")))
         ,(p (G_
              "Please contact us for reservations and for any questions regarding the boat tour and offers!")
             #:weight '(font-light)
             #:size '(text-md))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
                                          items-center))))
              ,(icon #:type 'chat-circle-dots
                     #:icon-css '(text-xl text-onyx-600))
              ,(p (G_ "WhatsApp:")
                  #:weight '(font-light))
              ,(a "wa.me/+351931933847"
                  #:href "https://wa.me/+351931933847"))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
                                          items-center))))
              ,(icon #:type 'phone
                     #:icon-css '(text-xl text-onyx-600))
              ,(p (G_ "Telephone:")
                  #:weight '(font-light))
              ,(a "+351 931 933 847"
                  #:href "tel:+351931933847"))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
                                          items-center))))
              ,(icon #:type 'envelope
                     #:icon-css '(text-xl text-onyx-600))
              ,(p (G_ "Email:")
                  #:weight '(font-light))
              ,(a "carvoeirowaterfun@gmail.com"
                  #:href "mailto:carvoeirowaterfun@gmail.com"))
         (div (@ (class ,(mk-class '(flex flex-col gap-2 mt-2))))
              ,(em (G_ "Note: Call costs to mobile network.")
                   #:size '(text-md))
              ,(em (G_
                    "You may incur monetary costs while calling our phone number, as it will be a call to a Portuguese telephone.")
                   #:size '(text-md))))))
