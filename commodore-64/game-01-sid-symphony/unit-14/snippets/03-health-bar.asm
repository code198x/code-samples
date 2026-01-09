; Draw health bar (8 segments, each = 8 health points)
;
; Health 0-64 divided into 8 segments of 8 points each.
; health / 8 = number of filled segments.
; Simple right-shift division: LSR three times = /8

draw_health_bar:
                ; Calculate filled segments
                lda health
                lsr                     ; /2
                lsr                     ; /4
                lsr                     ; /8 = segments filled (0-8)
                sta health_segments

                ; Draw 8 segments
                ldx #0                  ; Segment counter
.loop:
                cpx health_segments
                bcs .draw_empty         ; X >= segments = empty

                ; Draw full segment (green)
                lda #HEALTH_FULL
                sta SCREEN + 21*40 + 20,x
                lda #COL_GREEN
                sta COLOUR + 21*40 + 20,x
                jmp .next

.draw_empty:
                ; Draw empty segment (dark grey)
                lda #HEALTH_EMPTY
                sta SCREEN + 21*40 + 20,x
                lda #COL_DARK_GREY
                sta COLOUR + 21*40 + 20,x

.next:
                inx
                cpx #8                  ; All 8 segments drawn?
                bne .loop
                rts

health_segments: !byte 0
