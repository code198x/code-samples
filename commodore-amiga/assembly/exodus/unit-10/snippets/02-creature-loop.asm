            ; --- Process all creatures ---
            lea     creatures,a2
            moveq   #NUM_CREATURES-1,d7

.creature_loop:
            bsr     update_creature
            add.w   #CR_SIZE,a2
            dbra    d7,.creature_loop
