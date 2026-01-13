; Move All Cars with Screen Wrapping
; Update each car's X position, wrap at screen edges

move_all_cars:
            lea     car_data,a2
            moveq   #NUM_CARS-1,d7

.loop:
            move.w  (a2),d0             ; X position
            move.w  4(a2),d1            ; Speed (signed)
            add.w   d1,d0               ; Move

            ; --- Wrap at screen edges ---
            tst.w   d1                  ; Check direction
            bmi.s   .check_left

            ; Moving right: wrap when past right edge
            cmp.w   #320,d0
            blt.s   .store
            sub.w   #320+32,d0          ; Wrap from right to left
            bra.s   .store

.check_left:
            ; Moving left: wrap when past left edge
            cmp.w   #-32,d0
            bgt.s   .store
            add.w   #320+32,d0          ; Wrap from left to right

.store:
            move.w  d0,(a2)             ; Store new X

            lea     CAR_STRUCT_SIZE(a2),a2
            dbf     d7,.loop
            rts
