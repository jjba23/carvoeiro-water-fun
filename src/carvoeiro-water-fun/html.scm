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
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 threads)
  #:export (carvoeiro-water-fun carvoeiro-water-fun-main-body asset-library
                                carvoeiro-water-fun-page-footer
                                carvoeiro-water-fun-html-template))

;; ====== Serialize (SXML) ======

(define check-name
  (let ((*good-cache* (make-hash-table)))
    (lambda (name)
      (if (not (hashq-ref *good-cache* name))
          (let* ((str (symbol->string name))
                 (i (string-index str #\:))
                 (head (or (and i
                                (substring str 0 i)) str))
                 (tail (and i
                            (substring str
                                       (1+ i)))))
            (and i
                 (string-index (substring str
                                          (1+ i)) #\:)
                 (error "Invalid QName: more than one colon" name))
            (for-each (lambda (s)
                        (and s
                             (or (char-alphabetic? (string-ref s 0))
                                 (eq? (string-ref s 0) #\_)
                                 (error "Invalid name starting character" s
                                        name))
                             (string-for-each (lambda (c)
                                                (or (char-alphabetic? c)
                                                    (string-index
                                                     "0123456789.-_" c)
                                                    (error
                                                     "Invalid name character"
                                                     c s name))) s)))
                      (list head tail))
            (hashq-set! *good-cache* name #t))))))

;; The following two functions serialize tags and attributes. They are
;; being used in the node handlers for the post-order function, see
;; below.

(define (attribute-value->xml value port)
  (cond
    ((pair? value)
     (attribute-value->xml (car value) port)
     (attribute-value->xml (cdr value) port))
    ((null? value)
     *unspecified*)
    ((string? value)
     (string->escaped-xml value port))
    ((procedure? value)
     (with-output-to-port port value))
    (else (string->escaped-xml (call-with-output-string (lambda (port)
                                                          (display value port)))
                               port))))

(define (attribute->xml attr value port)
  (check-name attr)
  (display attr port)
  (display "=\"" port)
  (attribute-value->xml value port)
  (display #\" port))

(define (element->xml tag attrs body port)
  (check-name tag)
  (display #\< port)
  (display tag port)
  (if attrs
      (let lp
        ((attrs attrs))
        (if (pair? attrs)
            (let ((attr (car attrs)))
              (display #\space port)
              (if (pair? attr)
                  (attribute->xml (car attr)
                                  (cdr attr) port)
                  (error "bad attribute" tag attr))
              (lp (cdr attrs)))
            (if (not (null? attrs))
                (error "bad attributes" tag attrs)))))
  (if (pair? body)
      (begin
        (display #\> port)
        (let lp
          ((body body))
          (cond
            ((pair? body)
             (sxml->xml (car body) port)
             (lp (cdr body)))
            ((null? body)
             (display "</" port)
             (display tag port)
             (display ">" port))
            (else (error "bad element body" tag body)))))
      (display " />" port)))

;; FIXME: ensure name is valid
(define (entity->xml name port)
  (display #\& port)
  (display name port)
  (display #\; port))

;; FIXME: ensure tag and str are valid
(define (pi->xml tag str port)
  (display "<?" port)
  (display tag port)
  (display #\space port)
  (display str port)
  (display "?>" port))

(define* (sxml->xml tree
                    #:optional (port (current-output-port))
                    (escape? #f))
  "Serialize the sxml tree @var{tree} as XML. The output will be written
to the current output port, unless the optional argument @var{port} is
present."
  (cond
    ((pair? tree)
     (if (symbol? (car tree))
         ;; An element.
         (let ((tag (car tree)))
           (case tag
             ((*TOP*)
              (sxml->xml (cdr tree) port escape?))
             ((*ENTITY*)
              (if (and (list? (cdr tree))
                       (= (length (cdr tree)) 1))
                  (entity->xml (cadr tree) port)
                  (error "bad *ENTITY* args"
                         (cdr tree))))
             ((*PI*)
              (if (and (list? (cdr tree))
                       (= (length (cdr tree)) 2))
                  (pi->xml (cadr tree)
                           (caddr tree) port)
                  (error "bad *PI* args"
                         (cdr tree))))
             (else (let* ((elems (cdr tree))
                          (attrs (and (pair? elems)
                                      (pair? (car elems))
                                      (eq? '@
                                           (caar elems))
                                      (cdar elems))))
                     (element->xml tag attrs
                                   (if attrs
                                       (cdr elems) elems) port)))))
         ;; A nodelist.
         (for-each (lambda (x)
                     (sxml->xml x port)) tree)))
    ((string? tree)
     (if escape?
         (string->escaped-xml tree port)
         (display tree port)))
    ((null? tree)
     *unspecified*)
    ((not tree)
     *unspecified*)
    ((eqv? tree #t)
     *unspecified*)
    ((procedure? tree)
     (with-output-to-port port tree))
    (else (when escape?
            (string->escaped-xml (call-with-output-string (lambda (port)
                                                            (display tree port)))
                                 port)))))

(define (sxml->string sxml)
  "Detag an sxml tree @var{sxml} into a string. Does not perform any
formatting."
  (string-concatenate-reverse (foldts (lambda (seed tree)
                                        ;; fdown
                                        '())
                                      (lambda (seed kid-seed tree)
                                        ;; fup
                                        (append! kid-seed seed))
                                      (lambda (seed tree)
                                        ;; fhere
                                        (if (string? tree)
                                            (cons tree seed) seed))
                                      '() sxml)))

(define (make-char-quotator char-encoding)
  (let ((bad-chars (list->char-set (map car char-encoding))))
    
    ;; Check to see if str contains one of the characters in charset,
    ;; from the position i onward. If so, return that character's index.
    ;; otherwise, return #f
    (define (index-cset str i charset)
      (string-index str charset i))

    ;; The body of the function
    (lambda (str port)
      (let ((bad-pos (index-cset str 0 bad-chars)))
        (if (not bad-pos)
            (display str port) ;str had all good chars
            (let loop
              ((from 0)
               (to bad-pos))
              (cond
                ((>= from
                     (string-length str))
                 *unspecified*)
                ((not to)
                 (display (substring str from
                                     (string-length str)) port))
                (else (let ((quoted-char (cdr (assv (string-ref str to)
                                                    char-encoding)))
                            (new-to (index-cset str
                                                (+ 1 to) bad-chars)))
                        (if (< from to)
                            (display (substring str from to) port))
                        (display quoted-char port)
                        (loop (1+ to) new-to))))))))))

;; Given a string, check to make sure it does not contain characters
;; such as '<' or '&' that require encoding. Return either the original
;; string, or a list of string fragments with special characters
;; replaced by appropriate character entities.

(define string->escaped-xml
  (make-char-quotator '((#\< . "&lt;") (#\> . "&gt;")
                        (#\& . "&amp;")
                        (#\" . "&quot;"))))

;; ================================

(define* (carvoeiro-water-fun-html-template #:key title body)
  `(html (head (title ,title)
                                ,(hygguile-recommended-meta)
                                ,(hygguile-recommended-resources)
                                (link (@ (rel stylesheet)
                                         (href "/css/carvoeiro-water-fun.olive.min.css"))
                                      "")
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
")  )
         (body (@ (class ,(mk-class '(break-words bg-white-smoke-300 dark:bg-onyx-700))))
               (div (@ (class ,(mk-class '(container mx-auto py-4 sm:py-6 px-3
                                                     sm:px-6))))
                    ,@body
                    ,(carvoeiro-water-fun-page-footer)))))

(define* (carvoeiro-water-fun-page-footer)
  `(,(hr) (div (@ (class ,(mk-class '(block text-center font-sans))))
               (div (@ (class ,(mk-class '(my-3 flex flex-row gap-3 flex-wrap
                                                justify-center))))
                    ,(em (G_
                          "this website was rendered with Lisp (Guile Scheme) code")))
               (div (@ (class ,(mk-class '(my-3 flex
                                                flex-row
                                                gap-3
                                                flex-wrap
                                                justify-center
                                                items-center))))
                    ,(em (G_
                          "this page's source code is licensed under the GNU Affero General Public License v3 or newer (at your convenience)")))
               (div (@ (class ,(mk-class '(my-3 flex
                                                flex-row
                                                gap-3
                                                flex-wrap
                                                justify-center
                                                items-center))))
                    ,(em (G_ "find the source code here:"))
                    ,(a "https://codeberg.org/jjba23/carvoeiro-water-fun"
                        #:size '(text-sm)
                        #:weight '(font-medium)
                        #:color '(text-onyx-600 dark:text-onyx-400))))))

(define* (mk-header-img src)
  `((img (@ (class ,(mk-class '(h-auto max-h-80
                                       max-w-full
                                       w-full
                                       sm:w-1/2
                                       md:w-1/3
                                       lg:w-1/4
                                       rounded-xl)))
            (src ,src)))))

(define* (carvoeiro-water-fun-main-body)
  `((div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2))))
         ,(h1 (G_ "Carvoeiro"))
         ,(h1 (G_ "Water Fun"))
         (span (@ (class ,(mk-class '(text-3xl)))) "⚓"))
    
    (div (@ (class ,(mk-class '(my-3 max-w-prose flex flex-col gap-3))))
         ,(p (G_
              "Book a boat tour around the beautiful cliffs and caves of the Algarve, in the region of Carvoeiro, Benagil, or take a Kayak tour with us.")
             #:weight '(font-light))
         (div (@ (class ,(mk-class '(my-3 flex flex-row flex-wrap gap-4))))
              ,(a (icon-button #:icon 'sailboat
                               #:content (G_ "About the Boat Tour")
                               #:background '(bg-teal-700)
                               #:color '(text-onyx-200)
                               #:icon-css '(text-onyx-100 text-xl)
                               #:hover-background '(hover:bg-teal-900))
                  #:href "#")
              ,(a (icon-button #:icon 'calendar
                               #:content (G_ "Book Now")
                               #:background '(bg-green-700)
                               #:color '(text-onyx-200)
                               #:icon-css '(text-onyx-100 text-xl)
                               #:hover-background '(hover:bg-green-900))
                  #:href "#")
               ,(ui-mode-button)
              )
         ,(p (G_
              "Here you can find kayak tours and rentals of nautical equipment to enjoy relaxing moments of leisure with family and friends.")
             #:weight '(font-light)))

    ,(hr)

    (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2 items-center
                                     justify-center))))
         ,(mk-header-img "/img/FB_IMG_1719434096367.jpg")
         ,(mk-header-img "/img/car2.jpeg")
         ,(mk-header-img "/img/barco-scaled.jpg"))
    ,(hr)
    (div (@ (class ,(mk-class '(my-3))))
         ,(h3 `(div ,(icon #:type 'island
                           #:icon-css '(text-xl text-onyx-600 mr-2))
                    ,(G_ "Enjoy Algarve's spectacular coast")))
         (div (@ (class ,(mk-class '(my-3 max-w-prose flex flex-col gap-3))))
              ,(p (G_
                   "Take a boat tour with us, or row in a kayak, and make your way to the many beautiful caves in the Algarve's coastline.")
                  #:weight '(font-light))
              ,(p (G_
                   "🐬 Corvine and other kinds of dolphins and wildlife are common sight in our coasts, and add to the magical experience of a great holiday here.")
                  #:weight '(font-light))
              ,(p (G_
                   "The Algarve’s coastline is known for its limeonyx cliffs, rock formations, grottos, and many sea caves.")
                  #:weight '(font-light))
              ,(p (G_
                   "While it’s possible to enjoy the beauty of the coast from land, seeing it from the sea is a unique experience.")
                  #:weight '(font-light))))
    (div (@ (class ,(mk-class '(flex flex-row
                                     flex-wrap
                                     gap-2
                                     items-center
                                     justify-between
                                     my-8))))
         (div (@ (class ,(mk-class '(max-w-prose))))
              ,(h3 `(div ,(icon #:type 'phone-transfer
                                #:icon-css '(text-xl text-onyx-600 mr-2))
                         ,(G_ "Contact us")))
              ,(p (G_
                   "Please contact us for reservations and for any questions regarding the boat tour and offers!")
                  #:weight '(font-light))
              (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
                                               items-center))))
                   ,(icon #:type 'chat-circle-dots
                          #:icon-css '(text-xl text-onyx-600))
                   ,(p (G_ "WhatsApp:")
                       #:weight '(font-light))
                   ,(a "+351 931 933 847"
                       #:href "https://wa.me/+351931933847"
                       #:color '(text-lime-600 dark:text-lime-300)
                       #:hover '(hover:text-lime-800 dark:hover:text-lime-500)))
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
              (div ,(em (G_ "Call cost to mobile network."))
                   ,(em (G_
                         "You may incur monetary costs while calling our phone number, as it will be a call to a Portuguese telephone."))))
         (div (@ (class ,(mk-class '(max-w-prose))))
              ,(h3 `(div ,(icon #:type 'map-pin
                                #:icon-css '(text-xl text-onyx-600 mr-2))
                         ,(G_ "Where to find us?")))
              (div (@ (class ,(mk-class '(my-3))))
                   ,(em (G_ "Open daily from 09:00AM until 06:00PM.")))
              ,(p (G_
                   "You can find us daily, right on Carvoeiro's beach sands, and feel free to approach our co-workers.")
                  #:weight '(font-light))
              ,(p (G_
                   "We really appreciate it if you can book our services in advance.")
                  #:weight '(font-light))
              (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
                                               items-center my-4))))
                   ,(p (G_ "Our address:")
                       #:weight '(font-light))
                   ,(p
                     "Rua do Casino, 29 A, Carvoeiro, 8400-515 Praia do Carvoeiro"))))
    (div ,(h4 (G_ "About us - Insurance"))
         ,(em (G_
               "Proceedings from the Municipal Chamber of Lagoa E/8399/2023 date of 2023-03-13."))
         ,(p (G_
              "Civil Liability Insurance Policy No. 85/25935 Maritime Tourism €50,000.00")
             #:weight '(font-light))
         ,(p (G_ "Death or Permanent Disability €1,120,000.00")
             #:weight '(font-light))
         ,(p (G_ "Treatment and Repatriation Expenses €196,000.00")
             #:weight '(font-light)))))

(define* (carvoeiro-water-fun)
  (with-output-to-string (lambda ()
                           (sxml->xml (carvoeiro-water-fun-html-template
                                       #:title "Carvoeiro Water Fun"
                                       #:body (carvoeiro-water-fun-main-body))))))

