; Performance rating based on BCD score
;
; Rating thresholds (16 notes at 100 points each = 1600 max):
;   0000-0499  = POOR    (< 5 hits)
;   0500-0999  = GOOD    (5-9 hits)
;   1000-1499  = GREAT   (10-14 hits)
;   1500+      = PERFECT (15-16 hits)
;
; We check score+1 (the hundreds/thousands byte in BCD)

show_rating:
                ; Compare score+1 against thresholds
                lda score+1
                cmp #$15                ; >= $15 = 1500+ ?
                bcs .perfect
                cmp #$10                ; >= $10 = 1000+ ?
                bcs .great
                cmp #$05                ; >= $05 = 500+ ?
                bcs .good

                ; POOR rating (red)
                ldx #0
-               lda rating_poor,x
                beq .done
                sta SCREEN + 14*40 + 16,x
                lda #COL_RED
                sta COLOUR + 14*40 + 16,x
                inx
                bne -
                rts

.good:
                ; GOOD rating (yellow)
                ldx #0
-               lda rating_good,x
                beq .done
                sta SCREEN + 14*40 + 16,x
                lda #COL_YELLOW
                sta COLOUR + 14*40 + 16,x
                inx
                bne -
                rts

.great:
                ; GREAT rating (green)
                ldx #0
-               lda rating_great,x
                beq .done
                sta SCREEN + 14*40 + 16,x
                lda #COL_GREEN
                sta COLOUR + 14*40 + 16,x
                inx
                bne -
                rts

.perfect:
                ; PERFECT rating (cyan)
                ldx #0
-               lda rating_perfect,x
                beq .done
                sta SCREEN + 14*40 + 15,x
                lda #COL_CYAN
                sta COLOUR + 14*40 + 15,x
                inx
                bne -

.done:
                rts

rating_poor:    !scr "poor"
                !byte 0
rating_good:    !scr "good"
                !byte 0
rating_great:   !scr "great"
                !byte 0
rating_perfect: !scr "perfect!"
                !byte 0
