#lang info
(define collection "jsond")
(define deps '("base"))
(define build-deps '("scribble-lib" "racket-doc"))
(define scribblings '(("scribblings/jsond.scrbl" ())))
(define pkg-desc "A #lang for json data")
(define version "0.1")
(define pkg-authors '(benknoble))
(define compile-omit-paths '("examples"))
