;; Carvoeiro Water Fun
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; What a visitor actually receives: the document, the assets it asks for, the
;; translations each locale gets, and the hooks the motion script has to handle.
;;
;; Both pages are rendered while this file loads.  gettext keeps the locale in
;; process-global state, and veritas runs the tests of a suite concurrently, so
;; switching locale inside a test would make the suite depend on timing.

(define-module (carvoeiro-water-fun unit pages)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 textual-ports)
  #:use-module (carvoeiro-water-fun prelude)
  #:use-module (carvoeiro-water-fun html)
  #:export (document-suite asset-suite motion-suite theme-suite))

;; ====== Helpers ======

(define (page-for locale)
  "Render the page as a visitor of @var{locale} receives it."
  (setup-i18n locale)
  (carvoeiro-water-fun #:locale locale))

(define (mentions? text needle)
  "True when @var{text} contains @var{needle}."
  (if (string-contains text needle) #t #f))

(define (member? item items)
  "True when @var{item} is one of @var{items}."
  (if (member item items) #t #f))

(define (group-matches pattern group text)
  "Return group @var{group} of every match of @var{pattern} in @var{text}."
  (let ((rx (make-regexp pattern)))
    (let loop ((start 0)
               (found '()))
      (let ((match (regexp-exec rx text start)))
        (if match
            (loop (match:end match 0)
                  (cons (match:substring match group) found))
            (reverse found))))))

(define (match-count pattern text)
  "Count the matches of @var{pattern} in @var{text}."
  (length (group-matches pattern 0 text)))

(define (file-content path)
  "Return the whole of @var{path} as a string."
  (call-with-input-file path (lambda (port) (get-string-all port))))

(define (local-assets html)
  "Return the local files @var{html} loads through src or href, once each.

Routes such as @code{/pt} are links to another document, not files, and are
recognised by the absence of an extension."
  (delete-duplicates
   (group-matches "(src|href)=\"(/[^\"#?]*[.][a-z0-9]+)\"" 2 html)))

(define (resource-path url-path)
  "Where a path the page loads at run time lives in the sources."
  (string-append "resources" url-path))

(define (appears-before? html earlier later)
  "True when @var{earlier} is found before @var{later} in @var{html}."
  (let ((a (string-contains html earlier))
        (b (string-contains html later)))
    (if (and a b (< a b)) #t #f)))

;; ====== The pages and assets under test ======

(define english-page (page-for 'en_US))
(define portuguese-page (page-for 'pt_PT))
(define english-assets (local-assets english-page))
(define motion-script (file-content "resources/js/maritime.js"))

;; ====== Tests ======

(define document-suite
  (suite "the document a visitor receives"
         (test "the English page is a complete, self-describing document"
               (assert-true (mentions? english-page "<!DOCTYPE html>")
                            #:name "the doctype is present")
               (assert-true (mentions? english-page "lang=\"en\"")
                            #:name "the document is marked as English")
               (assert-true (mentions? english-page
                                        "<title>Carvoeiro Water Fun</title>")
                            #:name "the title is set")
               (assert-true (mentions? english-page "og:image")
                            #:name "the social card has an image")
               (assert-true (mentions? english-page
                                        "fun beach day in the Algarve")
                            #:name "the description is in the page"))
         (test "the Portuguese page keeps its language and translations"
               (assert-true (mentions? portuguese-page "lang=\"pt\"")
                            #:name "the document is marked as Portuguese")
               (assert-true (mentions? portuguese-page "Contacte-nos")
                            #:name "the contact heading is translated")
               (assert-true (mentions? portuguese-page
                                        "Acerca da viagem de barco")
                            #:name "the boat tour heading is translated")
               (assert-false (mentions? portuguese-page ">Contact us<")
                             #:name "the English heading is not left behind"))
         (test "the sea sits behind the content"
               (assert-true (appears-before? english-page "tide-line" "page-layer")
                            #:name "the reading line comes before the page")
               (assert-true (appears-before? english-page "sea-canvas" "page-layer")
                            #:name "the water comes before the page"))))

(define asset-suite
  (suite "the assets the page asks for"
         (test "the page loads the style sheets and the motion script"
               (assert-true (member? "/css/carvoeiro-water-fun.olive.min.css"
                                     english-assets)
                            #:name "the utility sheet is linked")
               (assert-true (member? "/css/maritime.css" english-assets)
                            #:name "the maritime layer is linked")
               (assert-true (member? "/js/maritime.js" english-assets)
                            #:name "the motion script is linked"))
         (test "the maritime layer is applied after the utilities it builds on"
               (assert-true (appears-before? english-page
                                             "carvoeiro-water-fun.olive.min.css"
                                             "/css/maritime.css")
                            #:name "maritime.css wins the cascade"))
         (test "every local asset the page references exists"
               (assert-true (pair? english-assets)
                            #:name "the page references local assets")
               (for-each (lambda (path)
                           (assert-true (file-exists? (resource-path path))
                                        #:name (string-append (resource-path path)
                                                              " exists")))
                         english-assets))
         (test "every photograph is lazily loaded and marked decorative"
               (let ((images (group-matches "<img[^>]*>" 0 english-page)))
                 (assert-true (pair? images)
                              #:name "the page has photographs")
                 (for-each (lambda (image)
                             (assert-true (mentions? image "loading=\"lazy\"")
                                          #:name "the photograph is lazy")
                             (assert-true (mentions? image "alt=")
                                          #:name "the photograph declares alt"))
                           images)))))

(define theme-suite
  (suite "the sea theme"
         (test "dolphins, the boat and the caves are on the page"
               (assert-true (mentions? english-page "FB_IMG_1719434007758.jpg")
                            #:name "a dolphin leaps in the gallery")
               (assert-true (mentions? english-page "FB_IMG_1719434096367.jpg")
                            #:name "a dolphin rides at the bow")
               (assert-true (mentions? english-page "FB_IMG_1719434138555.jpg")
                            #:name "the boat waits in the harbour")
               (assert-true (mentions? english-page "FB_IMG_1719434180086.jpg")
                            #:name "a cave is lit from above")
               (assert-true (mentions? english-page "FB_IMG_1719434196131.jpg")
                            #:name "the grotto is framed"))
         (test "the cave drifts as the page is read"
               (assert-true (mentions? english-page "data-parallax")
                            #:name "the grotto asks for a parallax layer"))
         (test "the cards carry their icon coins"
               (assert-true (>= (match-count "medallion" english-page) 6)
                            #:name "each card head has a medallion"))))

(define motion-suite
  (suite "the motion layer"
         (test "every motion hook in the page is handled by the script"
               (let ((hooks (delete-duplicates
                             (map (lambda (name)
                                    (string-append "data-" name))
                                  (group-matches "data-([a-z-]+)=" 1 english-page)))))
                 (assert-true (pair? hooks)
                              #:name "the page carries motion hooks")
                 (for-each (lambda (hook)
                             (assert-true (mentions? motion-script hook)
                                          #:name (string-append "the script handles "
                                                                hook)))
                           hooks)))
         (test "the reveal can always be undone"
               (assert-true (>= (match-count "data-reveal" english-page) 4)
                            #:name "several sections reveal on scroll")
               (assert-true (mentions? english-page "<noscript>")
                            #:name "a no-script fallback is present"))))
