; ------------------------------------------------
; Subroutine: show_game_over
; Writes "GAME OVER" to screen RAM, row 12, col 16
; ------------------------------------------------
show_game_over:
        ; Screen codes: G=7, A=1, M=13, E=5, space=32, O=15, V=22, E=5, R=18
        ; Position: row 12 × 40 + col 16 = 496 → $0400 + $01F0 = $05F0
        lda #$07            ; G
        sta $05f0
        lda #$01            ; A
        sta $05f1
        lda #$0d            ; M
        sta $05f2
        lda #$05            ; E
        sta $05f3
        lda #$20            ; (space)
        sta $05f4
        lda #$0f            ; O
        sta $05f5
        lda #$16            ; V
        sta $05f6
        lda #$05            ; E
        sta $05f7
        lda #$12            ; R
        sta $05f8

        ; Colour to white
        lda #$01
        sta $d9f0
        sta $d9f1
        sta $d9f2
        sta $d9f3
        sta $d9f4
        sta $d9f5
        sta $d9f6
        sta $d9f7
        sta $d9f8

        rts
