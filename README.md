# Wavenet API

A Racket interface for the [Google Cloud text-to-speech API][tts].

[Complete documentation is available][docs]. 

[tts]: https://cloud.google.com/text-to-speech
[docs]: https://joeldueck.com/what-about/wavenet-api

Here’s a quick example program:

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

## Installation 

To make use of this package, you need a Google Cloud API key.

To install from within DrRacket, click *File* → *Install Package*, type `wavenet` into the
box and click *Install*. 

To install from the command line, run `raco pkg install wavenet`.
