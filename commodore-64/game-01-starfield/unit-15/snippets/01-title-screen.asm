; Subroutine: show_title
; Writes "STARFIELD" and "PRESS FIRE" to screen RAM
show_title:
        ; "STARFIELD" at row 10, col 16 ($05A0)
        lda #$13            ; S
        sta $05a0
        lda #$14            ; T
        sta $05a1
        lda #$01            ; A
        sta $05a2
        lda #$12            ; R
        sta $05a3
        lda #$06            ; F
        sta $05a4
        lda #$09            ; I
        sta $05a5
        lda #$05            ; E
        sta $05a6
        lda #$0c            ; L
        sta $05a7
        lda #$04            ; D
        sta $05a8

        ; Colour to white
        lda #$01
        sta $d9a0
        sta $d9a1
        sta $d9a2
        sta $d9a3
        sta $d9a4
        sta $d9a5
        sta $d9a6
        sta $d9a7
        sta $d9a8

        ; "PRESS FIRE" at row 14, col 15 ($063F)
        lda #$10            ; P
        sta $063f
        lda #$12            ; R
        sta $0640
        lda #$05            ; E
        sta $0641
        lda #$13            ; S
        sta $0642
        lda #$13            ; S
        sta $0643
        lda #$20            ; (space)
        sta $0644
        lda #$06            ; F
        sta $0645
        lda #$09            ; I
        sta $0646
        lda #$12            ; R
        sta $0647
        lda #$05            ; E
        sta $0648

        ; Colour to light grey
        lda #$0f
        sta $da3f
        sta $da40
        sta $da41
        sta $da42
        sta $da43
        sta $da44
        sta $da45
        sta $da46
        sta $da47
        sta $da48

        rts
