; Simple sprite position test
!to "simple-test.prg", cbm

*=$0801
        !byte $0b,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*=$080d
main:
        ; Setup colors
        lda #$00
        sta $d021
        lda #$03
        sta $d020
        
        ; Deploy sprite at memory bank 13
        lda #$0d
        sta $07f8
        
        ; Copy simple sprite pattern
        ldx #0
copy:
        lda #$ff            ; Solid block
        sta $0340,x
        inx
        cpx #63
        bne copy
        
        ; Enable sprite 0
        lda #$01
        sta $d015
        lda #$01            ; White sprite
        sta $d027
        
        ; Position sprite at X=200, Y=100
        lda #200
        sta $d000
        lda #100
        sta $d001
        lda #$00            ; No MSB needed for X=200
        sta $d010
        
        ; Show "200" on screen (just put raw values)
        lda #2
        sta $0400+10*40+10
        lda #0
        sta $0400+10*40+11
        lda #0
        sta $0400+10*40+12
        
loop:
        jmp loop            ; Infinite loop