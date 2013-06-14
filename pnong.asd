;;;; pnong.asd

(asdf:defsystem #:pnong
  :serial t
  :description "Example networked pong game using usocket and userial with lispbuilder-sdl"
  :author "Matt Novenstern <fisxoj@gmail.com>"
  :license "LLGPLv3+"
  :depends-on (#:lispbuilder-sdl
               #:usocket
               #:userial)
  :components ((:file "package")
	       (:file "game-state")
	       (:file "paddle")
	       (:file "ball")
	       (:module "network"
		:components ((:file "common")
			     (:file "server")
			     (:file "client")))
	       (:file "draw")
               (:file "pnong")))

