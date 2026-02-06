        ; --- Check bullet-enemy collision ---
        lda bullet_active
        beq no_hit              ; No bullet, skip

        ; Check Y distance
        lda bullet_y
        sec
        sbc enemy_y
        cmp #$10                ; Within 16 pixels? (positive direction)
        bcc y_close
        cmp #$f0                ; Within 16 pixels? (negative/wrapped)
        bcc no_hit              ; Too far apart
y_close:
        ; Check X distance
        lda $d002               ; Bullet X
        sec
        sbc enemy_x
        cmp #$10                ; Within 16 pixels? (positive direction)
        bcc hit_enemy
        cmp #$f0                ; Within 16 pixels? (negative/wrapped)
        bcc no_hit              ; Too far apart

hit_enemy:
        ; Deactivate bullet
        lda #$00
        sta bullet_active
        lda $d015
        and #%11111101          ; Disable sprite 1 (bullet)
        sta $d015

        ; Respawn enemy at top
        lda #$32
        sta enemy_y
        sta $d005
        lda $d012               ; New random X
        and #$7f
        clc
        adc #$30
        sta enemy_x
        sta $d004

no_hit:
