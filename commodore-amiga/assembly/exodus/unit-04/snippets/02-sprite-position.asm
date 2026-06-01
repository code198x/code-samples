;──────────────────────────────────────────────────────────────
; set_sprite_pos — Write position into sprite control words
;
; Reads CREATURE_X and CREATURE_Y constants.
; Writes VSTART, HSTART, VSTOP into sprite_data.
;──────────────────────────────────────────────────────────────
set_sprite_pos:
            lea     sprite_data,a0

            ; Convert to display coordinates
            ; Sprite HSTART is in low-res pixels + $80 (display window offset)
            ; Sprite VSTART/VSTOP are in scan lines + $2C (PAL display start)
            move.w  #CREATURE_Y+$2c,d0  ; VSTART (display line)
            move.w  #CREATURE_Y+$2c+SPRITE_HEIGHT,d1  ; VSTOP
            move.w  #CREATURE_X+$80,d2  ; HSTART (display pixel)

            ; Word 0: VSTART[7:0] in high byte, HSTART[8:1] in low byte
            move.b  d0,d3               ; D3 = VSTART low 8 bits
            lsl.w   #8,d3               ; Shift to high byte
            move.w  d2,d4
            lsr.w   #1,d4               ; HSTART >> 1
            or.b    d4,d3               ; Combine
            move.w  d3,(a0)+            ; Write control word 0

            ; Word 1: VSTOP[7:0] in high byte, control bits in low byte
            move.b  d1,d3               ; D3 = VSTOP low 8 bits
            lsl.w   #8,d3               ; Shift to high byte
            ; Low byte: bit 2 = VSTART[8], bit 1 = VSTOP[8], bit 0 = HSTART[0]
            moveq   #0,d4
            btst    #8,d0               ; Test VSTART bit 8
            beq.s   .no_vs8
            bset    #2,d4
.no_vs8:
            btst    #8,d1               ; Test VSTOP bit 8
            beq.s   .no_ve8
            bset    #1,d4
.no_ve8:
            btst    #0,d2               ; Test HSTART bit 0
            beq.s   .no_h0
            bset    #0,d4
.no_h0:
            or.b    d4,d3               ; Combine control bits
            move.w  d3,(a0)             ; Write control word 1

            rts
