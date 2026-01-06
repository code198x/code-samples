;───────────────────────────────────────
; Claim the current cell
;───────────────────────────────────────
claim_cell:
        ; Get board state for current position
        ld a, (cursor_y)
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_board_addr

        ; Check if neutral
        ld a, (hl)
        or a
        ret nz                  ; Not neutral - can't claim

        ; Claim it!
        ld a, (current_player)
        ld (hl), a

        ; Update screen colour
        call set_cell_colour

        ret
