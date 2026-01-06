.proc move_enemies
    ldx #0                  ; Start with enemy 0
@loop:
    ; Move enemy down (increment Y)
    inc enemy_y, x

    ; Check if off bottom of screen
    lda enemy_y, x
    cmp #232                ; Past visible area?
    bcc @next               ; No - continue

    ; Wrap to top
    lda #0
    sta enemy_y, x

@next:
    inx                     ; Next enemy
    cpx #4                  ; All 4 done?
    bne @loop               ; No - loop
    rts
.endproc
