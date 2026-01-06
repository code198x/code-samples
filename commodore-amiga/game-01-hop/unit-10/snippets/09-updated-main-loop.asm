main_loop:
            bsr     wait_vblank
            bsr     update_objects

            cmp.w   #STATE_ALIVE,frog_state
            bne.s   .skip_input

            bsr     read_joystick
            bsr     handle_movement
            bsr     check_home_zone         ; Check goal first
            bsr     handle_platform
            bsr     check_bounds_death
            bsr     check_car_death
            bsr     check_water_death
            bra.s   .draw

.skip_input:
            ; ...
