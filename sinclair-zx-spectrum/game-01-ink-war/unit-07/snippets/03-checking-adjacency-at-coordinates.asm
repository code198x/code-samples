;───────────────────────────────────────
; Check if cell (B,C) is adjacent to current player's territory
; Input: B = y, C = x
; Output: Z flag set if valid (adjacent), NZ if invalid
;───────────────────────────────────────
check_adjacency_at:
        push bc

        ; Check Up (y-1)
        ld a, b
        or a
        jr z, .skip_up          ; At top edge

        dec a
        ld b, a
        call get_owner
        ld e, a
        ld a, (current_player)
        cp e
        jr z, .found            ; Match!

.skip_up:
        pop bc
        push bc

        ; Check Down (y+1)
        ld a, b
        cp 7
        jr z, .skip_down        ; At bottom edge

        inc a
        ld b, a
        call get_owner
        ld e, a
        ld a, (current_player)
        cp e
        jr z, .found

.skip_down:
        pop bc
        push bc

        ; Check Left (x-1)
        ld a, c
        or a
        jr z, .skip_left        ; At left edge

        dec a
        ld c, a
        call get_owner
        ld e, a
        ld a, (current_player)
        cp e
        jr z, .found

.skip_left:
        pop bc
        push bc

        ; Check Right (x+1)
        ld a, c
        cp 7
        jr z, .skip_right       ; At right edge

        inc a
        ld c, a
        call get_owner
        ld e, a
        ld a, (current_player)
        cp e
        jr z, .found

.skip_right:
        pop bc
        ; No adjacent territory found
        or 1                    ; Clear Z flag
        ret

.found:
        pop bc
        xor a                   ; Set Z flag
        ret
