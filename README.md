# Pnong

Pnong is a simple pong-clone that demonstrates usocket and userial.  It's not too clever, but those libraries lack some good examples so I hope this helps in that sense.

## Running the game

This runs the server:
```lisp
(pnong:main)
```

Then, in another lisp instance, start the client:
```lisp
(pnong::main nil usocket:*wildcard-host*)
```

Make sure to start them in that order.

## What's happening?

The server sends batch updates to the client saying where everything is.  The client sends delta updates to the server saying where its paddle is.  The ball probably will slide off the screen because I didn't really care about the boundary conditions.

## Enjoy!