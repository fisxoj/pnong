(in-package #:pnong)

(defparameter +paddle-width+  10)
(defparameter +paddle-height+ 50)

(defparameter +paddle-move-speed+ 15)

(defclass paddle ()
  ((position :type integer
	     :accessor paddle-position
	     :initform 300)
   (player :type (member :one :two)
	   :accessor player
	   :initarg :player)))

(defun player-paddle ()
  (if (server-p)
      *paddle-one*
      *paddle-two*))

(defun move-up ()
  (decf (paddle-position (if (server-p)
			     *paddle-one*
			     *paddle-two*))
	+paddle-move-speed+))

(defun move-down ()
  (incf (paddle-position (if (server-p)
			     *paddle-one*
			     *paddle-two*))
	+paddle-move-speed+))

(defmethod serialize (buffer (paddle paddle))
  (userial:with-buffer buffer
      (userial:serialize* :keyword (player paddle)
			  :int32 (paddle-position paddle))))

(defmethod deserialize (buffer (thing (eql :paddle)))

  (userial:with-buffer buffer
    (let ((player (userial:unserialize :keyword))
	  (position (userial:unserialize :int32)))

      (setf (paddle-position (if (eq player :one)
				 *paddle-one*
				 *paddle-two*))
	    position))))
