read_keys:
            ; Store previous states
            lda key_x
            sta key_x_prev
            lda key_c
            sta key_c_prev
            lda key_v
            sta key_v_prev

            ; Read X key (column 7, row 2)
            lda #%01111111
            sta CIA1_PORTA
            lda CIA1_PORTB
            and #%00000100
            beq +
            lda #$00
            jmp ++
+           lda #$01
++          sta key_x

            ; Read C key (column 4, row 2)
            lda #%11101111
            sta CIA1_PORTA
            lda CIA1_PORTB
            and #%00000100
            beq +
            lda #$00
            jmp ++
+           lda #$01
++          sta key_c

            ; Read V key (column 7, row 3)
            lda #%01111111
            sta CIA1_PORTA
            lda CIA1_PORTB
            and #%00001000
            beq +
            lda #$00
            jmp ++
+           lda #$01
++          sta key_v
            rts
