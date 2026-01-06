fill_home_slot:
            ; ... slot check code ...

            move.w  #1,SLOT_FILLED(a0)
            add.l   #SCORE_HOME,score

            bsr     play_score_sound    ; ADD THIS

            ; ... rest of routine ...
