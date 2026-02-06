; Zero-page variables
bullet_active = $02     ; 0 = no bullet, 1 = active
bullet_y      = $03     ; Bullet Y position

; ... (inside initialisation)

        ; Sprite 1 setup (bullet)
        lda #129
        sta $07f9           ; Data pointer (block 129 = $2040)
        lda #$07
        sta $d028           ; Colour (yellow)

        ; Enable sprite 0 only (bullet starts disabled)
        lda #%00000001
        sta $d015

        ; Bullet starts inactive
        lda #$00
        sta bullet_active
