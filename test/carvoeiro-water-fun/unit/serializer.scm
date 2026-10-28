;; Carvoeiro Water Fun
;;
;; SPDX-LICENSE-IDENTIFIER: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; The page is built by walking SXML, so the serializer decides whether the
;; markup a browser receives is well formed.  Three behaviours matter here:
;; an element without children must not close itself (HTML treats <div /> as an
;; opening tag), attributes must escape their ampersands, and text must survive
;; untouched unless escaping is asked for.

(define-module (carvoeiro-water-fun unit serializer)
  #:use-module (veritas veritas)
  #:use-module (ice-9 textual-ports)
  #:use-module (carvoeiro-water-fun sxml)
  #:export (serializer-suite))

(define (serialize tree)
  "Write @var{tree} as XML and return it as a string."
  (call-with-output-string (lambda (port) (sxml->xml tree port))))

(define (serialize-escaped tree)
  "Write @var{tree} as XML with text nodes escaped."
  (call-with-output-string (lambda (port) (sxml->xml tree port #t))))

(define serializer-suite
  (suite "the SXML serializer"
         (test "an element without children is closed, not self-closed"
               (assert-equal #:expect "<div class=\"rule\"></div>"
                             #:got (serialize '(div (@ (class "rule")) ""))
                             #:name "an empty rule div keeps its closing tag")
               (assert-equal #:expect "<img src=\"/img/a.jpg\" />"
                             #:got (serialize '(img (@ (src "/img/a.jpg"))))
                             #:name "void elements still self-close"))
         (test "attributes escape what would end the attribute"
               (assert-equal #:expect "<a href=\"https://example.org/?a=1&amp;b=2\">x</a>"
                             #:got (serialize
                                    '(a (@ (href "https://example.org/?a=1&b=2"))
                                        "x"))
                             #:name "an ampersand in a URL is escaped")
               (assert-equal #:expect "<p title=\"a &quot;b&quot;\">x</p>"
                             #:got (serialize '(p (@ (title "a \"b\"")) "x"))
                             #:name "a quote in an attribute is escaped"))
         (test "text is escaped only when asked"
               (assert-equal #:expect "<p>a < b</p>"
                             #:got (serialize '(p "a < b"))
                             #:name "text is passed through by default")
               (assert-equal #:expect "<p>a &lt; b &amp; c</p>"
                             #:got (serialize-escaped '(p "a < b & c"))
                             #:name "escaping is available when wanted"))
         (test "conditional fragments disappear instead of printing"
               (assert-equal #:expect "<p>a</p><p>b</p>"
                             #:got (serialize (list '(p "a") #f '(p "b") '()))
                             #:name "false and empty fragments are skipped"))
         (test "non-ASCII content is preserved"
               (assert-equal #:expect "<p>⚓ Carvoeiro · Benagil</p>"
                             #:got (serialize '(p "⚓ Carvoeiro · Benagil"))
                             #:name "the acorn and the accents survive"))))

