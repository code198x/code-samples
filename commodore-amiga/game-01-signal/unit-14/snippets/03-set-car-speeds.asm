;------------------------------------------------------------------------------
; SET_CAR_SPEEDS - Calculate car speeds based on current level
; Speed = base_speed + (level-1) * sign(base_speed)
; This adds 1 pixel/frame for each level above 1
;------------------------------------------------------------------------------
set_car_speeds:
            movem.l d0-d3/a0-a1,-(sp)

            move.w  level,d2
            subq.w  #1,d2                   ; d2 = level - 1 (speed increment)

            ; Cap the speed increment at MAX_LEVEL-1
            cmp.w   #MAX_LEVEL-1,d2
            ble.s   .speed_ok
            move.w  #MAX_LEVEL-1,d2
.speed_ok:

            lea     base_speeds,a0
            lea     car_data+4,a1           ; Point to first car's speed field
            moveq   #NUM_CARS-1,d3

.loop:
            move.w  (a0)+,d0                ; Get base speed
            tst.w   d0
            beq.s   .store                  ; Speed 0 stays 0
            bpl.s   .positive

            ; Negative speed (moving left) - subtract increment
            sub.w   d2,d0
            bra.s   .store

.positive:
            ; Positive speed (moving right) - add increment
            add.w   d2,d0

.store:
            move.w  d0,(a1)                 ; Store new speed
            addq.l  #CAR_STRUCT_SIZE,a1     ; Next car's speed field
            dbf     d3,.loop

            movem.l (sp)+,d0-d3/a0-a1
            rts
