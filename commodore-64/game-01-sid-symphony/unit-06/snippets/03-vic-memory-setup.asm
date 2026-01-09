; Point VIC-II to our custom character set
;
; $D018 (VIC memory setup register):
;   Bits 1-3: Character memory location (multiply by $0800)
;   Bits 4-7: Screen memory location (multiply by $0400)
;
; For screen at $0400 and characters at $3000:
;   Screen: $0400 / $0400 = 1, so bits 4-7 = %0001
;   Chars:  $3000 / $0800 = 6, so bits 1-3 = %110
;
; Combined value: (1 << 4) | (6 << 1) = $10 | $0C = $1C

VIC_MEMSETUP    = $d018

point_vic_to_charset:
                lda #$1c            ; Screen at $0400, chars at $3000
                sta VIC_MEMSETUP
                rts

; Common configurations:
; $14 = Screen $0400, Chars $1000 (default)
; $15 = Screen $0400, Chars $1800
; $1C = Screen $0400, Chars $3000 (our setup)
; $1E = Screen $0400, Chars $3800
