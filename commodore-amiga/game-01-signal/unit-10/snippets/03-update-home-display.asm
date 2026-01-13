; Update Home Display
; Modify Copper list colours to show filled homes

update_home_display:
            lea     home_filled,a0
            lea     home_colour_0,a1

            ; Home 0
            tst.w   (a0)+
            beq.s   .home0_empty
            move.w  #COLOUR_HOME_FILLED,(a1)
            bra.s   .home1
.home0_empty:
            move.w  #COLOUR_HOME_LIT,(a1)

.home1:
            lea     home_colour_1,a1
            tst.w   (a0)+
            beq.s   .home1_empty
            move.w  #COLOUR_HOME_FILLED,(a1)
            bra.s   .home2
.home1_empty:
            move.w  #COLOUR_HOME_LIT,(a1)

            ; (continue for homes 2, 3, 4...)

            rts

; Copper list with modifiable home colours:
copperlist:
            ; ... other setup ...

            ; Home zone row with horizontal colour changes
            dc.w    $2c07,$fffe
            dc.w    COLOR00,COLOUR_HOME     ; Gap

            dc.w    $2c4f,$fffe             ; Wait for home 0 X position
            dc.w    COLOR00
home_colour_0:
            dc.w    COLOUR_HOME_LIT         ; Modified at runtime

            dc.w    $2c5f,$fffe             ; End of home 0
            dc.w    COLOR00,COLOUR_HOME     ; Gap

            ; (continue for homes 1-4...)
