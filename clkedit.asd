(in-package :cl-user)
(defpackage clkedit-asd
  (:use :cl :asdf))
(in-package :clkedit-asd)

(defsystem clkedit
  :version "0.1.3"
  :author "Tomoki Aburatani"
  :license :MIT
  :depends-on (:cl-who
	       :cl-fad
	       :alexandria
	       :cl-ppcre
	       :uiop
	       :local-time
	       :dbi
	       :cl-json
               :clack
               :ningle
               :woo
	       :split-sequence
	       :utsushiyo)
  :components ((:static-file "LICENSE-MIT")
	       (:static-file "LICENSE-APACHE2.0")
	       (:static-file "README.md")
	       (:module "src"
                :components
                ((:file "clkedit" :depends-on ("server"))
		 (:file "pages" :depends-on ("server"))
		 (:file "server" :depends-on ("controller"))
		 (:file "controller" :depends-on ("init" "utils"))
		 (:file "utils")
		 (:file "init"))))
  :description "Common Lisp network style Knowledge graph EDITtor"
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.md"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op clkedit-test))))
