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

(use-modules (guix packages)
             (gnu)
             (guix utils)
             (guix git-download)
             (guix download)
             (gnu packages guile)
             (gnu packages nss)
             (gnu packages web)
             (gnu packages gnupg)
             (gnu packages guile-xyz)
             (gnu packages pkg-config)
             (guix build-system guile)
             (gnu packages linux)
             (gnu packages compression)
             (gnu packages texinfo)
             (gnu packages autotools)
             ((guix licenses)
              #:prefix license:))

(define-public guile-hygguile
  (package
    (name "guile-hygguile")
    (version "0.5.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/hygguile.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0mjcjmd2hi0009lpniacqmqgyl9wgm447dsfcpz4bljjiy6hi6pn"))))
    (build-system guile-build-system)
    (native-inputs (list guile-3.0))
    (arguments
     (list
      #:source-directory "src"))
    (home-page "https://codeberg.org/jjba23/hygguile")
    (synopsis
     "SXML and TailwindCSS UI component library for Lisp (Guile Scheme) software projects")
    (description
     "Cozy and professional user-interfaces for everyone.
        SXML and TailwindCSS UI component library for Lisp (Guile Scheme) software projects.
        hygge + guile = hygguile")
    (license license:lgpl3+)))

(packages->manifest (list (specification->package "make") guile-next darkhttpd
                          guile-ares-rs guile-hygguile))

