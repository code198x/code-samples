            ; --- Point sprite 0 at the sheep, the rest at nothing ---
            lea     copsprites,a1       ; Eight pointer pairs in the list
            lea     sheep,a0
            move.l  a0,d0
            move.w  d0,6(a1)            ; Sprite 0 low word
            swap    d0
            move.w  d0,2(a1)            ; Sprite 0 high word

            lea     nullspr,a0          ; Sprites 1-7: an empty sprite
            move.l  a0,d0
            moveq   #7-1,d6
.nulls:
            lea     8(a1),a1            ; Next pointer pair in the list
            move.w  d0,6(a1)
            swap    d0
            move.w  d0,2(a1)
            swap    d0
            dbf     d6,.nulls
