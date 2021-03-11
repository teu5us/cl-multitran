;;;; request.lisp

(in-package #:cl-multitran)

(defparameter *the-word* nil)

(defun load-page (string)
  (multiple-value-bind (response result)
      (handler-case (dex:get string)
        (dexador.error:http-request-bad-gateway (c)
          (format t "Got 502 \"Bad gateway\".~%" c)
          (lparallel:end-kernel :wait nil)
          (uiop:quit 1)))
    (when (eql result 200)
      response)))

(defun fix-link (broken-query)
  (multiple-value-bind
        (scheme userinfo host port path query fragments)
        (quri:parse-uri
         (format nil "https://multitran.com~A" broken-query))
    (declare (ignorable fragments port))
    (format nil "~A"
            (quri:make-uri :scheme scheme
                           :userinfo userinfo
                           :host host
                           :path path
                           :query (let ((fixed-query (quri:url-decode-params query)))
                                    (setf (cdr (assoc "s" fixed-query :test #'string=))
                                          *the-word*)
                                    (quri:url-encode-params fixed-query))))))

(defun get-trs (html-string)
  (let ((root (parse html-string)))
    (coerce (lquery:$ root "tr") 'list)))

(defun create-word-request (word l1 l2)
  (format nil "https://www.multitran.com/m.exe?s=~A&l1=~A&l2=~A"
          (quri:url-encode word) l1 l2))

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
                                         (get-trs (load-page (fix-link (cadr category))))))))
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
