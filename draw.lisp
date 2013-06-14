(in-package #:pnong)

(defparameter +red+   (sdl:color :r 255))
(defparameter +green+ (sdl:color :g 255))
(defparameter +blue+  (sdl:color :b 255))

(defgeneric draw (thing)
  (:documentation "Draws the things!")

  (:method ((paddle paddle))
    (sdl:draw-box-* (if (eq (player paddle) :one)
			5
			(- 800 +paddle-width+ 5))
		    (- (paddle-position paddle) (/ +paddle-height+ 2))
		    +paddle-width+
		    +paddle-height+
		    :color (if (eq (player paddle) :one)
			       +red+
			       +blue+)))

  (:method ((ball ball))
    (sdl:draw-filled-circle-* (aref (ball-position ball) 0)
			      (aref (ball-position ball) 1)
			      +ball-radius+)))
