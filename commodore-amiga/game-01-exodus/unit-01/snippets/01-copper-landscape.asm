copperlist:
            ; --- Display setup ---
            dc.w    BPLCON0,$0200       ; 0 bitplanes, colour burst on

            ; --- SKY GRADIENT (5 bands, deep to pale) ---
            dc.w    COLOR00,COLOUR_SKY_DEEP     ; Deep navy from top of frame

            dc.w    $3401,$fffe                 ; Wait for line $34
            dc.w    COLOR00,COLOUR_SKY_UPPER    ; Dark blue

            dc.w    $4401,$fffe                 ; Wait for line $44
            dc.w    COLOR00,COLOUR_SKY_MID      ; Medium blue

            dc.w    $5401,$fffe                 ; Wait for line $54
            dc.w    COLOR00,COLOUR_SKY_LOWER    ; Light blue

            dc.w    $6001,$fffe                 ; Wait for line $60
            dc.w    COLOR00,COLOUR_SKY_HORIZON  ; Pale horizon

            ; --- GROUND SURFACE ---
            dc.w    $6801,$fffe                 ; Wait for line $68
            dc.w    COLOR00,COLOUR_GRASS        ; Green grass

            ; --- TERRAIN CROSS-SECTION ---
            dc.w    $7401,$fffe                 ; Wait for line $74
            dc.w    COLOR00,COLOUR_EARTH_TOP    ; Light brown

            dc.w    $8c01,$fffe                 ; Wait for line $8C
            dc.w    COLOR00,COLOUR_EARTH_MID    ; Medium brown

            dc.w    $a401,$fffe                 ; Wait for line $A4
            dc.w    COLOR00,COLOUR_EARTH_DEEP   ; Dark brown

            ; --- UNDERGROUND ---
            dc.w    $bc01,$fffe                 ; Wait for line $BC
            dc.w    COLOR00,COLOUR_ROCK         ; Rock

            dc.w    $d401,$fffe                 ; Wait for line $D4
            dc.w    COLOR00,COLOUR_ROCK_DEEP    ; Deep rock

            dc.w    $e801,$fffe                 ; Wait for line $E8
            dc.w    COLOR00,COLOUR_VOID         ; Black void

            ; --- END OF COPPER LIST ---
            dc.w    $ffff,$fffe                 ; Wait for impossible position
