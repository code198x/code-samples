; Fill a specific row with a colour
; Address = $5800 + (row × 32)

        ; Row 5: address = $5800 + (5 × 32) = $5800 + 160 = $58A0
        ld hl, ATTR_START + (5 * 32)
        ld b, 32            ; 32 columns
        ld a, %00010000     ; Red paper, black ink
fill_loop:
        ld (hl), a          ; Write attribute
        inc hl              ; Next cell
        djnz fill_loop      ; Repeat 32 times
