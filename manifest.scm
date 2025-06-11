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
    (version "0.5.9")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/jjba23/hygguile.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "01xixcay0qsbkmd47j46ky6cqn278ayb78sdf2cgq5fn3rbgigsc"))))
    (build-system guile-build-system)
    (native-inputs (list guile-3.0))
    (arguments
     (list
      #:source-directory "src"))
    (home-page "https://codeberg.org/jjba23/hygguile")
    (synopsis "Web UI component library for Guile Scheme projects")
    (description
     "Hygguile is a library that allows you to create cozy web user-interfaces
using Guile Scheme, by defining an expressive domain-specific language (DSL),
and by leveraging the power of S-expressions, SXML and TailwindCSS.

The project aims to provide reusable, professional-looking and accessible
web components, whose names resemble the HTML counterparts, thus
easing the learning curve, and reducing the cognitive load.")
    (license license:lgpl3+)))

(define-public guile-kracht
  (package
   (name "guile-kracht")
   (version "0.1.2")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://codeberg.org/jjba23/kracht.git")
           (commit (string-append "v" version))))
     (file-name (git-file-name name version))
     (sha256
      (base32 "08pgkj111sjwlkv3q30zqhrz2zxis06iknmb09qkmf3vh9ww1d73"))))
   (build-system guile-build-system)
   (native-inputs (list guile-3.0))
   (arguments
    (list
     #:source-directory "src"))
   (home-page "https://codeberg.org/jjba23/kracht")
   (synopsis
    "Good prelude for Guile Scheme, an opt-in enhancement to the standard library")
   (description
    "Good prelude for Guile Scheme, an opt-in enhancement to the standard library. kracht means power/strength in the Dutch language, and is also a recursive acronym which stands for: KRACHT Reliable And Consistent Helper Tools")
   (license license:lgpl3+)))

(packages->manifest (list (specification->package "make") guile-next darkhttpd
                          guile-ares-rs guile-hygguile
                          guile-kracht))

