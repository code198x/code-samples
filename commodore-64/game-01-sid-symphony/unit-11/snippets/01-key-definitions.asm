; Keyboard matrix positions for our game keys
;
; The C64 keyboard is an 8x8 matrix.
; To read a key: write column select to $DC00, read rows from $DC01.
; Active low: bit=0 means pressed.

KEYBOARD_COLUMN = $dc00         ; Write column select here
KEYBOARD_ROW    = $dc01         ; Read row state here

; X key: Column 2 (bit 2 = 0), Row 7 (bit 7)
KEY_X_COL       = %11111011     ; Select column 2
KEY_X_ROW       = %10000000     ; Check row 7

; C key: Column 2 (bit 2 = 0), Row 4 (bit 4)
KEY_C_COL       = %11111011     ; Select column 2
KEY_C_ROW       = %00010000     ; Check row 4

; V key: Column 3 (bit 3 = 0), Row 7 (bit 7)
KEY_V_COL       = %11110111     ; Select column 3
KEY_V_ROW       = %10000000     ; Check row 7

; State tracking
key_x_state:    !byte 0         ; 1 if held
key_c_state:    !byte 0
key_v_state:    !byte 0

key_x_pressed:  !byte 0         ; 1 if NEW press this frame
key_c_pressed:  !byte 0
key_v_pressed:  !byte 0
