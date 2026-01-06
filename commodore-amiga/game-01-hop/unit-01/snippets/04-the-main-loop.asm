mainloop:
            ; Wait for vertical blank (line 0)
            move.l  #$1ff00,d1          ; Mask for vertical position
.vbwait:
            move.l  VPOSR(a5),d0        ; Read beam position
            and.l   d1,d0               ; Isolate vertical bits
            bne.s   .vbwait             ; Loop until line 0

            ; Check left mouse button (active low)
            btst    #6,$bfe001          ; Test bit 6 of CIA-A
            bne.s   mainloop            ; If set (not pressed), continue

            ; Mouse pressed - for now, just loop forever
            ; In a real game, this might reset or exit
            bra.s   mainloop
