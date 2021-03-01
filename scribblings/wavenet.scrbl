#lang scribble/manual
@require[@for-label[wavenet
                    hash-view
                    json
                    racket/base
                    racket/file
                    racket/gui/base]]

@require[wavenet scribble/example]

@define[examps (make-base-eval)]

@title{Wavenet TTS API Interface}
@author[(author+email "Joel Dueck" "joel@jdueck.net" #:obfuscate? #t)]

@defmodule[wavenet]

A Racket interface for @hyperlink["https://cloud.google.com/text-to-speech"]{Google’s Wavenet
text-to-speech engine}.

The functions in this module make HTTP requests to a Google Cloud API (see @racket[endpoint]). You
will need a valid API key from Google in order to make use of this package.

The source code is @hyperlink["https://github.com/otherjoel/wavenet-api"]{on Github} and licensed
under the @hyperlink["https://github.com/otherjoel/wavenet-api/blob/main/LICENSE.md"]{Blue Oak Model
License 1.0.0}.

Here’s an example program:

@codeblock{
#lang racket

(require wavenet
         racket/gui/base)

(api-key (file->string "api.rktd"))

;; One way to pick a voice. (Use voice-names to list available voices.)
(define eliza (select-voice "en-GB-Wavenet-F (FEMALE)"))

;; Another way to pick a voice. Statically defining a voice allows us to avoid
;; an extra API call to fetch voices every time the program is run. But you
;; can’t just make up your own values!
(define british-dude
  #hasheq((languageCodes . ("en-GB"))
         (name . "en-GB-Wavenet-B")
         (naturalSampleRateHertz . 24000)
         (ssmlGender . "MALE")))

;; Turn your sound up and call this function!
(define (say text)
  (synthesize text british-dude #:output-file "temp.mp3")
  (play-sound "temp.mp3" #t))
}

@defparam[api-key key-string string? #:value #f]{

A parameter for your Google Cloud API key. You must set this before calling @racket[voice-names],
@racket[select-voice] or @racket[synthesize], or an exception will be raised.

You should store this key in a separate file and make sure to exclude that file from Git (or
whatever version control system you use). Then you can load it up at runtime:

@codeblock{
(api-key (file->string "api.rktd"))
}

}

@defparam[endpoint uri string? #:value #,(endpoint)]{

A parameter holding the URL to use for API calls. You can change it if you wish to use a different
version of the API.

}

@defproc[(voice-names [prefix string? ""]) (listof string?)]{

Returns a list of names of voices available for you to use.

If @racket[_prefix] is provided, only names that begin with @racket[_prefix] will be included in
that list. Voice names have a standard format — for example, @racket{en-AU-Wavenet-A (FEMALE)}, so
@racket[_prefix] is good for narrowing the list to particular languages, or language/engine
combinations.

Each time your program is run, the first call to either @racket[voice-names] or
@racket[select-voice] will generate an API call to @racket[endpoint] to fetch information about
voices currently available from Google Cloud. If @racket[api-key] is not set, or if the HTTP
response code is anything other than @racket[200], an @racket[exn:fail:user] exception is raised.
Subsequent calls to these two functions will refer to a local cache of this information instead of
making another API call.

}

@defproc[(select-voice [voice-name string?]) voice?]{

Returns the @racket[voice] identified by the @racket[_voice-name] argument; this argument must
match one of the names returned by @racket[voice-names].

Each time your program is run, the first call to either @racket[voice-names] or
@racket[select-voice] will generate an API call to @racket[endpoint] to fetch information about
voices currently available from Google Cloud. If @racket[api-key] is not set, or if the HTTP
response code is anything other than @racket[200], an @racket[exn:fail:user] exception is raised.
Subsequent calls to these two functions will refer to a local cache of this information instead of
making another API call.

}

@defproc[(synthesize [text string?] [voice-or-name (or/c voice? string?)]
                     [#:output-file filename (or/c #f path-string?) #f])
         (or/c bytes? integer?)]{

Makes an API request to @racket[endpoint] to synthesize @racket[_text] into MP3 audio using
@racket[_voice-or-name], which must either be a @racket[voice] or a string matching one of the names
returned by @racket[voice-names]. Also note that the API specifies a limit to the length of
@racket[_text]; as of current writing the limit is 5,000 characters per request.

If @racket[api-key] is not set, or if the HTTP response code is anything other than @racket[200], an
@racket[exn:fail:user] exception is raised.

If @racket[#:output-file] is specified, the bytes of the MP3 audio are saved to that file, silently
overwriting it if it exists already, and the return value is the number of bytes written out.
Otherwise the MP3 audio bytes are themselves returned.

}

@defstruct*[voice ([languageCodes (listof string?)]
                   [name string?]
                   [naturalSampleRateHertz integer?]
                   [ssmlGender string?])]{

A struct-like type containing information about a single voice available for speech synthensis. In
reality @racket[voice] is a @racket[hash-view], i.e. a @racket[hash] that can be accessed with
struct-like accessor functions. Because it is a hash table, it can be easily marshaled to and from a
JSON representation of the same data.

@examples[#:eval examps
(require wavenet json)
(define british-dude (voice '("en-GB") "en-GB-Wavenet-B" 24000 "MALE"))
british-dude
(hash-ref british-dude 'name)
(voice-name british-dude)
(display (jsexpr->string british-dude))

]

}
