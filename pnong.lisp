;;;; pnong.lisp

(in-package #:pnong)

;;; "pnong" goes here. Hacks and glory await!

(defun main (&optional (server-p t) (server-ip))
  (setf *server* server-p)
  (sdl:window 800 600)
  (sdl:initialise-default-font)
  (setf *paddle-one* (make-instance 'paddle :player :one))
  (setf *paddle-two* (make-instance 'paddle :player :two))
  (setf *balls* (list (make-instance 'ball)))
  (if (server-p)
    (start-server)
    (connect-to-server server-ip))
  (unwind-protect
       (sdl:with-events ()
	 (:key-down-event (:key key)
			  (cond
			    ((eq key :sdl-key-up)
			     (move-up))
			    ((eq key :sdl-key-down)
			     (move-down)))
			  (unless (server-p)
			    (delta-update (player-paddle))))
	 (:idle ()
		(network)
		(when (connected-p)
		  (tick 0f0)
		  (display)))
	 (:quit-event ()	   
		      
		      t))

    (if (server-p)
	(stop-server)
	(disconnect-from-server))))

(defun display ()
  (sdl:clear-display sdl:*black*)
  (draw *paddle-one*)
  (draw *paddle-two*)
  (dolist (ball *balls*)
    (draw ball))
  (sdl:with-color (sdl:*white*)
    (sdl:draw-string-solid-* (format nil "I am the ~a." (if (server-p) "server" "client"))
			     5 5))
  (sdl:update-display))

(defun tick (dt)
  (declare (ignore dt)) ; for now
  ;; Check if a ball has collided with a paddle
  (macrolet ((flip-x (ball)
	       `(setf (aref (velocity ,ball) 0)
		      (- (aref (velocity ,ball) 0))))
	     (flip-y (ball)
	       `(setf (aref (velocity ,ball) 1)
		      (- (aref (velocity ,ball) 1)))))

    (dolist (ball *balls*)
      (cond
	;; Left Paddle
	((and (<= (aref (ball-position ball) 0)
		  (+ 5 +paddle-width+ +ball-radius+))

	      (< (aref (ball-position ball) 1)
		 (+ (paddle-position *paddle-one*)
		    (/ +paddle-height+ 2)))
	      (> (aref (ball-position ball) 1)
		 (- (paddle-position *paddle-one*)
		    (/ +paddle-height+ 2))))

	 (flip-x ball))

	;; Right paddle
	((and (>= (aref (ball-position ball) 0)
		  (- 800 +paddle-width+ +ball-radius+ 5))
	      (< (aref (ball-position ball) 1)
		 (+ (paddle-position *paddle-two*)
		    (/ +paddle-height+ 2)))
	      (> (aref (ball-position ball) 1)
		 (- (paddle-position *paddle-two*)
		    (/ +paddle-height+ 2))))


	 (flip-x ball))

	;; Hit a wall?

					; left
	((<= (aref (ball-position ball) 0)
	     +ball-radius+)

	 (flip-x ball))

					; right
	((>= (aref (ball-position ball) 0)
	     (- 800 +ball-radius+))

	 (flip-x ball))

					; top
	((<= (aref (ball-position ball) 1)
	     +ball-radius+)

	 (flip-x ball))

					; bottom
	((>= (aref (ball-position ball) 1)
	     (- 600 +ball-radius+))

	 (flip-y ball)))
					;    (format t "~%ball position: ~a~t velocity: ~a" (ball-position ball) (velocity ball))
      ;; Move balls
      (dotimes (i 2)
	(incf (aref (ball-position ball) i) (aref (velocity ball) i))))))
