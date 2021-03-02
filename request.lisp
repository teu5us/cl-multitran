;;;; request.lisp

(in-package #:cl-multitran)

(defun load-page (string)
  (multiple-value-bind (response result)
      (dex:get string)
    (when (eql result 200)
      response)))

(defun fix-link (query)
  (format nil "https://multitran.com~A" query))

(defun get-trs (html-string)
  (let ((root (parse html-string)))
    (coerce (lquery:$ root "tr") 'list)))

(defun create-word-request (word l1 l2)
  (format nil "https://www.multitran.com/m.exe?s=~A&l1=~A&l2=~A"
          (urlencode:urlencode word) l1 l2))

(defmacro extract-from-table (class1 class2)
  `#'(lambda (trs)
       (lparallel:pmapcar #'(lambda (c1 c2)
                              (list (aref (lquery:$ c1 (text)) 0)
                                    (aref (lquery:$ c2 (text)) 0)))
                          :parts 8
                          (coerce (lquery:$ trs ,class1) 'list)
                          (coerce (lquery:$ trs ,class2) 'list))))

(defun translations (trs)
  (funcall (extract-from-table ".subj" ".trans") trs))

(defun phrases-internal (trs)
  (funcall (extract-from-table ".phraselist1" ".phraselist2") trs))

(defun phrases (trs)
  (lparallel:pmapcar #'(lambda (category)
                         (list (car category)
                               (cdr
                                (funcall #'phrases-internal
                                         (get-trs (dex:get (fix-link (cadr category))))))))
                     :parts 8
                     (coerce
                      (lquery:$ trs ".phras a" (combine (text) (attr :href)))
                      'list)))

(defun request-word (word l1 l2 &optional (phrases nil))
  (let ((page (load-page (create-word-request word l1 l2)))
        (filter (if phrases #'phrases #'translations)))
    (if page
        (funcall filter (get-trs page))
        (progn
          (format t "Word not found or there was an error.")
          (uiop:quit 1)))))
