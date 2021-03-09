;;;; cl-multitran.asd

(asdf:defsystem #:cl-multitran
  :description "Load translations from multitran.com"
  :author "Pavel Stepanov"
  :license  "MIT"
  :version "0.0.1"
  :depends-on (#:dexador
               #:cl-punch
               #:plump
               #:lquery
               #:do-urlencode
               #:lparallel
               #:command-line-arguments
               #:cl-fill-string)
  :components ((:file "package")
               (:file "printer")
               (:file "request")
               (:file "cl-multitran"
                :depends-on ("request"
                             "printer")))
  :build-operation "program-op"
  :build-pathname #.(ensure-directories-exist
                     (merge-pathnames ".local/bin/mtran" (user-homedir-pathname)))
  :entry-point "cl-multitran:main")

#+sb-core-compression
(defmethod asdf:perform ((o asdf:image-op) (c asdf:system))
  (uiop:dump-image (asdf:output-file o c) :executable t :compression t))
