showframe:
            lea     nullspr,a0          ; Game over, or the whole flock
            tst.w   gameover            ;   home: no sheep on the move
            bne.s   .picked
            tst.w   won
            bne.s   .picked
            lea     sheep0,a0
            move.w  curframe,d0
            cmp.w   #NERVE_EDGE,nerve   ; Trembling: walk on the spot —
            blt.s   .steady             ;   the step images alternate
            move.w  framecnt,d0         ;   every few frames, going
            lsr.w   #2,d0               ;   nowhere
.steady:
            and.w   #1,d0
            beq.s   .picked
            lea     sheep1,a0
.picked:
