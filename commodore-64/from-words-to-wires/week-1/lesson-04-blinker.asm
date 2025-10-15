        !to "blinker.prg",cbm
        * = $C000

BLINKER  LDA #$0F
         STA $D021        ; border to light blue
         LDY #$10
.loop    LDA COLORS,Y
         STA $D020        ; sprite/border colour
         JSR Delay
         DEY
         BPL .loop
         RTS

Delay    LDX #$FF
.d1      LDY #$FF
.d2      DEY
         BNE .d2
         DEX
         BNE .d1
         RTS

COLORS   !byte $00,$06,$07,$0E,$0B,$0C,$01,$02,$04,$05,$08,$09,$0A,$03,$0D,$0F
