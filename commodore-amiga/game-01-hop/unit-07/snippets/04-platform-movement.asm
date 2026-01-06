handle_platform:
            ; Check if in water zone
            move.w  frog_y,d0
            cmp.w   #WATER_TOP,d0
            blt.s   .done
            cmp.w   #WATER_BOT,d0
            bge.s   .done

            ; In water - check if on a log
            bsr.s   check_on_log
            tst.w   d0
            beq.s   .done               ; Not on log (death later)

            ; On a log - apply log speed
            add.w   d0,frog_x

            ; Clamp to screen
            tst.w   frog_x
            bpl.s   .check_right
            clr.w   frog_x
            bra.s   .done
.check_right:
            cmp.w   #MAX_X,frog_x
            ble.s   .done
            move.w  #MAX_X,frog_x
.done:      rts
