; SPDX-License-Identifier: MIT
; A Streaming CRC-8. Contiguous private bytes: CRC, DATA.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; A/X/flags change; Y and decimal mode survive. D=0 for binary arithmetic.
streaming_crc8_init:
    lda #0
    sta CRC
    sta DATA
    rts
streaming_crc8_step:
    lda CRC
    eor DATA
    sta CRC
    ldx #8
crc_bit:
    asl CRC
    bcc crc_next
    lda CRC
    eor #CRC_POLY
    sta CRC
crc_next:
    dex
    bne crc_bit
    rts
component_end:
