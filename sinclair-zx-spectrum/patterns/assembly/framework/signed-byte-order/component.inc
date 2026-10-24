; SPDX-License-Identifier: MIT
; Compare Signed Byte Values. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
signed_byte_order_init:
    ld a,0
    ld (ORDER),a
    ld (LEFT),a
    ld (RIGHT),a
    ld (T0),a
    ld (T1),a
    ret
signed_byte_order_step:
; T0 = LEFT ^ 128
    ld a,(LEFT)
    xor 128
    ld (T0),a
; T1 = RIGHT ^ 128
    ld a,(RIGHT)
    xor 128
    ld (T1),a
; ORDER = 1
    ld a,1
    ld (ORDER),a
; if T0 < T1:
    ld a,(T0)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp c,signed_byte_order_L1
    jp signed_byte_order_L2
signed_byte_order_L1:
; ORDER = 0
    ld a,0
    ld (ORDER),a
    jp signed_byte_order_L3
signed_byte_order_L2:
signed_byte_order_L3:
; if T0 > T1:
    ld a,(T0)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp z,signed_byte_order_L5
    jp nc,signed_byte_order_L4
    jp signed_byte_order_L5
signed_byte_order_L4:
; ORDER = 2
    ld a,2
    ld (ORDER),a
    jp signed_byte_order_L6
signed_byte_order_L5:
signed_byte_order_L6:
    ret
component_end:
