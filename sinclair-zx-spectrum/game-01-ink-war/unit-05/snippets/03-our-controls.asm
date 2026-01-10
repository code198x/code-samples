; Ink War uses these control keys:
;
; Q = Up      (ROW_Q_T, bit 0)
; A = Down    (ROW_A_G, bit 0)
; O = Left    (ROW_P_Y, bit 1)
; P = Right   (ROW_P_Y, bit 0)
; Space = Claim cell (ROW_SPC_B, bit 0)

; Check O (left) - note it's bit 1, not bit 0
        ld a, ROW_P_Y       ; P-Y row contains both O and P
        in a, (KEYBOARD_PORT)
        bit 1, a            ; O is bit 1
        jr nz, o_not_pressed
        ; O is pressed
o_not_pressed:
        bit 0, a            ; P is bit 0 (same read)
        jr nz, p_not_pressed
        ; P is pressed
p_not_pressed:
