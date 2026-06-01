; Score Display Constants
; 6-digit score in start zone using bitmap digits

; Score display position
SCORE_X         equ 256         ; Pixel X (byte-aligned for simplicity)
SCORE_Y         equ 236         ; Pixel Y (in start zone, row 12)

; Digit dimensions
DIGIT_H         equ 8           ; 8 pixels tall
NUM_DIGITS      equ 6           ; Display up to 999,999

; Points values
POINTS_PER_HOME equ 50

; Variables
score:          dc.l    0       ; 32-bit score (longword)
score_digits:   dc.w    0,0,0,0,0,0     ; Buffer for 6 digit values
