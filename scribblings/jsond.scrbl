#lang scribble/manual
@(require (for-label jsond
                     racket/base
                     json)
          scribble/examples
          scribble/bnf
          syntax/modresolve
          racket/file)

@title{jsond}
@author{D. Ben Knoble}

@(define my-eval (make-base-eval))
@(examples #:eval my-eval
           #:hidden
           (require jsond/examples/data
                    jsond/examples/lisp))

@defmodulelang[jsond]

This package provides a convienient format to embed JSON data in racket programs
by making the JSON data (surprise!) racket programs.

@section{Quick Start}

Suppose, for example, we had some JSON data consisting of a list of albums and
singles.

@verbatim{
["Cycles", "Flatspin", "Long Way to Climb"]
}

We also have a map of user favorites (each value is an index in the albums array).

@verbatim{
{
    "Jonathan Gordon": 0,
    "Brad Rubinstein": 2,
    "Paul Willmott": 1,
    "Jason Hall": 0,
    "Adam Rich": 1
}
}

Normally, we would need to @racket[require] the @racket[json] library and use
@racket[read-json] to read these data files. With @racket[jsond], however,
we can make the files into a program:

@codeblock{
#lang jsond

#:name albums
["Cycles", "Flatspin", "Long Way to Climb"]

#:name favorites
{
    "Jonathan Gordon": 0,
    "Brad Rubinstein": 2,
    "Paul Willmott": 1,
    "Jason Hall": 0,
    "Adam Rich": 1
}
}

If we put this in a file @code{lisp.rkt}, we suddenly have a program!

@examples[#:eval my-eval
          @eval:alts[(require "lisp.rkt") (void)]
          albums
          favorites
          (for/hash ([(member fav-id) (in-hash favorites)])
            (values member (list-ref albums fav-id)))]

The program can also be run to recover the original JSON. The following racket
code is equivalent to running a command-line

@verbatim{
# racket lisp.rkt
}

@examples[#:eval my-eval
          @eval:alts[(require (submod "lisp.rkt" main))
                     (require (submod jsond/examples/lisp main))]]

The @racket[jsond] language supports all of the JSON specification in JSON
values, as well as regular racket comments between value definitions:

@(typeset-code (file->string (resolve-module-path 'jsond/examples/data))
               #:context #'here)

@examples[#:eval my-eval
          (require jsond/examples/data)
          abc
          num
          array]

@section{Syntax}

@BNF[(list @nonterm{jsond}
           @kleenestar[@nonterm{name-json}])
     (list @nonterm{name-json}
           @BNF-seq[@racket[#:name]
                    @nonterm{id}
                    @nonterm{json}])]

There may be any style of racket comment between @nonterm{name-json}s. Each use
of @racket[#:name], @nonterm{id}, and @nonterm{json} must be
whitespace-separated. @nonterm{json} can be any valid JSON value as determined
by @racket[read-json]. @nonterm{id} can be any valid Racket identifier.

@section{Semantics}

The @racket[jsond] language produces a module that @racket[provide]s each of the
@nonterm{id}s as a binding to the @racket[jsexpr?] corresponding to the adjacent
@nonterm{json}.

The module has a submodule @code{main} that, when run, calls @racket[write-json]
on a @racket[hash] mapping each @racket[provide]d @nonterm{id} to its value.
