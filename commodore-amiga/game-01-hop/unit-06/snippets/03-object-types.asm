draw_object:
            tst.w   OBJ_TYPE(a2)
            beq.s   .is_car
            ; It's a log
            lea     log_gfx,a3
            bra.s   .draw
.is_car:
            lea     car_gfx,a3
.draw:
            ; Blit from A3 to screen...
