check_exit:
            ; Read keyboard via CIA-A
            move.b  $bfec01,d0          ; CIAA keyboard register
            not.b   d0                  ; Invert (active low)
            ror.b   #1,d0               ; Shift key code
            cmpi.b  #$45,d0             ; Escape key
            beq.s   .do_exit
            rts

.do_exit:
            bsr     restore_system
            moveq   #0,d0               ; Return code 0
            rts
