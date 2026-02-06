        ; --- Update bullet ---
        lda bullet_active
        beq no_bullet       ; Not active, skip

        ; Move bullet up (4 pixels per frame)
        lda bullet_y
        sec
        sbc #$04
        sta bullet_y
        sta $d003           ; Update sprite 1 Y position

        ; Check if bullet has left the screen (Y < 30)
        cmp #$1e
        bcs no_bullet       ; Y >= 30, still on screen

        ; Deactivate bullet
        lda #$00
        sta bullet_active

        ; Disable sprite 1 (keep sprite 0 enabled)
        lda $d015
        and #%11111101
        sta $d015

no_bullet:
