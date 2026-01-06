copperlist:
            dc.w    COLOR00,$0000   ; Black border

            ; Sprite 0 colours (17, 18, 19)
            dc.w    $01a2,$00f0     ; Colour 17: Green (body)
            dc.w    $01a4,$0ff0     ; Colour 18: Yellow (eyes)
            dc.w    $01a6,$0000     ; Colour 19: Black (outline)

            ; Sprite 0 pointer (CPU fills these in)
sprpt:
            dc.w    $0120,$0000     ; SPR0PTH (high word)
            dc.w    $0122,$0000     ; SPR0PTL (low word)

            ; ... rest of zones ...
