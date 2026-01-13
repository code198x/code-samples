;------------------------------------------------------------------------------
; NEXT_LEVEL - Advance to the next level
; Called when all 5 homes are filled
;------------------------------------------------------------------------------
next_level:
            ; Award level completion bonus
            add.l   #LEVEL_BONUS,score

            ; Increment level
            move.w  level,d0
            addq.w  #1,d0
            move.w  d0,level

            ; Clear all homes for new level
            lea     home_filled,a0
            moveq   #NUM_HOMES-1,d0
.clear:
            clr.w   (a0)+
            dbf     d0,.clear

            ; Update car speeds for new level
            bsr     set_car_speeds

            ; Update displays
            bsr     update_home_display
            bsr     display_score
            bsr     display_level

            rts
