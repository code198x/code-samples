.wet:
            move.w  contacts,d0
            and.w   #$0c00,d0           ; Either ferry under her feet?
            beq.s   .adrift
            clr.w   drownarm            ; Feet on something that floats
            btst    #10,d0              ; Which deck is she on?
            beq.s   .duckdeck
            add.w   #BALE_SPEED,sheepx  ; Carried with the bale's drift
            bra.s   .edges
.duckdeck:
            add.w   #DUCK_SPEED,sheepx  ; The duck paddles the other way
.edges:
            tst.w   sheepx              ; Carried off either end of the
            bmi.s   .drowned            ;   world is still a loss
            cmp.w   #320-16,sheepx
            blt     .dry
            bra.s   .drowned
