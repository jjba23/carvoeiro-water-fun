;; Carvoeiro Water Fun
;;
;; SPDX-LICENSE-IDENTIFIER: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; Entry point of the test suite.  One veritas run over every suite keeps the
;; report and the exit status in one place: a failing assertion exits 1, which
;; is what a CI job reads, and a passing one prints the tally below.

(use-modules (veritas veritas)
             ((carvoeiro-water-fun unit serializer)
              #:select (serializer-suite))
             ((carvoeiro-water-fun unit pages)
              #:select (document-suite asset-suite motion-suite))
             ((carvoeiro-water-fun unit structure)
              #:select (stylesheet-suite script-suite)))

(veritas-run #:debug? #f
             document-suite
             asset-suite
             motion-suite
             stylesheet-suite
             script-suite
             serializer-suite)

(display "\nCarvoeiro Water Fun: all checks passed\n")
