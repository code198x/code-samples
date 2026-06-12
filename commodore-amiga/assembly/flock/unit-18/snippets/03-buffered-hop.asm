.alive:
            tst.w   cooldown
            beq.s   .ready
            subq.w  #1,cooldown         ; Mid-rhythm — but LISTEN: a
            move.w  JOY1DAT(a5),d0      ;   tap during the cooldown
            move.w  d0,d1               ;   used to vanish. Bank it
            lsr.w   #1,d1               ;   and serve it when ready —
            eor.w   d0,d1               ;   that's input buffering,
            and.w   #$0303,d1           ;   and it's most of "feel".
            bne.s   .moving
            move.w  #1,sawneutral       ; The stick came home
            rts
.moving:
            tst.w   sawneutral          ; Only a FRESH press banks —
            beq.s   .nobuf              ;   the press that caused this
            move.w  d0,hopbuf           ;   hop must not echo itself
.nobuf:     rts
.ready:
            tst.w   panic               ; Bolting? She's not asking
            beq.s   .listening
            subq.w  #1,panic
            cmp.w   #FENCE_Y,sheepy     ; A bolt is an UP that ignores
            bgt.s   .bolthop            ;   the stick entirely
            bsr     trypen              ; Bolting at the fence: she
            bra     .done               ;   slams into it (or a pen)
.bolthop:
            sub.w   #STEP,sheepy
            bra     .stepped
.listening:
            move.w  JOY1DAT(a5),d0      ; Read the stick
            tst.w   hopbuf              ; A banked tap outranks the
            beq.s   .live               ;   stick's present mood —
            move.w  hopbuf,d0           ;   replayed RAW, so left and
            clr.w   hopbuf              ;   right replay too (steer
.live:                                  ;   tests those bits in D0)
            move.w  d0,d1
            lsr.w   #1,d1
            eor.w   d0,d1               ; Now: bit 0 = down, bit 8 = up
