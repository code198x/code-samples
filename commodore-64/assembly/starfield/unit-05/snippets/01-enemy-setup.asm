        ; Sprite 2 setup (enemy)
        lda #130
        sta $07fa           ; Data pointer (block 130 = $2080)
        lda #$05
        sta $d029           ; Colour (green)

        ; Enemy starting position
        lda #100
        sta enemy_x
        sta $d004           ; X position
        lda #$32
        sta enemy_y
        sta $d005           ; Y position

        ; Enable sprites 0 and 2 (bullet starts disabled)
        lda #%00000101
        sta $d015
