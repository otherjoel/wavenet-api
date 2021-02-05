#lang info
(define collection "wavenet")
(define deps '("base" "hash-view-lib" "http-easy"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/wavenet.scrbl" ())))
(define pkg-desc "Racket interface for Google’s Wavenet Cloud text-to-speech API")
(define version "0.0")
(define pkg-authors '(joel))
