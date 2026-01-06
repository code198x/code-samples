; A simple hop sound - rising tone
; 32 bytes = 16 words = very short sample
sfx_hop:
            dc.b    0,20,40,60,80,100,100,80
            dc.b    60,40,20,0,-20,-40,-60,-80
            dc.b    -80,-60,-40,-20,0,20,40,60
            dc.b    80,100,100,80,60,40,20,0

SFX_HOP_LEN     equ 16      ; Length in words
