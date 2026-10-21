*=$f000
FC=$0070
start:
    sei
    cld
    ldx #$ff
    txs
    lda #10
    sta $e880
    lda #$20
    sta $e881
    ldx #0
    lda #32
clear_screen:
    sta $8000,x
    sta $8100,x
    sta $8200,x
    sta $8300,x
    inx
    bne clear_screen
case_0:
    lda #<pictures
    sta FC+0
    lda #>pictures
    sta FC+1
    lda #2
    sta FC+2
    lda #0
    sta FC+3
    lda #6
    sta FC+4
    jsr character_span
    lda FC+5
    ora #128
    sta $0090
case_1:
    lda #<pictures
    sta FC+0
    lda #>pictures
    sta FC+1
    lda #0
    sta FC+2
    lda #1
    sta FC+3
    lda #40
    sta FC+4
    jsr character_span
    lda FC+5
    ora #128
    sta $0091
case_2:
    lda #<pictures
    sta FC+0
    lda #>pictures
    sta FC+1
    lda #39
    sta FC+2
    lda #2
    sta FC+3
    lda #1
    sta FC+4
    jsr character_span
    lda FC+5
    ora #128
    sta $0092
case_3:
    lda #<pictures
    sta FC+0
    lda #>pictures
    sta FC+1
    lda #0
    sta FC+2
    lda #24
    sta FC+3
    lda #1
    sta FC+4
    jsr character_span
    lda FC+5
    ora #128
    sta $0093
case_4:
    lda #<pictures
    sta FC+0
    lda #>pictures
    sta FC+1
    lda #40
    sta FC+2
    lda #0
    sta FC+3
    lda #1
    sta FC+4
    jsr character_span
    lda FC+5
    ora #128
    sta $0094
case_5:
    lda #<pictures
    sta FC+0
    lda #>pictures
    sta FC+1
    lda #0
    sta FC+2
    lda #25
    sta FC+3
    lda #1
    sta FC+4
    jsr character_span
    lda FC+5
    ora #128
    sta $0095
case_6:
    lda #<pictures
    sta FC+0
    lda #>pictures
    sta FC+1
    lda #0
    sta FC+2
    lda #0
    sta FC+3
    lda #0
    sta FC+4
    jsr character_span
    lda FC+5
    ora #128
    sta $0096
case_7:
    lda #<pictures
    sta FC+0
    lda #>pictures
    sta FC+1
    lda #39
    sta FC+2
    lda #0
    sta FC+3
    lda #2
    sta FC+4
    jsr character_span
    lda FC+5
    ora #128
    sta $0097
case_8:
    lda #<pictures
    sta FC+0
    lda #>pictures
    sta FC+1
    lda #255
    sta FC+2
    lda #0
    sta FC+3
    lda #2
    sta FC+4
    jsr character_span
    lda FC+5
    ora #128
    sta $0098
case_9:
    lda #<pictures
    sta FC+0
    lda #>pictures
    sta FC+1
    lda #0
    sta FC+2
    lda #255
    sta FC+3
    lda #1
    sta FC+4
    jsr character_span
    lda FC+5
    ora #128
    sta $0099
case_10:
    lda #<pictures
    sta FC+0
    lda #>pictures
    sta FC+1
    lda #0
    sta FC+2
    lda #0
    sta FC+3
    lda #255
    sta FC+4
    jsr character_span
    lda FC+5
    ora #128
    sta $009a
    lda #239
    sta $00af
done:
    jmp done
    !source "characters.inc"
pictures:
    !byte 1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6
    !fill $fffc-*,0
    !word start,start
