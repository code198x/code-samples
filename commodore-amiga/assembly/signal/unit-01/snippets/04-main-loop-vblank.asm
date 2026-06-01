; Main Loop with VBlank Wait
; The main loop runs once per frame, synchronised to the display.
; We wait for line 0 (vertical blank) to ensure smooth updates.

mainloop:
            ; Wait for vertical blank (line 0)
            move.l  #$1ff00,d1          ; Mask: 9 bits of line number
.vbwait:
            move.l  VPOSR(a5),d0        ; Read beam position
            and.l   d1,d0               ; Isolate line bits
            bne.s   .vbwait             ; Loop until line 0

            ; Game logic here...

            bra.s   mainloop

; VPOSR contains: V8 V7 V6 V5 V4 V3 V2 V1 V0 H8 H7...
; The mask $1ff00 isolates the 9 vertical bits
; When zero, we're at the top of the display
