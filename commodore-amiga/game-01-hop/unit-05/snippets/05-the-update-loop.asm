update_cars:
            lea     cars,a2
            move.w  #NUM_CARS-1,d7
.loop:
            ; Clear old position
            move.w  CAR_X(a2),d0
            move.w  CAR_Y(a2),d1
            bsr     clear_object

            ; Update position
            move.w  CAR_SPEED(a2),d0
            add.w   d0,CAR_X(a2)

            ; Wrap at screen edges
            move.w  CAR_X(a2),d0
            bsr     wrap_x

            ; Draw new position
            move.w  CAR_X(a2),d0
            move.w  CAR_Y(a2),d1
            bsr     draw_car

            ; Next car
            lea     CAR_SIZE(a2),a2
            dbf     d7,.loop
            rts
