; SPDX-License-Identifier: MIT
; A Streaming CRC-8. Contiguous private bytes: CRC, DATA.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; AF/BC/DE/HL change; IX/IY survive.
streaming_crc8_init:
    xor a
    ld (CRC),a
    ld (DATA),a
    ret
streaming_crc8_step:
    ld a,(DATA)
    ld b,a
    ld a,(CRC)
    xor b
    ld b,8
crc_bit:
    add a,a
    jr nc,crc_next
    xor CRC_POLY
crc_next:
    djnz crc_bit
    ld (CRC),a
    ret
component_end:
