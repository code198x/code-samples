showframe:
            lea     sheep0,a0
            tst.w   curframe
            beq.s   .picked
            lea     sheep1,a0
.picked:
            move.l  a0,d0
            lea     copsprites,a1
            move.w  d0,6(a1)            ; Sprite 0 low word
            swap    d0
            move.w  d0,2(a1)            ; Sprite 0 high word
            rts
