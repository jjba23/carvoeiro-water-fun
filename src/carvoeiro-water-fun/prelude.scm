;;; Carvoeiro Water Fun

;; Copyright © Josep Jesus Bigorra Algaba

;; carvoeiro-water-fun is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; carvoeiro-water-fun is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with carvoeiro-water-fun. If not, see <https://www.gnu.org/licenses/>.

(define-module (carvoeiro-water-fun prelude)
  #:declarative? #t
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 regex)
  #:export (setup-i18n
            G_
                        mk-class
                        syscall
                        log-message
                        log
                        log-info
                        log-error))

(define (G_ msg)
  (gettext msg))

(define (setup-i18n locale)
  (catch #t
         (lambda ()
           (setlocale LC_MESSAGES (format #f "~a.UTF-8" locale))
           (bindtextdomain "carvoeiro-water-fun" "./resources/locale")
           (textdomain "carvoeiro-water-fun"))
         (lambda (key . args)
           (display (format #f "error setting i18n up: ~a: ~a" key args)))))

;; mk-class: Convert a list of symbols into a CSS `class` attribute pair.
;;
;; This function takes a list of symbols representing CSS class names and
;; returns an S-expression `(class "class-names")`. The class names are
;; space-separated in a string. If the input is an empty list or `#f`,
;; it returns `(class "")`, ensuring that an empty class attribute is still valid.
;;
;; Examples:
;; (mk-class '())                       ⇒ ""
;; (mk-class '(p-2 bg-stone-900/75))    ⇒ "bg-stone-900/75 p-2 "
;; (mk-class #f)                        ⇒ ""
;;
(define* (mk-class xs)
  (cond
    ((nil? xs)
     "")
    (else (string-join (sort (map symbol->string
                                  (delete-duplicates xs)) string<?) " "))))

(define (syscall cmd)
  (let* ((process (open-input-pipe cmd))
         (process-output (get-string-all process)))
    (close-pipe process) process-output))

(define preferred-strftime-format
  (make-parameter "%Y-%m-%d %H:%M:%S%z"))

(define (log-message msg)
  (display (format #f "\n\x1b[1m~a\x1b[0m" msg)))

(define (log msg . args)
  (log-message (apply format
                      (append (list #f msg) args))))

(define (log-info msg . args)
  (log-message (format #f "[INFO][~a] ~a"
                       (strftime (preferred-strftime-format)
                                 (localtime (current-time)))
                       (apply format
                              (append (list #f msg) args)))))

(define (log-error msg . args)
  (log-message (format #f "[ERROR][~a] ~a"
                       (strftime (preferred-strftime-format)
                                 (localtime (current-time)))
                       (apply format
                              (append (list #f msg) args)))))
