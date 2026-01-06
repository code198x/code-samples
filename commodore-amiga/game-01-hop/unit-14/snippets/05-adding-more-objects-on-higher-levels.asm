activate_level_objects:
            bsr     get_active_objects
            move.w  d0,d7
            subq.w  #1,d7           ; For dbf

            lea     objects,a0
            moveq   #0,d0           ; Object index

.check_loop:
            cmp.w   d0,d7
            blt.s   .done

            ; If this slot is empty, activate it
            tst.w   OBJ_TYPE(a0)
            bne.s   .skip

            ; Spawn a new object based on position
            ; Alternate between cars and logs
            btst    #0,d0
            beq.s   .spawn_car

            ; Spawn log
            move.w  #TYPE_LOG,OBJ_TYPE(a0)
            ; Random X position
            bsr     random
            andi.w  #$FF,d0
            add.w   #32,d0
            move.w  d0,OBJ_X(a0)
            ; Y position based on slot
            move.w  #80,OBJ_Y(a0)   ; River area
            move.w  #1,OBJ_SPEED(a0)
            bra.s   .skip

.spawn_car:
            move.w  #TYPE_CAR,OBJ_TYPE(a0)
            bsr     random
            andi.w  #$FF,d0
            add.w   #32,d0
            move.w  d0,OBJ_X(a0)
            move.w  #192,OBJ_Y(a0)  ; Road area
            move.w  #-2,OBJ_SPEED(a0)

.skip:
            addq.w  #1,d0
            lea     OBJ_SIZE(a0),a0
            bra.s   .check_loop

.done:
            rts
