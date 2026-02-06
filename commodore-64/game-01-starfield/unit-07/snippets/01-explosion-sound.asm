hit_enemy:
        ; Deactivate bullet
        lda #$00
        sta bullet_active
        lda $d015
        and #%11111101          ; Disable sprite 1 (bullet)
        sta $d015

        ; Flash enemy white
        lda #$01
        sta $d029               ; Sprite 2 colour = white

        ; Start flash timer
        lda #$08
        sta flash_timer         ; 8 frames of flash

        ; Explosion sound — SID voice 2 (noise)
        lda #$00
        sta $d407               ; Frequency low
        lda #$08
        sta $d408               ; Frequency high (low rumble)
        lda #$09
        sta $d40c               ; Attack=0, Decay=9
        lda #$00
        sta $d40d               ; Sustain=0, Release=0
        lda #$80
        sta $d40b               ; Noise, gate OFF (reset envelope)
        lda #$81
        sta $d40b               ; Noise, gate ON (trigger)
