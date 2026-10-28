;; Carvoeiro Water Fun
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (carvoeiro-water-fun html)
  #:declarative? #t
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (ice-9 regex)
  #:use-module (sxml ssax input-parse)
  #:use-module (sxml ssax)
  #:use-module (sxml transform)
  #:use-module (carvoeiro-water-fun components footer)
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
                                carvoeiro-water-fun-html-template))

(define speculation-rules
  `((script (@ (type speculationrules)) "
{
  \"prerender\": [
    {
      \"where\": {
        \"selector_matches\": \"a\"
      }
    }
  ]
}
")))

(define custom-fonts
  `((link (@ (rel preconnect)
             (href "https://fonts.googleapis.com")))
    (link (@ (rel preconnect)
             (href "https://fonts.gstatic.com")
             (crossorigin "")))
    (link (@ (rel stylesheet)
             (href
              "https://fonts.googleapis.com/css2?family=Intel+One+Mono:ital,wght@0,300..700;1,300..700&family=Lora:ital,wght@0,400..700;1,400..700&family=Plus+Jakarta+Sans:ital,wght@0,200..800;1,200..800&display=swap")))))

(define* (carvoeiro-water-fun-html-template #:key title body locale)
  `(,doctype-html (html (@ (style "scroll-behavior: smooth;")
                           (lang ,(string-take (format #f "~a" locale) 2)))
                        (head (title ,title)
                              ,(hygguile-recommended-meta)
                              ,(hygguile-recommended-resources #:fonts
                                                               custom-fonts)
                              (meta (@ (property "og:image")
                                       (content
                                        "https://carvoeirowaterfun.com/img/barco-scaled.jpg"))
                                    "")
                              (meta (@ (property "og:title")
                                       (content ,title)) "")
                              (meta (@ (name description)
                                       (content ,(G_
                                                  "Book a boat tour around the beautiful cliffs and caves or rent some nautical equipment for a fun beach day in the Algarve.")))
                                    "")

                              (link (@ (rel stylesheet)
                                       (href
                                        "/css/carvoeiro-water-fun.olive.min.css"))
                                    "")
                              (link (@ (rel stylesheet)
                                       (href "/css/maritime.css"))
                                    "")
                              ,speculation-rules
                              (script "" "document.documentElement.classList.add('js');")
                              (noscript (style (@ (type "text/css"))
                                               ".js [data-reveal] {opacity: 1; transform: none; filter: none;}")))
                        (script (@(src "/js/symbanta.js")) "")
                        (body (@ (class ,(mk-class '(maritime-body
                                                     break-words
                                                     bg-white-smoke-300))))
                              (div (@ (class "tide-line")
                                      (aria-hidden "true"))
                                   (span (@ (class "tide-line__fill")) ""))
                              (div (@ (class "sea-canvas")
                                      (aria-hidden "true"))
                                   (div (@ (class "tide tide--1")) "")
                                   (div (@ (class "tide tide--2")) "")
                                   (div (@ (class "tide tide--3")) ""))
                              (div (@ (class "page-layer"))
                                   ,@body
                                   ,(footer-section))
                              (script (@ (src "/js/maritime.js")
                                         (defer "defer"))
                                      "")))))

(define* (mk-header-img src)
  `((div (@ (class "photo-frame"))
         (img (@ (class ,(mk-class '(h-auto w-full)))
                 (src ,src)
                 (loading "lazy")
                 (decoding "async")
                 (alt ""))))))

(define* (carvoeiro-water-fun-main-body #:key locale)
  `((div (@ (class "hero-shell"))
         (div (@ (class "glass glass--panel hero")
                 (data-tilt "true"))
              (div (@ (class "hero-title-row"))
                   ,(h1 (G_ "Carvoeiro")
                        #:weight '(font-light)
                        #:size '(text-16))
                   (span (@ (class ,(mk-class '(text-16 hero-anchor)))
                            (aria-hidden "true"))
                         "⚓")
                   (h1 (@ (class ,(mk-class '(text-16 hero-title
                                                      shimmer font-light
                                                      font-sans))))
                       ,(G_ "Water Fun")))
              (div (@ (class "gold-rule")) "")
              (div (@ (class "hero-content max-w-prose flex flex-col gap-8"))
                   ,(p (G_
                        "Book a boat tour around the beautiful cliffs and caves or rent some nautical equipment for a fun beach day in the Algarve.")
                       #:weight '(font-light leading-8)
                       #:family '(font-serif)
                       #:size '(text-lg))
                   (div (@ (class ,(mk-class '(hero-actions my-3 flex
                                                            flex-row
                                                            flex-wrap
                                                            gap-4
                                                            justify-center
                                                            items-center
                                                            align-center))))
                        ,(when (eq? locale
                                    'en_US)
                           (a (button "🇵🇹 Português"
                                      #:weight '(font-light)
                                      #:size '(text-sm)
                                      #:background '(bg-stone-300))
                              #:href "/pt"))
                        ,(when (eq? locale
                                    'pt_PT)
                           (a (button "🇬🇧 English"
                                      #:weight '(font-light)
                                      #:size '(text-sm)
                                      #:background '(bg-stone-300))
                              #:href "/"))
                        ,(a (icon-button #:icon 'sailboat
                                         #:content (G_ "About the boat tour")
                                         #:background '(bg-stone-300)
                                         #:icon-css '(text-onyx-300 text-xl)
                                         #:color '(text-onyx-300)
                                         #:weight '(font-light)
                                         #:extra-classes '(hover-lift py-2 px-4
                                                                    max-w-prose
                                                                    cursor-pointer)
                                         #:hover-background '(hover:bg-stone-700))
                            #:href "#about-boat-tour-section")
                        ,(a (icon-button #:icon 'calendar
                                         #:content (G_ "Book your experience")
                                         #:background '(bg-jeans-blue-500)
                                         #:color '(text-white-smoke-300)
                                         #:icon-css '(text-white-smoke-100 text-xl)
                                         #:weight '(font-light)
                                         #:extra-classes '(hover-lift py-2 px-4
                                                                    max-w-prose
                                                                    cursor-pointer)
                                         #:hover-background '(hover:bg-jeans-blue-900))
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
                             #:size '(text-lg))))))

    (div (@ (class "carousel-shell px-3 py-2")
            (data-reveal "true"))
         ,(carousel #:id 'first-carousel
                    #:item-width '(w-96)
                    #:item-height '(h-auto)
                    #:fragments (list (mk-header-img
                                       "/img/FB_IMG_1719434007758.jpg")
                                      (mk-header-img
                                       "/img/FB_IMG_1719434096367.jpg")
                                      (mk-header-img
                                       "/img/FB_IMG_1719434138555.jpg")
                                      (mk-header-img
                                       "/img/FB_IMG_1719434185151.jpg")
                                      (mk-header-img "/img/barco-scaled.jpg")
                                      (mk-header-img
                                       "/img/FB_IMG_1719434201178.jpg")
                                      (mk-header-img
                                       "/img/FB_IMG_1719434026784.jpg")
                                      (mk-header-img "/img/car2.jpeg"))
                    #:carousel-button-css '(glass hover-lift absolute
                                                   bottom-1/2
                                                   w-14
                                                   h-14
                                                   p-1
                                                   text-onyx-500
                                                   cursor-pointer
                                                   font-bold
                                                   text-3xl)
                    #:carousel-list-css '(carousel-glass flex gap-16
                                                         p-4
                                                         list-none
                                                         overflow-x-scroll
                                                         snap-x
                                                         my-6)))

    ,(enjoy-algarve-section)
    (div (@ (class "card-row section-shell"))
         (div (@ (class "glass glass--card")
                 (data-reveal "true"))
              ,(contact-us-section))
         (div (@ (class "glass glass--card")
                 (data-reveal "true"))
              ,(where-to-find-us-section)))

    (div (@ (class "section-shell")
            (data-reveal "true"))
         ,(map-frame-section))

    (div (@ (class "section-shell")
            (data-reveal "true"))
         ,(about-boat-tour-section))

    (div (@ (class "card-row section-shell"))
         (div (@ (class "glass glass--card")
                 (data-reveal "true"))
              ,(leave-a-review-section))
         (div (@ (class "glass glass--card")
                 (data-reveal "true"))
              ,(insurance-section)))))

(define* (enjoy-algarve-section)
  `((div (@ (class "section-shell")
            (data-reveal "true"))
         (div (@ (class "glass glass--panel"))
              (div (@ (class "card-head"))
                   (div (@ (class "medallion"))
                        ,(icon #:type 'waves #:icon-css '(text-lg)))
                   ,(h3 (G_ "Enjoy Algarve's spectacular coast")))
              (div (@ (class "gold-rule")) "")
              ,(p (G_
                   "Take a boat tour with us, or row in a kayak, and make your way to the many beautiful caves in the Algarve's coastline.")
                  #:weight '(font-light leading-8))
              (div (@ (class ,(mk-class '(theme-grid my-6))))
                   (div (@ (class "glass glass--card theme-card"))
                        (div (@ (class "theme-card__media"))
                             (img (@ (class "")
                                     (src "/img/FB_IMG_1719434096367.jpg")
                                     (loading "lazy")
                                     (decoding "async")
                                     (alt "")))
                             (div (@ (class "medallion theme-card__badge"))
                                  ,(icon #:type 'fish #:icon-css '(text-lg))))
                        (div (@ (class "theme-card__body"))
                             ,(p (G_
                                  "🐬 Corvine and other kinds of dolphins and wildlife are common sight in our coasts, and add to the magical experience of a great holiday here.")
                                 #:size '(text-md)
                                 #:weight '(font-light leading-8))))
                   (div (@ (class "glass glass--card theme-card"))
                        (div (@ (class "theme-card__media"))
                             (img (@ (class "")
                                     (src "/img/FB_IMG_1719434180086.jpg")
                                     (loading "lazy")
                                     (decoding "async")
                                     (alt "")))
                             (div (@ (class "medallion theme-card__badge"))
                                  ,(icon #:type 'island #:icon-css '(text-lg))))
                        (div (@ (class "theme-card__body"))
                             ,(p (G_
                                  "The Algarve’s coastline is known for its beautiful cliffs, rock formations, grottos, and many sea caves.")
                                 #:size '(text-md)
                                 #:weight '(font-light leading-8))))
                   (div (@ (class "glass glass--card theme-card"))
                        (div (@ (class "theme-card__media"))
                             (img (@ (class "")
                                     (src "/img/FB_IMG_1719434138555.jpg")
                                     (loading "lazy")
                                     (decoding "async")
                                     (alt "")))
                             (div (@ (class "medallion theme-card__badge"))
                                  ,(icon #:type 'boat #:icon-css '(text-lg))))
                        (div (@ (class "theme-card__body"))
                             ,(p (G_
                                  "While it’s possible to enjoy the beauty of the coast from land, seeing it from the sea is a unique experience.")
                                 #:size '(text-md)
                                 #:weight '(font-light leading-8))))))
     (div (@ (class "grotto-band") (data-reveal "true"))
          (div (@ (class "grotto-frame") (data-parallax "26"))
               (img (@ (class "")
                       (src "/img/FB_IMG_1719434196131.jpg")
                       (loading "lazy")
                       (decoding "async")
                       (alt ""))))))))

(define* (insurance-section)
  `((div (@ (class ,(mk-class '(px-4 md:px-6
                                     lg:px-8
                                     max-w-128
                                     flex
                                     flex-col
                                     gap-2))))
         (div (@ (class "card-head"))
              (div (@ (class "medallion"))
                   ,(icon #:type 'newspaper #:icon-css '(text-lg)))
              ,(h4 (G_ "About us - Insurance")))
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
  `((div (@ (class ,(mk-class '(review-card flex flex-col gap-3 px-2))))
         (div (@ (class "card-head"))
              (div (@ (class "medallion"))
                   ,(icon #:type 'list-star #:icon-css '(text-lg)))
              ,(h4 (G_ "Leave a review")))
         ,(em (G_
               "You can read more reviews, and we are thankful if you write us one."))
         (a (@ (href "https://maps.app.goo.gl/evwhXe4U8YWzJuDe6")
               (target _blank)
               (rel "noopener"))
            ,(icon-button #:icon 'link
                          #:content (G_ "Reviews on Google Maps")
                          #:extra-classes '(hover-lift py-2 px-4
                                                     max-w-prose
                                                     cursor-pointer)
                          #:size '(text-sm)))
         (div (@ (class "photo-frame review-qr"))
              (img (@ (class ,(mk-class '(h-auto w-full)))
                      (src "/img/carvoeiro-water-fun-review.png")
                      (loading "lazy")
                      (decoding "async")
                      (alt "")))))))

(define* (carvoeiro-water-fun #:key (locale 'en_US))
  (with-output-to-string (lambda ()
                           (sxml->xml (carvoeiro-water-fun-html-template
                                       #:title "Carvoeiro Water Fun"
                                       #:locale locale
                                       #:body (carvoeiro-water-fun-main-body
                                               #:locale locale))))))

(define* (where-to-find-us-section)
  `((div (@ (class ,(mk-class '(w-full max-w-prose flex flex-col gap-2))))
         ,(h3 `(div (@ (class "card-head"))
                    (div (@ (class "medallion"))
                         ,(icon #:type 'map-pin #:icon-css '(text-lg)))
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
            (class ,(mk-class '(w-full flex flex-col gap-3 max-w-prose))))
         ,(h3 `(div (@ (class "card-head"))
                    (div (@ (class "medallion"))
                         ,(icon #:type 'phone-transfer #:icon-css '(text-lg)))
                    ,(G_ "Contact us")))
         ,(p (G_
              "Please contact us for reservations and for any questions regarding the boat tour and offers!")
             #:weight '(font-light)
             #:size '(text-md))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
                                          items-center))))
              ,(icon #:type 'chat-circle-dots
                     #:icon-css '(text-xl text-onyx-500))
              ,(p (G_ "WhatsApp:")
                  #:weight '(font-light))
              ,(a "wa.me/+351931933847"
                  #:href "https://wa.me/+351931933847"
                  #:extra-classes '(link-lux no-underline)))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
                                          items-center))))
              ,(icon #:type 'phone
                     #:icon-css '(text-xl text-onyx-500))
              ,(p (G_ "Telephone:")
                  #:weight '(font-light))
              ,(a "+351 931 933 847"
                  #:href "tel:+351931933847"
                  #:extra-classes '(link-lux no-underline)))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
                                          items-center))))
              ,(icon #:type 'envelope
                     #:icon-css '(text-xl text-onyx-500))
              ,(p (G_ "Email:")
                  #:weight '(font-light))
              ,(a "carvoeirowaterfun@gmail.com"
                  #:href "mailto:carvoeirowaterfun@gmail.com"
                  #:extra-classes '(link-lux no-underline)))
         (div (@ (class ,(mk-class '(flex flex-col gap-2 mt-2))))
              ,(em (G_ "Note: Call costs to mobile network.")
                   #:size '(text-sm))
              ,(em (G_
                    "You may incur monetary costs while calling our phone number, as it will be a call to a Portuguese telephone.")
                   #:size '(text-sm))))))

(define map-frame-url
  "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3182.37556480607!2d-8.471684899999998!3d37.09617659999999!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0xd1ad764b5120b8b%3A0x108f3a9ef89e164e!2sCarvoeiro%20Water%20Fun!5e0!3m2!1snl!2snl!4v1718611022914!5m2!1snl!2snl")

(define* (map-frame-section)
  `((div (@ (class "map-shell glass")
            (data-tilt "true"))
         (iframe (@ (src ,map-frame-url)
                    (width "100%")
                    (height 500)
                    (title (G_ "Map showing the location of our business"))
                    (style "border:0;")
                    (allowfullscreen true)
                    (loading lazy)
                    (referrerpolicy "no-referrer-when-downgrade")
                    (class ,(mk-class '(w-full)))) ""))))

(define* (about-boat-tour-section)
  `((div (@ (id about-boat-tour-section)
            (class "glass glass--panel section-shell flex flex-row
                    flex-wrap gap-12 justify-center items-center"))
         (div (@ (class ,(mk-class '(flex flex-col gap-2 md:max-w-128
                                          leading-6))))
              (div (@ (class "card-head"))
                   (div (@ (class "medallion"))
                        ,(icon #:type 'sailboat #:icon-css '(text-lg)))
                   ,(h3 (G_ "About the boat tour")))
              (div (@ (class "spec-list"))
                   ,(dl (list (dt (G_ "Tour duration"))
                              (dd (G_ "2 hours")
                                  #:size '(text-md))
                              (dt (G_ "Boarding location"))
                              (dd
                               "Praia do Carvoeiro (with free transport to Ferragudo)"
                               #:size '(text-md)))))
              ,(p (G_
                   "This program includes a brief stop by the beach to dive whenever be possible.")
                  #:size '(text-md)
                  #:weight '(font-light))
              ,(p (G_
                   "Experience the breathtaking beauty of Portugal's stunning Algarve coastline on this tour. The boarding is done in Carvoeiro, we provide transport to Ferragudo to start the tour.")
                  #:size '(text-md)
                  #:weight '(font-light))
              ,(p (G_
                   "We are a team of professionals, passionate about the sea, who are dedicated to their work to make your trip a unique and unforgettable moment!")
                  #:size '(text-md)
                  #:weight '(font-light))
              ,(p (G_
                   "The trip will start heading to the dolphins habitat and on the way back we visit Praia da Marinha, Algar de Benagil, Olhos de Deus, the largest cave in the Algarve, and much more.")
                  #:size '(text-md)
                  #:weight '(font-light))
              ,(p (G_
                   "Our professionals like to share their extensive knowledge about the region, as well as marine life, and the local ecosystem, ensuring that all our passengers can fully understand and appreciate the wonderful marine life.")
                  #:size '(text-md)
                  #:weight '(font-light)))
         (div (@ (class ,(mk-class '(md:max-w-1/3 leading-6))))
              (div (@ (class "spec-list"))
                   ,(dl (list (dt (G_ "Health & Safety"))
                              (dd (G_
                                   "We do not recommend the speed boat tour to people with serious back problems, or weighing more than 120kg and pregnant women in late stages of pregnancy.")
                                  #:weight '(font-light)
                                  #:size '(text-md))
                              (dt (G_ "Included"))
                              (dd (G_ "Life jacket, Waterproofing when necessary.")
                                  #:weight '(font-light)
                                  #:size '(text-md))
                              (dt (G_ "Not included"))
                              (dd (G_ "Swimsuit, towel, sun lotion, sunglasses.")
                                  #:weight '(font-light)
                                  #:size '(text-md))
                              (dt (G_ "Cancellation policy"))
                              (dd (G_
                                   "For a full refund, cancel at least 24 hours in advance of the tour start date.")
                                  #:weight '(font-light)
                                  #:size '(text-md)))))))))
