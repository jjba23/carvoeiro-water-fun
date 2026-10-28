;; Carvoeiro Water Fun
;;
;; SPDX-LICENSE-IDENTIFIER: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; The motion layer is two hand-written files that have to agree with
;; themselves before they can agree with the page: every animation needs its
;; keyframes, every keyframe needs a use, and the decoration must have a way to
;; switch itself off.  These checks read the files, not a browser.

(define-module (carvoeiro-water-fun unit structure)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 textual-ports)
  #:export (stylesheet-suite script-suite))

;; ====== Helpers ======

(define (file-content path)
  "Return the whole of @var{path} as a string."
  (call-with-input-file path (lambda (port) (get-string-all port))))

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

(define (char-count char text)
  "How often @var{char} occurs in @var{text}."
  (string-count text char))

(define stylesheet (file-content "resources/css/maritime.css"))
(define script (file-content "resources/js/maritime.js"))

(define (animation-names sheet)
  "The keyframe names the sheet animates with, without the special values."
  (remove (lambda (name)
            (member name '("none" "initial" "inherit")))
          (delete-duplicates
           (group-matches "animation:[[:space:]]*([a-z][a-z-]*)" 1 sheet))))

(define (keyframe-names sheet)
  "The keyframe sets the sheet defines."
  (delete-duplicates (group-matches "@keyframes[[:space:]]+([a-z][a-z-]*)"
                                    1 sheet)))

;; ====== Tests ======

(define stylesheet-suite
  (suite "the maritime stylesheet"
         (test "the rules are balanced"
               (assert-equal #:expect (char-count #\{ stylesheet)
                             #:got (char-count #\} stylesheet)
                             #:name "every block is closed"))
         (test "the frosted glass is really frosted"
               (assert-true (mentions? stylesheet "backdrop-filter")
                            #:name "a backdrop filter is used")
               (assert-true (mentions? stylesheet "-webkit-backdrop-filter")
                            #:name "the prefixed filter is used too")
               (assert-true (mentions? stylesheet ".glass")
                            #:name "the glass panel is defined"))
         (test "the finish that carries the expensive look is defined"
               (for-each (lambda (class)
                           (assert-true (mentions? stylesheet class)
                                        #:name (string-append class
                                                              " is defined")))
                         '(".photo-frame" ".gold-rule" ".spec-list" ".shimmer"
                           ".footer-glass" ".carousel-glass" ".hero-title-row")))
         (test "every animation has keyframes"
               (for-each (lambda (name)
                           (assert-true (member? name (keyframe-names stylesheet))
                                        #:name (string-append name
                                                              " has keyframes")))
                         (animation-names stylesheet)))
         (test "every keyframe is used"
               (for-each (lambda (name)
                           (assert-true (member? name (animation-names stylesheet))
                                        #:name (string-append name " is animated")))
                         (keyframe-names stylesheet)))
         (test "the decoration can be switched off"
               (assert-true (mentions? stylesheet "prefers-reduced-motion")
                            #:name "reduced motion is honoured")
               (assert-true (mentions? stylesheet ".js [data-reveal]")
                            #:name "reveals are hidden only when the script runs")
               (assert-true (mentions? stylesheet
                                        "@supports not ((-webkit-backdrop-filter")
                            #:name "glass has a fallback"))))

(define script-suite
  (suite "the motion script"
         (test "the blocks are balanced"
               (assert-equal #:expect (char-count #\{ script)
                             #:got (char-count #\} script)
                             #:name "every block is closed"))
         (test "the behaviours the page relies on are implemented"
               (for-each (lambda (behaviour)
                           (assert-true (mentions? script behaviour)
                                        #:name (string-append behaviour
                                                              " is present")))
                         '("data-reveal" "data-tilt" "tide-line__fill"
                           "IntersectionObserver" "requestAnimationFrame"
                           "matchMedia")))
         (test "the script stays defensive"
               (assert-true (mentions? script "prefers-reduced-motion")
                            #:name "reduced motion is read")
               (assert-false (mentions? script "innerHTML")
                             #:name "nothing is written as raw HTML")
               (assert-false (mentions? script "eval(")
                             #:name "nothing is evaluated"))))
