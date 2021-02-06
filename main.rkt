#lang racket/base

(require hash-view
         net/base64
         net/http-easy
         racket/contract
         racket/string)

(define api-key (make-parameter #f))
(define (api-key/uri-param) (cons 'key (api-key)))

(define endpoint (make-parameter "https://texttospeech.googleapis.com/v1/"))

(provide api-key
         api-key/uri-param
         endpoint
         voice-names
         select-voice
         synthesize
         (hash-view-out voice))

(hash-view voice (languageCodes name naturalSampleRateHertz ssmlGender))

;; (Private) Appends `resource` onto `endpoint` and GETs response, checking for errors
(define (get/check resource)
  (unless (api-key) (error 'get/check "API key not set"))
  (define res (get (string-append (endpoint) resource)
                   #:params (list (api-key/uri-param))))
  (define res-code (response-status-code res))
  (cond
    [(not (equal? 200 res-code))
     (raise-user-error (string->symbol resource) "HTTP response was ~a!" res-code)]
    [else (response-json res)]))

;; (Private) Cache the list of voices
(define voices-cache (make-parameter null))

;; (Private) Returns the list of available voices, caching to avoid repeat requests
(define (voices)
  (unless (not (equal? null (voices-cache)))
    (unless (api-key) (error 'get/check "API key not set"))
    (voices-cache
     (for/hash ([v (in-list (hash-ref (get/check "voices") 'voices))])
       (values (format "~a (~a)" (voice-name v) (voice-ssmlGender v))
               v))))
  (voices-cache))

;; Return a list of voice names (strings)
(define/contract (voice-names [lang ""])
  (->* () (string?) (listof string?))
  (let ([vnames (sort (hash-keys (voices)) string<?)])
    (if (not (equal? lang ""))
        (filter (lambda (s) (string-prefix? s lang)) vnames)
        vnames)))

;; Return a voice from the voice list
(define/contract (select-voice name)
  (-> string? voice?)
  (hash-ref (voices) name))

;; Returns the raw mp3 audio bytes from the Text-to-Speech API
;; NOTE: If you use a string for the voice argument and (voices) has not yet been called, there
;; will be an extra network request
(define/contract (synthesize text voice-or-name)
  (-> string (or/c voice? string?) bytes?)
  (unless (api-key) (error 'get/check "API key not set"))
  (let* ([synth-voice (if (voice? voice-or-name) voice-or-name (select-voice voice-or-name))]
         [api-voice (hash-remove synth-voice 'naturalSampleRateHertz)]
         [lang-code (car (hash-ref api-voice 'languageCodes))]
         [api-voice (hash-set api-voice 'languageCode lang-code)]
         [api-voice (hash-remove api-voice 'languageCodes)]
         [req-json  (hash 'input (hash 'ssml text)
                          'voice api-voice
                          'audioConfig (hash 'audioEncoding "MP3"))]
         [res (response-json (post (format "~atext:synthesize?key=~a" (endpoint) (api-key))
                              #:json req-json))]
         [audio-str (hash-ref res 'audioContent)]
         [audio-b64 (string->bytes/utf-8 audio-str)])
    (base64-decode audio-b64)))
