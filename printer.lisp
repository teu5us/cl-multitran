;;;; printer.lisp

(in-package #:cl-multitran)

(defun print-translation (translation &key (stream t))
  (destructuring-bind (subj trans) translation
    ;; (format stream "~A~%~A~%~4T~A~%~%"
    ;;         subj
    ;;         (make-string (length subj)
    ;;                      :initial-element #\-)
    ;;         trans)
    (format stream "* ~A~%~2T~A~%~%"
            subj
            trans)))

(defun print-translation-pair (translation-pair &key (stream t) (fill 0))
  (format stream (format nil "~~~A/cl-multitran::print-pair/" fill) translation-pair))

(defun print-pair (stream pair columnp atsignp smt)
  (format stream
          (cfs:fill-string
           (format nil "~2T- ~A :: ~A~%~^~%"
                   (car pair)
                   (cadr pair)) smt)))

(defun print-phrases-entry (entry &key (stream t) (fill 0))
  (destructuring-bind (section pairs) entry
    ;; (format stream "~A~%~A~%~{~/cl-multitran::print-pair/~}~%"
    ;;         section
    ;;         (make-string (length section)
    ;;                      :initial-element #\-)
    ;;         pairs)
    (format stream (format nil "* ~~A~~%~~{~~~A/cl-multitran::print-pair/~~}~~%" fill)
            section
            pairs)))
