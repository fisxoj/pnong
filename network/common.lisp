(in-package #:pnong)

(userial:make-enum-serializer :opcodes
    (
     ;; For joining a game
     :join
     :accept

     ;; For the game
     :delta-update
     :batch-update
     ))

(userial:make-vector-serializer :coordinate :int32 2)

(defun connected-p ()
  (or *client*
      *server-connection*))

(defun send-message (to buffer)
  (userial:with-buffer buffer
    (let ((size (userial:buffer-length))
	  (stream (usocket:socket-stream to)))
      (write-byte size stream)
      (write-sequence buffer stream :end (length buffer))
      (force-output stream))))

(defun read-messages ()
  (let* ((connection (if (server-p)
			 *client*
			 *server-connection*))
	 (buffer     (userial:make-buffer))
	 (stream     (usocket:socket-stream connection)))

    ;; Read the size of the message in bytes, then read those bytes
    (when (listen stream)
      (userial:with-buffer buffer
	(let* ((size (read-byte stream)))
	  (userial:buffer-advance size)
	  (read-sequence buffer stream :end size))


	(unless (zerop (userial:buffer-length))
	  (userial:buffer-rewind)
	  (deserialize buffer (userial:unserialize :opcodes)))))))

(defgeneric deserialize (buffer thing)
  (:method (message (thing (eql :delta-update)))
    (userial:with-buffer message
      (deserialize message (userial:unserialize :keyword))))

  (:method (message (thing (eql :batch-update)))
    (userial:with-buffer message
      (let ((number-of-deltas (userial:unserialize :int32)))
	(dotimes (i number-of-deltas)
	  (deserialize message :delta-update))))))

(defgeneric serialize (buffer thing))


(defun network ()
  "Network loop"
  (if (connected-p)
      (progn
	(read-messages)

	(when (server-p)
	  (batch-update)))

      ;; Nothing is connected, so wait for its connection
      (when (server-p)
	(accept-client))))
