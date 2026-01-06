;───────────────────────────────────────
; Set cell colour based on current_player
;───────────────────────────────────────
set_cell_colour:
        ; Get colour for current player
        ld a, (current_player)
        cp 1
        jr z, .red
        ld a, CYAN_ON_CYAN
        jr .got_colour
.red:
        ld a, RED_ON_RED
.got_colour:
        ld b, a                 ; Save colour in B

        ; Get attribute address
        push bc
        ld a, (cursor_y)
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_cell_addr
        pop bc                  ; B = colour

        ; Write to all 4 attribute bytes
        ld (hl), b
        inc hl
        ld (hl), b
        ld de, 31
        add hl, de
        ld (hl), b
        inc hl
        ld (hl), b

        ret
