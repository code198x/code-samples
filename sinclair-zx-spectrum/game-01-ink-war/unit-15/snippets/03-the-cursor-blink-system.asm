main_loop:
        halt

        ; Increment frame counter
        ld a, (frame_counter)
        inc a
        ld (frame_counter), a

        ; Update cursor blink
        call update_cursor_blink

        call check_keyboard

        jr main_loop
