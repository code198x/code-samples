        ; Tell VIC-II where sprite 0's graphic data lives
        ; Block number = address / 64.  $2000 / 64 = 128.
        lda #128
        sta $07f8           ; Sprite 0 data pointer

        ; Position sprite 0 near centre-bottom of screen
        lda #172            ; X position
        sta $d000           ; Sprite 0 X position
        lda #220            ; Y position
        sta $d001           ; Sprite 0 Y position

        ; Set sprite 0 colour to white
        lda #$01
        sta $d027           ; Sprite 0 colour

        ; Enable sprite 0
        lda #%00000001      ; Bit 0 = sprite 0
        sta $d015           ; Sprite enable register
