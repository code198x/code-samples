        ; --- Fire button (bit 4) ---
        lda $dc00
        and #%00010000
        bne no_fire         ; Bit is 1 = NOT pressed

        ; Fire is pressed — only spawn if no bullet active
        lda bullet_active
        bne no_fire         ; Already active, skip

        ; Spawn bullet at ship position
        lda $d000           ; Ship X → bullet X
        sta $d002
        lda $d001           ; Ship Y → bullet Y
        sta bullet_y

        ; Enable sprite 1 (keep sprite 0 enabled)
        lda $d015
        ora #%00000010
        sta $d015

        ; Mark bullet active
        lda #$01
        sta bullet_active

no_fire:
