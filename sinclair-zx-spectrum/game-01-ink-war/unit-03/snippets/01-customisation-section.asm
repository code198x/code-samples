; ============================================================================
; CUSTOMISATION SECTION - Change these values to personalise your game!
; ============================================================================

; Attribute format: %FBPPPIII
;   F = Flash (bit 7): 1 = flashing
;   B = Bright (bit 6): 1 = brighter colours
;   PPP = Paper colour (bits 5-3): background
;   III = Ink colour (bits 2-0): foreground
;
; Colour values (0-7):
;   0=Black, 1=Blue, 2=Red, 3=Magenta, 4=Green, 5=Cyan, 6=Yellow, 7=White

; Empty cells - CUSTOMISED: cyan instead of white
;   %01101000 = BRIGHT + Paper 5 (cyan) + Ink 0 (black)
EMPTY_ATTR  equ     %01101000       ; Cyan paper, black ink + BRIGHT

; Board border - CUSTOMISED: yellow border around playing area
;   %01110000 = BRIGHT + Paper 6 (yellow) + Ink 0 (black)
BORDER_ATTR equ     %01110000       ; Yellow paper, black ink + BRIGHT

; Cursor - CUSTOMISED: bright white instead of flashing
;   %01111000 = BRIGHT + Paper 7 (white) + Ink 0 (black)
CURSOR_ATTR equ     %01111000       ; White paper + BRIGHT (no flash)
