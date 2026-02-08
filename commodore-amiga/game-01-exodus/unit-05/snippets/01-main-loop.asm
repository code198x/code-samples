            ; === Main Loop ===
mainloop:
            ; Wait for vertical blank
            move.l  #$1ff00,d1
.vbwait:
            move.l  VPOSR(a5),d0
            and.l   d1,d0
            bne.s   .vbwait

            ; --- Update creature position ---
            move.w  creature_x,d0
            add.w   #CREATURE_SPEED,d0
            move.w  d0,creature_x

            ; --- Update sprite control words ---
            bsr     update_sprite

            ; --- Check exit ---
            btst    #6,$bfe001
            bne.s   mainloop
