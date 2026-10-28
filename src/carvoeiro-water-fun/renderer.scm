;; Carvoeiro Water Fun
;;
;; SPDX-LICENSE-IDENTIFIER: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (carvoeiro-water-fun renderer)
  #:declarative? #f
  #:use-module (carvoeiro-water-fun html)
  #:use-module (carvoeiro-water-fun prelude)
  #:use-module (kracht prelude)
  #:export (render-page))

(define* (render-page #:key locale output-dir resources-dir)
  (setup-i18n locale)
  (log-info "Start rendering with settings:")
  (log-info "\tlocale: ~a" locale)
  (log-info "\tresources-dir: ~a" resources-dir)
  (log-info "\toutput-dir: ~a" output-dir)

  (let* ((cp-to-dist-cmds (list (format #f "cp -rfv ~a/css ~a/css"
                                        resources-dir output-dir)
                                (format #f "cp -rfv ~a/js ~a/js"
                                        resources-dir output-dir)
                                (format #f "cp -rfv ~a/img ~a/img"
                                        resources-dir output-dir))))

    (map (lambda (c)
           (log-info "executing: ~a" c)
           (syscall c)) cp-to-dist-cmds)

    (with-output-to-file (format #f "~a/index.html" output-dir)
      (lambda ()
        (display (carvoeiro-water-fun #:locale locale))))
    (log-info "Completed rendering of page")))
