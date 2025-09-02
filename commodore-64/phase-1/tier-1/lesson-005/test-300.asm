; Test sprite at X=300 (needs MSB)
!to "test-300.prg", cbm

*=$0801
        !byte $0b,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*=$080d
main:
        ; Setup colors
        lda #$00
        sta $d021
        lda #$03
        sta $d020
        
        ; Deploy sprite
        lda #$0d
        sta $07f8
        
        ; Copy sprite pattern
        ldx #0
copy:
        lda #$ff
        sta $0340,x
        inx
        cpx #63
        bne copy
        
        ; Enable sprite
        lda #$01
        sta $d015
        lda #$01
        sta $d027
        
        ; Position at X=300 (300-256=44, MSB=1)
        lda #44             ; 300-256=44
        sta $d000
        lda #100
        sta $d001
        lda #$01            ; MSB set
        sta $d010
        
        ; Show "300" on screen
        lda #3
        sta $0400+10*40+10
        lda #0
        sta $0400+10*40+11
        lda #0
        sta $0400+10*40+12
        
loop:
        jmp loop