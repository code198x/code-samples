; Simple BCD scoring
;
; Score stored as 3 bytes in BCD (Binary Coded Decimal)
; for easy display: each nibble is one digit (0-9).
;
; score_lo:  digits 0-1 (ones, tens)
; score_mid: digits 2-3 (hundreds, thousands)
; score_hi:  digits 4-5 (ten-thousands, hundred-thousands)

score_lo:       !byte 0
score_mid:      !byte 0
score_hi:       !byte 0

SCORE_PER_HIT   = $10           ; Add 10 points per hit (BCD!)

add_score:
                sed                     ; Set decimal mode
                clc
                lda score_lo
                adc #SCORE_PER_HIT
                sta score_lo
                lda score_mid
                adc #0
                sta score_mid
                lda score_hi
                adc #0
                sta score_hi
                cld                     ; Clear decimal mode
                rts

; To display: read each byte, split into nibbles, add $30 ('0')
; score_lo = $50 means "50", displayed as "5" and "0"
