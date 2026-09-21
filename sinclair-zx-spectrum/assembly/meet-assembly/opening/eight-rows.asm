; Eight rows of original artwork. Explicit writes come before a drawing loop.
; Adjacent displayed rows are not adjacent memory addresses on this machine.
 org 32768
start:
 ld a,0
 out ($FE),a
 ld a,71
 ld ($5800),a
 ld a,%00011000
 ld ($4000),a
 ld a,%00111100
 ld ($4100),a
 ld a,%01111110
 ld ($4200),a
 ld a,%11011011
 ld ($4300),a
 ld a,%11111111
 ld ($4400),a
 ld a,%00111100
 ld ($4500),a
 ld a,%01100110
 ld ($4600),a
 ld a,%01000010
 ld ($4700),a
hold:
 jr hold
 end start
