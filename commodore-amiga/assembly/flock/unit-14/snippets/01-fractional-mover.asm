;
; Unit 5's mover, made data — and now made FRACTIONAL. Every
; position is a longword in 16.16 fixed point: the top word is
; the pixel, the bottom word is the fraction of a pixel the
; vehicle has earned but not yet shown. Adding a 16.16 speed
; each frame accumulates the fraction; when it overflows, the
; pixel above it ticks. The cow ambles at half a pixel a frame
; and the mover never knows she's special. And because the
; 68000 stores the high word FIRST, a plain move.w at the
; label still reads the pixel — every old word-read works.
;══════════════════════════════════════════════════════════════

drivelanes:
            lea     vehtab,a2
            moveq   #6-1,d6             ; Three vehicles, two ferries,
.veh:                                   ;   one cow
            move.l  (a2)+,a0            ; A0 = where this one's x lives
            move.l  (a2)+,d1            ; D1 = its speed (16.16, signed)
            move.l  (a0),d0
            add.l   d1,d0
            tst.l   d1
            bmi.s   .leftward
            cmp.l   #320<<16,d0         ; Rightward: clear of the right edge?
            blt.s   .store
            move.l  #-16<<16,d0         ; Re-enter from the left
            bra.s   .store
.leftward:
            cmp.l   #-16<<16,d0         ; Leftward: clear of the left edge?
            bgt.s   .store
            move.l  #320<<16,d0         ; Re-enter from the right
.store:
            move.l  d0,(a0)
            dbf     d6,.veh
            rts

vehtab:     dc.l    tractx
            dc.l    TRACTOR_SPEED<<16
            dc.l    cartx
            dc.l    CART_SPEED<<16
            dc.l    roverx
            dc.l    ROVER_SPEED<<16
            dc.l    balex
            dc.l    BALE_SPEED<<16
            dc.l    duckx
            dc.l    DUCK_SPEED<<16
            dc.l    cowx
            dc.l    COW_SPEED
