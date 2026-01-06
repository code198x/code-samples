main_loop:
            bsr     wait_vblank

            ; Always update world objects
            bsr     update_objects

            ; Check game state
            cmp.w   #STATE_ALIVE,frog_state
            bne.s   .skip_input

            ; Only process input when alive
            bsr     read_joystick
            bsr     handle_movement
            bsr     handle_platform
            bsr     check_car_death
            bsr     check_water_death

            bra.s   .draw

.skip_input:
            ; Handle death sequence
            bsr     update_death

.draw:
            bsr     update_frog_sprite
            bsr     draw_objects

            bra     main_loop
