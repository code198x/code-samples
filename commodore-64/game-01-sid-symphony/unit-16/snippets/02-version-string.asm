; Draw version (Unit 16)
            ldx #$00
dts_version:
            lda version_text,x
            beq dts_version_done
            sta SCREEN + (6 * 40) + 18,x
            lda #COL_GREY
            sta COLOUR + (6 * 40) + 18,x
            inx
            bne dts_version
dts_version_done:
