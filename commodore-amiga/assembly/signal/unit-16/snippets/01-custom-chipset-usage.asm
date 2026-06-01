; Phase 1 Custom Chipset Summary
; ==============================

; AGNUS (Blitter)
; ---------------
; Used for: car drawing, screen clearing, digit rendering
move.w  #$0100,BLTCON0(a5)          ; Clear mode (D = 0)
move.w  #$09f0,BLTCON0(a5)          ; Copy mode (D = A)

; DENISE (Display)
; ----------------
; Used for: bitplane display, sprites, colours
            dc.w    $0100,$1200     ; 1 bitplane, colour enabled
            dc.w    $0182,COLOUR_CAR ; Colour 1 = red for cars
            dc.w    $01a2,COLOUR_FROG ; Sprite colour 1 = green

; PAULA (Audio)
; -------------
; Used for: hop, death, home sounds
move.l  a0,AUD0LC(a5)               ; Sample address
move.w  d1,AUD0LEN(a5)              ; Sample length in words
move.w  d2,AUD0PER(a5)              ; Period (pitch)
move.w  #64,AUD0VOL(a5)             ; Volume
move.w  #$8001,DMACON(a5)           ; Enable audio DMA

; COPPER (Display Processor)
; --------------------------
; Used for: zone colours, sprite pointers
            dc.w    $2c07,$fffe     ; Wait for line $2c
            dc.w    COLOR00,COLOUR_HOME ; Set background colour
