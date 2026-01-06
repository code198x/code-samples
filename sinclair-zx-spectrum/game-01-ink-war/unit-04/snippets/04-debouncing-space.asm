space_held:     defb 0          ; 0 = released, 1 = held

;───────────────────────────────────────
; Check SPACE with edge detection
; Returns: Z if just pressed (edge), NZ otherwise
;───────────────────────────────────────
check_space_edge:
        ld bc, $7ffe
        in a, (c)
        bit 0, a
        jr nz, .released

        ; SPACE is down - was it already?
        ld a, (space_held)
        or a
        jr nz, .already_held    ; Yes - ignore

        ; First frame of press
        ld a, 1
        ld (space_held), a
        xor a                   ; Set Z flag (pressed)
        ret

.already_held:
        or 1                    ; Clear Z flag
        ret

.released:
        xor a
        ld (space_held), a      ; Mark as released
        or 1                    ; Clear Z flag
        ret
