;;;; package.lisp

(defpackage #:cl-multitran
  (:nicknames #:mtran)
  (:use #:cl #:plump #:split-sequence)
  (:export
   #:main
   #:*languages*))
