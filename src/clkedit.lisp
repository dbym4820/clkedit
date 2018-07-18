(in-package :cl-user)
(defpackage clkedit
  (:use :cl)
  (:import-from :clkedit.server
   :run-server)
  (:import-from :clkedit.init
		:init
		:clear-data)
  (:export :run-server :init :clear-data))
(in-package :clkedit)
