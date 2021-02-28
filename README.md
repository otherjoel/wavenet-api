# Wavenet API

A Racket interface for the [Google Cloud text-to-speech API][tts].

[tts]: https://cloud.google.com/text-to-speech

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

(define british-dude
  #hasheq((languageCodes . ("en-GB"))
         (name . "en-GB-Wavenet-B")
         (naturalSampleRateHertz . 24000)
         (ssmlGender . "MALE")))

(define (say text)
  (synthesize text british-dude #:output-file "temp.mp3")
  (play-sound "temp.mp3" #t))
```
