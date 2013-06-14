(in-package #:pnong)

(deftype coordinate ()
  '(simple-array interger (2)))

(defparameter +ball-radius+ 5)

(defclass ball ()
  ((position :type coordinate
	     :accessor ball-position
	     :initform (make-array 2
				   :element-type 'integer
				   :initial-contents '(400 300)))
   (velocity :type coordinate
	     :initform (random-coordinate 5)
	     :accessor velocity)))

(defun random-coordinate (&optional (max 10))
  (let ((result (make-array 2 :element-type 'integer)))
    (setf (aref result 0) (* (expt -1 (random 2)) (random max))
	  (aref result 1) (* (expt -1 (random 2)) (random max)))
    result))

(defmethod deserialize (buffer (type (eql :ball)))
  (userial:with-buffer buffer
    (userial:unserialize* :coordinate (ball-position (first *balls*))
			  :coordinate (velocity (first *balls*)))))

(defmethod serialize (buffer (ball ball))
  (userial:with-buffer buffer
    (userial:serialize* :coordinate (ball-position ball)
			:coordinate (velocity ball))))
