; Meteor Storm loading screen: the 6912-byte SCREEN$ as a CODE block at 16384,
; the bitmap's address, so that LOAD ""SCREEN$ puts it straight on the screen.
; meteor-storm.scr comes from loading-screen.png (see compose.py).
 org 16384
 incbin "meteor-storm.scr"
