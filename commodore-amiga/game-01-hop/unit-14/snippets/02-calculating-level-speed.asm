get_speed_multiplier:
; Returns d0 = speed multiplier (16 = 1.0x)
            move.w  level,d0
            subq.w  #1,d0           ; Level 1 = multiplier of 16
            mulu    #SPEED_INCREASE,d0
            addi.w  #16,d0

            ; Cap at maximum
            cmpi.w  #MAX_SPEED_MULT,d0
            ble.s   .no_cap
            move.w  #MAX_SPEED_MULT,d0
.no_cap:
            rts
