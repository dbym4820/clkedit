(in-package :cl-user)
(defpackage clkedit.server
  (:use :cl)
  (:import-from :ningle
		:route
		:<app>)
  (:import-from :cl-who
                :with-html-output
                :html-mode)
  (:import-from :alexandria
		:read-file-into-string
		:read-file-into-byte-vector)
  (:import-from :clack
		:clackup)
  (:import-from :clkedit.init
                :*clkedit-project*
		:*user-db-path*
		:*static-file-path*
                :get-attribute
		:get-attribute-sentence
                :set-attribute)
  (:export
   :defroute
   :return-static-text-file
   :return-static-vector-file
   :run-server))
(in-package :clkedit.server)

#|
Application settings
|#
(defvar *serv* (make-instance '<app>))
(defparameter *active-server* nil)

#|
Launch functions
|#
(defun start-system (port)
  (setf (route *serv* "/welcome")
	#'(lambda (params)
	    (format nil "Welcome to CLKEditor"))
	*active-server* (clack:clackup *serv* :port port :server :woo :silent t)))

(defun stop-system ()
  (clack.handler:stop *active-server*)
  (setf *active-server* nil))

(defun run-server (&optional (port 26262))
  (progn
    (start-system port)
    (format t "The clkedit server is running")
    (loop for input = (read-line)
	  while (not (or (string= "quit" input) (string= "exit" input)))
	  finally (stop-system))))

#|
Page settings
|#
(defun return-static-text-file (file-path-from-static-dir)
  "(return-static-file \"vis/vis.min.js\")"
  (read-file-into-string (format nil "~A~A" *static-file-path* file-path-from-static-dir)))

(defun return-static-vector-file (file-path-from-static-dir)
  "(return-static-vector-file \"img/vis/sample.png\")"
  (read-file-into-byte-vector (format nil "~A~A" *static-file-path* file-path-from-static-dir)))


(defmacro defroute (name (params &rest route-args) &body body)
  `(setf (ningle:route *serv* ,name ,@route-args)
         #'(lambda (,params)
	     (declare (ignorable ,params))
	     (eval ,@body))))

