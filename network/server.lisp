(in-package #:pnong)

(defvar *server* t)

(defvar *server-socket* nil)

(defun server-p () *server*)

(defvar *client* nil)

(defun start-server (&optional (port 2448))
  (assert (not *server-socket*))
  (setf *server-socket*
	(usocket:socket-listen usocket:*wildcard-host*
			       port
			       :reuseaddress t
			       :element-type '(unsigned-byte 8))))

(defun stop-server ()
  (assert *server-socket*)
  (usocket:socket-close *server-socket*)
  (setf *server-socket* nil
	*client* nil))

(defun accept-client ()
  (when (usocket:wait-for-input *server-socket*
				:timeout 0
				:ready-only t)
    (unless *client*
      (setf *client* (usocket:socket-accept *server-socket*)))))

(defun batch-update ()
  (when *client*
    (let ((buffer (userial:make-buffer)))
      (userial:with-buffer buffer
	(userial:serialize :opcodes :batch-update)
	(userial:serialize :int32 3) ; number of delta update in the batch

	(userial:serialize :keyword :paddle)
	(serialize buffer *paddle-one*)

	(userial:serialize :keyword :paddle)
	(serialize buffer *paddle-two*)

	(dolist (ball *balls*)
	  (userial:serialize :keyword :ball)
	  (serialize buffer ball)))

      (send-message *client* buffer))))
