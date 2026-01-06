;──────────────────────────────────────────────────────────────
; INK WAR
; A territory control game for the ZX Spectrum
; Unit 1: The Board
;──────────────────────────────────────────────────────────────

            org 32768

start:
            ; Set border to black
            ld a, 0
            out (254), a

            ; Clear screen using ROM routine
            call 3435           ; CLS

            ; Set permanent colours: white ink on black paper
            ld a, 7             ; White ink (7), black paper (0)
            ld (23693), a       ; ATTR_P system variable
