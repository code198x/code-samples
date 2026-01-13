; Copper List Basics
; The Copper is a simple coprocessor that executes a list of
; WAIT and MOVE instructions synchronised to the display beam.

copperlist:
            dc.w    COLOR00,$0000       ; MOVE: Set colour 0 to black

            ; --- Sprite 0 palette (colours 17-19) ---
            dc.w    $01a2,COLOUR_FROG   ; Colour 17: body
            dc.w    $01a4,COLOUR_EYES   ; Colour 18: eyes
            dc.w    $01a6,COLOUR_OUTLINE ; Colour 19: outline

            ; --- Sprite 0 pointer ---
            dc.w    SPR0PTH             ; SPR0PTH register ($120)
sprpth_val: dc.w    $0000               ; High word (patched by CPU)
            dc.w    SPR0PTL             ; SPR0PTL register ($122)
sprptl_val: dc.w    $0000               ; Low word (patched by CPU)

            ; === ZONE COLOURS (WAIT + MOVE) ===
            dc.w    $2c07,$fffe         ; WAIT: line $2c, any horizontal
            dc.w    COLOR00,COLOUR_HOME ; MOVE: Set background to green

            ; ... more zones ...

            dc.w    $ffff,$fffe         ; End: wait for impossible position

; Each MOVE is: register_offset, value
; Each WAIT is: vpos_hpos, $fffe (mask)
