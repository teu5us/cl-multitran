;;;; printer.lisp

(in-package #:cl-multitran)

(defun print-pair (stream pair columnp atsignp smt)
  (format stream "~A"
          (cfs:fill-string
           (format nil "~2T- ~A :: ~A~%~^~%"
                   (car pair)
                   (cadr pair)) smt)))

(defun print-translation-pair (translation-pair &key (stream t) (fill 0))
  (format stream (format nil "~~~A/cl-multitran::print-pair/" fill) translation-pair))

(defun printer (entry &key (stream t) (fill 0))
  (destructuring-bind (section pairs) entry
    (format stream (format nil "* ~~A~~%~~{~~~A/cl-multitran::print-pair/~~}~~%" fill)
            section
            pairs)))
