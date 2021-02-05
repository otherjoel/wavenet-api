# Wavenet API

A Racket interface for Google’s Cloud text-to-speech engine.

Documentation to come. You need:

* An API key

This package is not currently on the Racket package server. To install it, clone this repo and do
`cd parent-folder; raco pkg install ./wavenet`.

Here’s a quick sample:

```racket
#lang racket

(require wavenet
         racket/gui/base)

(api-key (file->string "api.rktd"))

(define (save-bytes bstr filename)
  (with-output-to-file filename
    (lambda () (write-bytes bstr))
    #:exists 'replace))

(define british-dude
  #hasheq((languageCodes . ("en-GB"))
         (name . "en-GB-Wavenet-B")
         (naturalSampleRateHertz . 24000)
         (ssmlGender . "MALE")))

(define (say text)
  (save-bytes (synthesize text british-dude) "temp.mp3")
  (play-sound "temp.mp3" #t))
```
