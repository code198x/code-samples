.proc collect_item
    ; Increase score
    inc score

    ; Respawn item at new position
    ; For now, use a simple pattern based on score
    lda score
    asl a                   ; score × 2
    asl a                   ; score × 4
    asl a                   ; score × 8
    asl a                   ; score × 16
    clc
    adc #32                 ; offset from left edge
    sta item_x

    ; Y position: alternate high and low
    lda score
    and #%00000001          ; check if score is odd or even
    beq @high
    lda #160                ; odd: low on screen
    jmp @set_y
@high:
    lda #60                 ; even: high on screen
@set_y:
    sta item_y

    rts
.endproc
