update_crowd_hit:
            lda crowd_meter
            cmp #CROWD_MAX
            bcs +               ; Already maxed
            inc crowd_meter
+           rts

update_crowd_miss:
            lda crowd_meter
            sec
            sbc #$02            ; Subtract 2
            bcs +               ; No underflow
            lda #$00            ; Floor at 0
+           sta crowd_meter
            bne +               ; Not zero? Continue
            jsr trigger_game_over
+           rts
