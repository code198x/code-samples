checksquash:
            tst.w   squashtimer         ; Already mid-beat?
            beq.s   .watch
            subq.w  #1,squashtimer      ; Count the stillness down
            rts
.watch:
            move.w  CLXDAT(a5),d0       ; Read once — this clears it
            btst    #9,d0               ; Sprite 0/1 met sprite 2/3?
            beq.s   .safe
            ; --- Squashed. Back to the start of the field. ---
            move.w  #SHEEP_X,sheepx
            move.w  #SHEEP_Y,sheepy
            move.w  #SQUASH_BEAT,squashtimer
.safe:
            rts
