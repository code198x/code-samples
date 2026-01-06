main_loop:
        halt

        ; Increment frame counter (wraps at 256)
        ld a, (frame_counter)
        inc a
        ld (frame_counter), a

        call check_keyboard

        jr main_loop
