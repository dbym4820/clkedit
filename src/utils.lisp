(in-package :cl-user)
(defpackage clkedit.utils
  (:use :cl)
  (:import-from :local-time
                :now
   		:timestamp-year
		:timestamp-month
		:timestamp-day
		:timestamp-hour
		:timestamp-minute
		:timestamp-second)
  (:export
   :get-timestamp))
(in-package :clkedit.utils)

(defun get-timestamp ()
  (let* ((current-time (now))
	 (year (timestamp-year current-time))
	 (month (timestamp-month current-time))
	 (day (timestamp-day current-time))
	 (hour (timestamp-hour current-time))
	 (mini (timestamp-minute current-time))
	 (sec (timestamp-second current-time))
	 (time-stamp (format nil "~A-~2,,,'0@A-~2,,,'0@A ~2,,,'0@A:~2,,,'0@A:~2,,,'0@A" year month day hour mini sec)))
    time-stamp))
