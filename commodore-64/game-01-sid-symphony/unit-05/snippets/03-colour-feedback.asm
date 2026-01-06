get_crowd_colour:
            lda crowd_meter
            cmp #$05            ; Below 5?
            bcc +
            cmp #$0f            ; Below 15?
            bcc ++
            lda #COL_GREEN      ; 15+ = happy
            rts
++          lda #COL_YELLOW     ; 5-14 = okay
            rts
+           lda #COL_RED        ; 0-4 = danger
            rts
