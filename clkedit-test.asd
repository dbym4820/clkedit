(in-package :cl-user)
(defpackage clkedit-test-asd
  (:use :cl :asdf))
(in-package :clkedit-test-asd)

(defsystem clkedit-test
  :author "Tomoki Aburatani"
  :license "MIT"
  :depends-on (:clkedit
	       :drakma
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "clkedit"))))
  :description "Test system for clkedit"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
