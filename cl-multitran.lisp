;;;; cl-multitran.lisp

(in-package #:cl-multitran)

(defparameter *languages*
  (let* ((lang-list '((en . 1)
                      (ru . 2)
                      (de . 3)
                      (fr . 4)
                      (es . 5)
                      (he . 6)
                      (ar . 10)
                      (pt . 11)
                      (pl . 14)
                      (cs . 16)
                      (zh . 17)
                      (it . 23)
                      (nl . 24)
                      (et . 26)
                      (lv . 27)
                      (ja . 28)
                      (sv . 29)
                      (nn . 30)
                      (afh . 31)
                      (tr . 32)
                      (eo . 34)
                      (xal . 35)
                      (fi . 36)
                      (el . 38)
                      (ko . 39)
                      (ka . 40)
                      (sk . 60)
                      (ab . 71)
                      (am . 81)
                      (tg . 136)
                      (ba . 193)))
         (table (make-hash-table :test #'equal :size (length lang-list))))
    (dolist (pair lang-list)
      (destructuring-bind (code . number) pair
        (setf (gethash code table) number)))
    table))

(defun default-column ()
  (string-trim '(#\newline)
               (uiop:run-program "tput cols" :output 'string)))

(defun get-word (word l1 l2 &optional (phrase nil) fill)
  (let ((lparallel:*kernel* (lparallel:make-kernel 4))
        (from (gethash (find-symbol (string-upcase l1) :cl-multitran) *languages*))
        (to (gethash (find-symbol (string-upcase l2) :cl-multitran) *languages*)))
    (format t "~A <> ~A-~A~A~%~%"
            (string-upcase word)
            (string-upcase l1)
            (string-upcase l2)
            (if phrase ": PHRASES" ""))
    (let ((data (request-word word from to phrase)))
      (prog1
          (if data
              (progn
                (mapcar #'(lambda (el)
                            (apply #'printer el `(:fill ,fill)))
                        data)
                (uiop:quit 0))
              (progn
                (format t "Nothing found.~%")
                (uiop:quit 0)))
        (lparallel:end-kernel :wait t)))))

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
    (("help" #\h) :type boolean
                  :optional t
                  :documentation "Show this help.")))

(defun help (&key (exit-code 0))
  "Show help."
  (format t "MTRAN [OPTIONS]~%~%")
  (command-line-arguments:show-option-help *command-line-spec* :sort-names t)
  (uiop:quit exit-code))

(defun arg-handler (&key word from to phrases (col (default-column)) help)
  (unless (and word from to) (help :exit-code 1))
  (when help (help :exit-code 0))
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
