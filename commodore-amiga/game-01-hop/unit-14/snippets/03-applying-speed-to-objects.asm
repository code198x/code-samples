update_objects:
            bsr     get_speed_multiplier
            move.w  d0,d6           ; Save multiplier

            lea     objects,a0
            moveq   #7,d7

.obj_loop:
            move.w  OBJ_TYPE(a0),d0
            beq.s   .next_obj

            ; Calculate scaled speed
            move.w  OBJ_SPEED(a0),d1
            ; Handle negative speeds
            tst.w   d1
            bmi.s   .neg_speed

            ; Positive speed
            mulu    d6,d1
            lsr.w   #4,d1           ; Divide by 16
            bra.s   .apply_speed

.neg_speed:
            ; For negative, negate, scale, negate back
            neg.w   d1
            mulu    d6,d1
            lsr.w   #4,d1
            neg.w   d1

.apply_speed:
            add.w   d1,OBJ_X(a0)

            ; Wrap logic (unchanged)
            move.w  OBJ_X(a0),d0
            cmpi.w  #-32,d0
            bge.s   .check_right
            move.w  #320,OBJ_X(a0)
            bra.s   .next_obj
.check_right:
            cmpi.w  #320,d0
            ble.s   .next_obj
            move.w  #-32,OBJ_X(a0)

.next_obj:
            lea     OBJ_SIZE(a0),a0
            dbf     d7,.obj_loop
            rts
