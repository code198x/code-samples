; Keyboard interaction probe. Outputs: old port2, old port1, released port2,
; released port1, reverse scan (PB1 low), all-input ports, forward row-0 scan.
*=$0801
!byte $0b,$08,$0a,0,$9e
!text "2064"
!byte 0,0,0
*=$0810
start:
 sei
 lda #$7f
 sta $dc0d
 sta $dd0d
 lda $dc0d
 lda $dd0d
 lda #$35
 sta $01
 lda #0
 sta $dc03
 sta $dc0e
 sta $dc0f
 lda #$ff
 sta $dc02
 sta $dc00
ready:
 lda request
 beq ready
probe:
 jsr read_joystick
 sta observed
 jsr read_joystick1
 sta observed+1
 lda #$ff
 sta $dc00
 lda $dc00
 eor #$ff
 and #$1f
 sta observed+2
 lda $dc01
 eor #$ff
 and #$1f
 sta observed+3
 lda #$fe
 sta $dc00
 lda $dc01
 eor #$ff
 and #$1f
 sta observed+6
 lda #$ff
 sta $dc00
 lda #$fd
 sta $dc01
 lda #$ff
 sta $dc03
 lda #0
 sta $dc02
 lda $dc00
 eor #$ff
 and #$1f
 sta observed+4
 lda #0
 sta $dc03
 sta $dc00
 lda $dc01
 eor #$ff
 and #$1f
 sta observed+5
done:
 jmp done
request: !byte 0
observed: !fill 7,0
!source "baseline2.inc"
!source "baseline1.inc"
