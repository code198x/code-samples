reset:
    ; ... existing setup ...

    lda #3
    sta lives           ; start with 3 lives

    lda #0
    sta invuln_timer    ; not invulnerable at start
