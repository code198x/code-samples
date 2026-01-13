; ----------------------------------------------------------------------------
; Initialise Screen
; ----------------------------------------------------------------------------
; Clears the screen to black and sets border colour

init_screen:
            ; Set border to black
            xor     a               ; A = 0 (black)
            out     (KEY_PORT), a   ; Set border colour

            ; Clear attributes to black
            ld      hl, ATTR_BASE   ; Start of attributes
            ld      de, ATTR_BASE+1
            ld      bc, 767         ; 768 bytes - 1
            ld      (hl), 0         ; Black on black
            ldir                    ; Fill all attributes

            ret
