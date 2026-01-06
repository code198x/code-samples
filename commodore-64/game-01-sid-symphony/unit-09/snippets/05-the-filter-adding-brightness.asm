start_filter_sweep:
            lda #$70            ; Start cutoff high (bright)
            sta filter_cutoff
            sta SID_FC_HI
            lda #20             ; Sweep duration
            sta filter_sweep
            rts

update_filter_sweep:
            lda filter_sweep
            beq +

            dec filter_sweep

            lda filter_cutoff
            cmp #$40            ; Don't go below baseline
            bcc +
            sec
            sbc #$02
            sta filter_cutoff
            sta SID_FC_HI
+           rts
