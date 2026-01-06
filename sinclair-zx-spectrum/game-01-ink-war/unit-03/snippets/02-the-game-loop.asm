main_loop:
        halt                    ; Wait for interrupt (1/50th second)

        ; Debounce: only check keys every N frames
        ld a, (move_delay)
        dec a
        ld (move_delay), a
        jr nz, main_loop        ; Not time yet

        ; Reset delay counter
        ld a, 8                 ; Check every 8 frames (~6 moves/sec)
        ld (move_delay), a

        ; Check keyboard and move
        call check_keyboard

        jr main_loop
