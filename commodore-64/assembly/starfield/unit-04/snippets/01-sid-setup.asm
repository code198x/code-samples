        ; SID setup — voice 1 laser sound
        lda #$0f
        sta $d418           ; Volume to maximum

        lda #$00
        sta $d400           ; Frequency low byte
        lda #$10
        sta $d401           ; Frequency high byte ($1000 = mid-high pitch)

        lda #$09
        sta $d405           ; Attack=0, Decay=9
        lda #$00
        sta $d406           ; Sustain=0, Release=0
