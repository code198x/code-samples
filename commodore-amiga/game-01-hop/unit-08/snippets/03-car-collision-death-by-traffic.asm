; Check for car collisions
; Kills frog if hit
check_car_death:
            ; Only check if alive
            tst.w   frog_state
            bne.s   .done

            lea     objects,a0
            move.w  #NUM_OBJECTS-1,d7

.loop:
            ; Skip if not a car
            move.w  OBJ_TYPE(a0),d0
            cmp.w   #TYPE_CAR,d0
            bne.s   .next

            ; Check collision
            bsr     check_collision
            tst.w   d0
            bne.s   .hit_car

.next:
            add.w   #OBJ_SIZE,a0
            dbf     d7,.loop
.done:
            rts

.hit_car:
            bsr     kill_frog
            rts
