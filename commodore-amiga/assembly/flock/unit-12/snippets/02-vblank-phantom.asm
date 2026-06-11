            ; Wait for vertical blank — in two phases. If we only
            ; waited FOR line 0, a fast loop body could finish while
            ; the beam is still ON line 0 and run again in the same
            ; frame. Wait to leave line 0 first, then to reach it.
            move.l  #$1ff00,d1          ; Mask: bits 8-16 of beam position
.vbleave:
            move.l  VPOSR(a5),d0        ; Read beam position
            and.l   d1,d0               ; Isolate line number
            beq.s   .vbleave            ; Loop while still on line 0
.vbwait:
            move.l  VPOSR(a5),d0        ; Read beam position
            and.l   d1,d0               ; Isolate line number
            bne.s   .vbwait             ; Loop until line 0 again
            ; The line number spans TWO registers, and the 68000
            ; reads them one after the other. Catch the beam mid-
            ; crossing (255 to 256) and the halves disagree: V8
            ; from the old line, V0-V7 from the new one — a line
            ; that reads as 0 but isn't. Read again: a real line 0
            ; stays 0, a phantom is gone by the second look.
            move.l  VPOSR(a5),d0        ; Confirm against a second read
            and.l   d1,d0
            bne.s   .vbwait             ; Phantom — keep waiting
