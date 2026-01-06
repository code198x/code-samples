check_level_complete:
            lea     home_slots,a0
            moveq   #4,d0
.check_loop:
            tst.w   (a0)+
            beq.s   .not_complete
            dbf     d0,.check_loop

            ; All filled - level complete!
            addi.l  #1000,score
            addq.w  #1,level

            ; Clear slots for next level
            lea     home_slots,a0
            moveq   #4,d0
.clear_loop:
            clr.w   (a0)+
            dbf     d0,.clear_loop

            ; Reset best Y tracking
            move.w  #232,frog_best_y

            ; Activate additional objects for new level
            bsr     activate_level_objects

            ; Play level-up sound
            bsr     play_score_sound

.not_complete:
            rts
