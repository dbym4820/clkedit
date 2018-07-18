(in-package :cl-user)
(defpackage clkedit.init
  (:use :cl)
  (:import-from :utsushiyo
		:project-env
		:make-project-env
		:ensure-project-env
		:delete-project-env
		:get-attribute
		:get-attribute-sentence
		:set-attribute
		:project-root-path
		:config-dir
		:copy-file)
  (:export
   :clear-data
   :init
   :*clkedit-project*
   :*user-db-path*
   :*static-file-path*
   :get-attribute
   :get-attribute-sentence
   :set-attribute))
(in-package :clkedit.init)

(defconstant +p-name+ "clkedit")
(defparameter *clkedit-project*
  (make-project-env +p-name+))

(defvar *original-db-path*
  (format nil "~A~A"
	  (utsushiyo:project-root-path *clkedit-project*)
	  "/src/database/graphdb-origin.sqlite"))

(defvar *user-db-path*
  (format nil "~A~A" (utsushiyo:config-dir *clkedit-project*) "graphdb.sqlite"))

(defvar *static-file-path*
  (format nil "~A~A" (utsushiyo:project-root-path *clkedit-project*) "/src/static/"))

(defun clear-data ()
  (copy-file *original-db-path* *user-db-path* :overwrite t))

(defun init ()
  (ensure-project-env *clkedit-project*)
  (copy-file *original-db-path* *user-db-path* :overwrite t))
