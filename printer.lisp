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

(defun print-translation-pair (translation-pair &key (stream t))
  (format stream "~/cl-multitran::print-pair/" translation-pair))

(defun print-pair (stream pair columnp atsignp)
  (format stream "~2T- ~A :: ~A~%~^~%"
          (car pair)
          (cadr pair)))

(defun print-phrases-entry (entry &key (stream t))
  (destructuring-bind (section pairs) entry
    ;; (format stream "~A~%~A~%~{~/cl-multitran::print-pair/~}~%"
    ;;         section
    ;;         (make-string (length section)
    ;;                      :initial-element #\-)
    ;;         pairs)
    (format stream "* ~A~%~{~/cl-multitran::print-pair/~}~%"
            section
            pairs)))
