(in-package :cl-user)
(defpackage clkedit.controller
  (:use :cl)
  (:import-from :dbi
                :connect :disconnect
                :prepare :fetch :execute)
  (:import-from :cl-json
		:decode-json-from-string)
  (:import-from :utsushiyo
		:get-attribute-sentence)
  (:import-from :clkedit.init
		:*user-db-path*)
  (:import-from :clkedit.utils
		:get-timestamp)
  (:export
   :send-query
   :select
   :get-domain-name
   :create-new-domain
   :node-struct-jsonfy
   :edge-struct-jsonfy
   :node-save
   :edge-save))
(in-package :clkedit.controller)

(defun ensure-query (query)
  (let* ((database-connection (connect :sqlite3 :database-name *user-db-path*))
	 (pre-query (prepare database-connection query))
	 (result (execute pre-query))
	 (return-value
	   (loop for row = (fetch result)
		 while row
		 collect row)))
    (disconnect database-connection)
    return-value))

(defun query-conc (&rest q-str)
  (format nil "~{~A~^ ~}" q-str))

(defclass db-query ()
  ((database :initform *user-db-path* :reader db-path)))

(defclass select (db-query)
  ((distinct :initarg :dist :reader dist)
   (param :initarg :param :reader param)
   (table :initarg :table :reader table)
   (cond-list :initarg :cond-list :accessor cond-list)))

(defclass sql-insert (db-query)
  ((table :initarg :table :reader table)
   (param :initarg :param :reader param)
   (value-list :initarg :val :reader val)))

(defclass sql-delete (db-query)
  ((table :initarg :table :reader table)
   (cond-list :initarg :cond-list :accessor cond-list)))

(defgeneric send-query (db-query))
(defmethod send-query ((select select))
  (ensure-query
   (query-conc "select" (when (dist select) "distinct")
	       (if (param select) (format nil "~{~A~^, ~}" (param select)) "*")
	       "from" (table select)
	       (when (cond-list select)
		 (query-conc "where"
			     (format nil"~{~A~^ and ~}" (cond-list select)))))))

(defmethod send-query ((insert sql-insert))
  (ensure-query
   (query-conc "insert into" (table insert)
	       (format nil "(~{~A~^, ~}) values" (param insert))
	       (format nil "(~{'~A'~^, ~})" (val insert)))))

(defmethod send-query ((sql-delete sql-delete))
  (ensure-query
   (query-conc "delete from" (table sql-delete)
	       (when (cond-list sql-delete)
		 (query-conc "where"
			     (format nil "~{~A~^ and ~}" (cond-list sql-delete)))))))

(defun get-domain-name (domain-id)
  (cadar
   (send-query
    (make-instance 'select
		   :dist t
		   :param '("domain_name")
		   :table "domain"
		   :cond-list (list (format nil "domain_id=~A" domain-id))))))

(defun node-struct-jsonfy (domain-id)
  (format nil "[~{{~{\"id\":\"~A\", \"label\":\"~A\"~}}~^,~}]"
	  (mapcar #'(lambda (d)
		      (list (second d) (fourth d)))
		  (send-query
		   (make-instance 'select
				  :dist t
				  :param '("knowledge_id_in_graph" "knowledge_content")
				  :table "knowledge_node"
				  :cond-list (list (format nil "domain_id=~A" domain-id)))))))

(defun edge-struct-jsonfy (domain-id)
  (format nil "[~{{~{\"from\":\"~A\", \"to\":\"~A\"~}}~^,~}]"
	  (mapcar #'(lambda (d)
		      (list (second d) (fourth d)))
		  (send-query
		   (make-instance 'select
				  :dist t
				  :param '("edge_from" "edge_to")
				  :table "knowledge_edge"
				  :cond-list (list (format nil "domain_id=~A" domain-id)))))))

(defun create-new-domain (domain-name)
  (let ((cur-time (get-timestamp)))
    (send-query (make-instance 'sql-insert
			       :table "domain"
			       :param '("domain_name" "created_at" "edited_at")
			       :val (list domain-name cur-time cur-time)))))

(defun shaping-json (raw-data trim-from-even trim-from-odd &optional trim-end)
  (let* ((full (mapcar #'(lambda (d)
			   (string-trim "}" (string-trim "{" (string-trim "\"" (string-trim " " d)))))
		       (split-sequence:split-sequence #\, (subseq raw-data 1 (1- (length raw-data))))))
	 (even-data (loop for x from 0
			  for y in full
			  when (evenp x)
			    collect (subseq y trim-from-even (if trim-end (1- (length y)) (length y)))))
	 (odd-data (loop for x from 0
			 for y in full
			 when (oddp x)
			   collect (subseq y trim-from-odd (if trim-end (1- (length y)) (length y))))))
    (mapcar #'list even-data odd-data)))

(defun node-save (domain-id graph-json-string)
  (when (not (string= "[]" graph-json-string))
    (let ((cur-time (get-timestamp)))
      (progn
	(format t "~% node: ~A~%" graph-json-string)
	(send-query (make-instance 'sql-delete :table "knowledge_node" :cond-list (list (format nil "domain_id=~A" domain-id))))
	(loop for node in (shaping-json graph-json-string 4 7 t)
	      do (send-query
		  (make-instance 'sql-insert
				 :table "knowledge_node"
				 :param '("domain_id" "knowledge_id_in_graph" "knowledge_content" "created_at" "edited_at")
				 :val (list domain-id (first node) (second node) cur-time cur-time))))))))

(defun edge-save (domain-id edge-json-string)
  (when (not (string= "[]" edge-json-string))
    (let ((cur-time (get-timestamp)))
      (send-query (make-instance 'sql-delete :table "knowledge_edge" :cond-list (list (format nil "domain_id=~A" domain-id))))
      (loop for node in (shaping-json edge-json-string 6 4 t)
	    do (progn (format t "~A~%" node)
		 (send-query
		(make-instance 'sql-insert
			       :table "knowledge_edge"
			       :param '("domain_id" "edge_from" "edge_to" "created_at" "edited_at")
			       :val (list domain-id (format nil "~A" (first node)) (format nil "~A" (second node)) cur-time cur-time))))))))
