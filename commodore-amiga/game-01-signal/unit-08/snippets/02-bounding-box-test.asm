; Bounding Box Collision Test
; AABB overlap: two boxes collide if all four edges overlap

check_collision:
            ; Only check if frog is on a road row
            move.w  frog_grid_y,d0
            cmp.w   #ROAD_ROW_FIRST,d0
            blt     .no_collision
            cmp.w   #ROAD_ROW_LAST,d0
            bgt     .no_collision

            ; Frog is on road - check against all cars
            lea     car_data,a2
            moveq   #NUM_CARS-1,d7

.loop:
            ; Check if car is in same row
            move.w  2(a2),d1            ; Car row
            cmp.w   d0,d1
            bne.s   .next_car

            ; Same row - check X overlap using AABB test
            move.w  frog_pixel_x,d2     ; Frog X
            move.w  (a2),d3             ; Car X

            ; Test 1: frog_right > car_left
            move.w  d2,d4
            add.w   #FROG_WIDTH,d4      ; d4 = frog right edge
            cmp.w   d3,d4
            ble.s   .next_car           ; Frog right <= car left: no collision

            ; Test 2: car_right > frog_left
            move.w  d3,d4
            add.w   #CAR_WIDTH_PX,d4    ; d4 = car right edge
            cmp.w   d2,d4
            ble.s   .next_car           ; Car right <= frog left: no collision

            ; COLLISION! Both tests passed
            bsr     trigger_death
            bra.s   .no_collision       ; Exit early

.next_car:
            lea     CAR_STRUCT_SIZE(a2),a2
            dbf     d7,.loop

.no_collision:
            rts
