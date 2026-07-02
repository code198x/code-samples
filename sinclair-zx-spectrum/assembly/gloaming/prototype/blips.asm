blip_lit:                           ; a rising third — the lamp catches
            ld      b, $17          ; C6
            ld      c, $67
            call    beep
            ld      b, $28          ; E6
            ld      c, $51
            jp      beep

blip_snuff:                         ; the third falls, an octave down — cold again
            ld      b, $0F          ; E5
            ld      c, $A4
            call    beep
            ld      b, $10          ; C5
            ld      c, $CF
            jp      beep
