            bsr     penglyph
            move.w  #BLEAT_PER1,d0      ; A contented sound
            move.w  #BLEAT_PER2,d1
            move.w  #BLEAT_FRAMES,d2
            move.w  #BLEAT_VOL,d3
            tst.w   isblack             ; ...unless she's the gamble —
            beq.s   .sing
            move.w  #CHIME_PER1,d0      ;   then the game's best sound
            move.w  #CHIME_PER2,d1
            move.w  #CHIME_FRAMES,d2
            move.w  #CHIME_VOL,d3
.sing:
            bsr     playsound
            add.w   #PEN_POINTS,score   ; A sheep safely home
            tst.w   isblack
            beq.s   .paid
            add.w   #BLACK_BONUS,score  ; The gamble pays
.paid:
