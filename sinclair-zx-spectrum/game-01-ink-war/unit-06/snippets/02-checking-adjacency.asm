;───────────────────────────────────────
; Check if cursor is adjacent to current player's territory
; Output: Z flag set if valid (adjacent), NZ if invalid
;───────────────────────────────────────
check_adjacency:
        ; Check Up (y-1)
        ld a, (cursor_y)
        or a
        jr z, .skip_up          ; At top edge - no neighbour above

        dec a
        ld b, a                 ; B = y-1
        ld a, (cursor_x)
        ld c, a                 ; C = x
        call get_owner
        ld b, a                 ; B = owner of cell above
        ld a, (current_player)
        cp b
        ret z                   ; Match! Z flag set = valid

.skip_up:
        ; Check Down (y+1)
        ld a, (cursor_y)
        cp 7
        jr z, .skip_down        ; At bottom edge - no neighbour below

        inc a
        ld b, a                 ; B = y+1
        ld a, (cursor_x)
        ld c, a
        call get_owner
        ld b, a
        ld a, (current_player)
        cp b
        ret z

.skip_down:
        ; Check Left (x-1)
        ld a, (cursor_x)
        or a
        jr z, .skip_left        ; At left edge

        dec a
        ld c, a                 ; C = x-1
        ld a, (cursor_y)
        ld b, a                 ; B = y
        call get_owner
        ld b, a
        ld a, (current_player)
        cp b
        ret z

.skip_left:
        ; Check Right (x+1)
        ld a, (cursor_x)
        cp 7
        jr z, .skip_right       ; At right edge

        inc a
        ld c, a                 ; C = x+1
        ld a, (cursor_y)
        ld b, a
        call get_owner
        ld b, a
        ld a, (current_player)
        cp b
        ret z

.skip_right:
        ; No adjacent territory found
        or 1                    ; Clear Z flag (NZ = invalid)
        ret
