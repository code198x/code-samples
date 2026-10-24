; SPDX-License-Identifier: MIT
; A Streaming CRC-8. Contiguous private bytes: CRC, DATA.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; D0-D3/A0-A1/CCR change; D4-D7/A2-A6 survive.
streaming_crc8_init:
    clr.b CRC
    clr.b DATA
    rts
streaming_crc8_step:
    move.b CRC,d0
    move.b DATA,d2
    eor.b d2,d0
    moveq #7,d1
crc_bit:
    add.b d0,d0
    bcc.s crc_next
    eori.b #CRC_POLY,d0
crc_next:
    dbra d1,crc_bit
    move.b d0,CRC
    rts
component_end:
