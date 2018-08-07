(in-package :cl-user)
(defpackage clkedit.page
  (:use :cl)
  (:import-from :clkedit.server
		:defroute
		:return-static-text-file
		:return-static-vector-file)
  (:import-from :clkedit.controller
		:send-query
		:select
		:get-domain-name
		:create-new-domain
		:node-struct-jsonfy
		:edge-struct-jsonfy
		:node-save
		:edge-save)
  (:import-from :cl-who
                :with-html-output
                :html-mode))
(in-package :clkedit.page)

(defroute "/css/img/:image-name" (params :method :get)
  `(return-static-vector-file ,(format nil "~A~A" "vis/img/" (cdr (assoc 'image-name params :test #'string=)))))

(defroute "/css/vis.min.css" (params :method :get)
  `(return-static-text-file "vis/vis.min.css"))

(defroute "/js/jquery.min.js" (params :method :get)
  `(return-static-text-file "/jquery.min.js"))

(defroute "/js/bootstrap.min.js" (params :method :get)
  `(return-static-text-file "design/bootstrap.min.js"))

(defroute "/css/bootstrap.min.css" (params :method :get)
  `(return-static-text-file "design/bootstrap.min.css"))

(defroute "/css/graph.css" (params :method :get)
  `(return-static-text-file "vis/graph.css"))

(defroute "/js/advanced-setting.js" (params :method :get)
  `(return-static-text-file "vis/advanced-setting.js"))

(defroute "/js/vis.js" (params :method :get)
  `(return-static-text-file "vis/vis.js"))

(defroute "/network-node/:domain-id" (params :method :get)
  (node-struct-jsonfy (cdr (assoc 'domain-id params :test #'string=))))

(defroute "/network-edge/:domain-id" (params :method :get)
  (edge-struct-jsonfy (cdr (assoc 'domain-id params :test #'string=))))

(setf (cl-who:html-mode) :html5)

(defroute "/" (params :method :get)
  `(with-html-output (*standard-output* nil :indent t :prologue t)
     (:html :lang "ja"
	    (:head
	     (:meta :charset "utf-8")
	     (:meta :http-equiv "X-UA-Comatible" :content "IE=edge")
	     (:meta :name "viewpoint" :content "width=device-width, initial-scale=1"))
	    (:body
	     ,@(loop for x in (send-query
			       (make-instance 'select :dist t
						      :table "domain"
						      :param '("domain_id" "domain_name")
						      :cond-list '("1=1")))
		     collect (list :a :href (format nil "/edit?domain-id=~A" (second x))
				   (format nil "~A" (fourth x))
				   (list :br)))
	     (:form :action "/create-domain" :method :get
		    (:input :type "text" :name "new-domain-name" :placeholder "新しいドメイン")
		    (:input :type "submit" :value "送信"))))))

(defroute "/edit" (params :method :get)
  `(with-html-output (*standard-output* nil :indent t :prologue t)
     (:html :lang "ja"
	    (:head
	     (:meta :charset "utf-8")
	     (:meta :http-equiv "X-UA-Comatible" :content "IE=edge")
	     (:meta :name "viewpoint" :content "width=device-width, initial-scale=1")
	     (:title "CLKEdit")
	     (:script :type "text/javascript" :src "/js/jquery.min.js")
	     (:script :type "text/javascript" :src "/js/vis.js")
     	     (:script :type "text/javascript" :src "/js/advanced-setting.js")
	     (:script :type "text/javascript" :src "/js/bootstrap.min.js")
	     (:link :rel "stylesheet" :type "text/css" :href "/css/vis.min.css")
	     (:link :rel "stylesheet" :type "text/css" :href "/css/bootstrap.min.css")
	     (:link :rel "stylesheet" :type "text/css" :href "/css/graph.css"))
	    (:body
	     (:div :id "k-ins"
		   (:h1 :id "project-name"
			,(format nil "CLKEditor: ~A"
				 (get-domain-name (or (cdr (assoc "domain-id" params :test #'string=)) 1))))
		   (:a :href "/" (:p "Return TOP"))

		   (:div :id "knowledge-structure")
		   (:div :style "clear:both;")
		   (:br)
		   (:div

		    (:div :id "network-popUp"
			  (:span "編集ウィンドウ")
			  (:br)
			  (:table :style "margin:auto;" :id "editTable"
				  (:br)
				  (:tr
				   (:td "ノードのタイプ")
				   (:td " : ")
				   (:td (:select :id "node-type-selection" :name "node-type-sel"
						 (:option :value "fact" :selected "selected" "Knowledge Node")
						 (:option :value "predicate" "Edge Node"))))
				  (:tr (:td (:br)) (:td) (:td))
				  (:tr
				   (:td "編集前のラベル")
				   (:td " : ")
				   (:td (:span :id "before-edit-knowledge-label")))
				  (:tr (:td (:br)) (:td) (:td))
				  (:tr
				   (:td "編集後のラベル")
				   (:td " : ")
				   (:td (:input :id "node-edit-text-area" :value "" :size "40" :placeholder "編集するノードのラベルを入力してください")))
				  (:tr (:td (:br)) (:td) (:td)))
			  (:div :id "btn-modules"
				(:button :type "button" :class "btn btn-info" :id "knolwedge-edit-text-save-btn" "確定")
				(:button :type "button" :class "btn btn-error" :id "editCancelBtn" "中止"))))
		    (:button :type "button" :class "btn btn-warning" :id "knowledge-ensure-btn" "保存"))))))

(defroute "/create-domain" (params :method :get)
  (progn (create-new-domain (cdr (assoc "new-domain-name" params :test #'string=)))
	 (format nil "<!DOCTYPE html><html lang='ja'><head><script type='text/javascript'>location.href='/';</script></head></html>")))
      

(defroute "/node-save" (params :method :post)
  (node-save (cdr (assoc "domainId" params :test #'string=))
	     (cdr (assoc "jsonData" params :test #'string=))))

(defroute "/edge-save" (params :method :post)
  (edge-save (cdr (assoc "domainId" params :test #'string=))
	     (cdr (assoc "jsonData" params :test #'string=))))
