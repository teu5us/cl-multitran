;;;; cl-multitran.lisp

(in-package #:cl-multitran)

(defparameter *languages*
  '(("en" . 1)
    ("ru" . 2)
    ("de" . 3)
    ("fr" . 4)
    ("es" . 5)
    ("he" . 6)
    ("ar" . 10)
    ("pt" . 11)
    ("pl" . 14)
    ("cs" . 16)
    ("zh" . 17)
    ("it" . 23)
    ("nl" . 24)
    ("et" . 26)
    ("lv" . 27)
    ("ja" . 28)
    ("sv" . 29)
    ("nn" . 30)
    ("afh" . 31)
    ("tr" . 32)
    ("eo" . 34)
    ("xal" . 35)
    ("fi" . 36)
    ("el" . 38)
    ("ko" . 39)
    ("ka" . 40)
    ("sk" . 60)
    ("ab" . 71)
    ("am" . 81)
    ("tg" . 136)
    ("ba" . 193)))

(defun default-column ()
  (string-trim '(#\newline)
               (uiop:run-program "tput cols" :output 'string)))

(defun get-word (word l1 l2 &optional (phrase nil) (fill 0))
  (let ((lparallel:*kernel* (lparallel:make-kernel 4))
        (from (cdr (assoc l1 *languages* :test #'string-equal)))
        (to (cdr (assoc l2 *languages* :test #'string-equal))))
    (format t "~A <> ~A-~A~A~%~%"
            (string-upcase word)
            (string-upcase l1)
            (string-upcase l2)
            (if phrase ": PHRASES" ""))
    (let ((data (request-word word from to phrase)))
      (prog1
          (if data
              (mapcar #'(lambda (el)
                          (apply #'printer el `(:fill ,fill)))
                      data)
              (format t "Nothing found.~%"))
        (lparallel:end-kernel :wait t)
        (uiop:quit 0)))))

(defparameter *command-line-spec*
  '((("word" #\w) :type string
                    :optional nil
                    :documentation "What to translate.")
    (("from" #\f) :type string
                  :optional nil
                  :documentation "Language to translate from.")
    (("to" #\t) :type string
                :optional nil
                :documentation "Language to translate to.")
    (("phrases" #\p) :type boolean
                     :optional t
                     :documentation "Load phrases instead of translations.")
    (("col" #\c) :type string
                 :optional t
                 :documentation "Fill-column.")
    (("langs" #\l) :type boolean
                   :optional t
                   :documentation "Print language codes and quit immediately.")
    (("help" #\h) :type boolean
                  :optional t
                  :documentation "Show this help.")))

(defun help (&key (exit-code 0))
  "Show help."
  (format t "MTRAN [OPTIONS]~%~%")
  (command-line-arguments:show-option-help *command-line-spec* :sort-names t)
  (uiop:quit exit-code))

(defun arg-handler (&key word from to phrases (col (default-column)) langs help)
  (unless (or langs (and word from to)) (help :exit-code 1))
  (when help (help :exit-code 0))
  (when langs (format t "~{~A~%~}" (mapcar #'car *languages*)) (uiop:quit 0))
  (setf *the-word* word)
  (get-word word from to phrases (parse-integer col :junk-allowed t)))

(defun main (&optional args)
  (handler-case
      (command-line-arguments:handle-command-line
       *command-line-spec*
       #'arg-handler
       :name "mtran"
       :command-line (or args (uiop:command-line-arguments))
       :rest-arity nil)
    (command-line-arguments:command-line-arity (c)
      (format t "~A~%" c)
      (uiop:quit 1))))
