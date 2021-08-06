#lang racket/base

(module+ reader
  (provide (rename-out [read-jsond-syntax read-syntax]))

  (require json
           syntax/strip-context)

  (define (read-jsond-syntax src in)
    (define-values (names jsons)
      (let loop ([names '()]
                 [jsons '()])
        (define maybe-kw (read-syntax src in))
        (cond
          [(eof-object? maybe-kw) (values (reverse names) (reverse jsons))]
          [(eq? (syntax->datum maybe-kw) '#:name)
           (define maybe-name (read-syntax src in))
           (cond
             [(eof-object? maybe-name) (raise-syntax-error 'jsond "expected name before eof" maybe-name)]
             [(symbol? (syntax->datum maybe-name))
              (loop (cons maybe-name names)
                    (cons `',(read-json in) jsons))]
             [else (raise-syntax-error 'jsond "expected name" maybe-name)])]
          [else (raise-syntax-error 'jsond "expected keyword #:name" maybe-kw)])))
    (strip-context
      #`(module jsond-module racket/base
          (provide #,@names)
          (define-values #,names (values #,@jsons))

          (module+ main
            (require json)
            (write-json
              (make-hash (list #,@(for/list ([name names])
                                    `(cons ',name ,name)))))
            (newline))))))