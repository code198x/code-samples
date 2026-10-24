; SPDX-License-Identifier: MIT
; Compare Signed Byte Values. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
signed_byte_order_init:
    move.b #0,d0
    move.b d0,ORDER
    move.b d0,LEFT
    move.b d0,RIGHT
    move.b d0,T0
    move.b d0,T1
    rts
signed_byte_order_step:
; T0 = LEFT ^ 128
    move.b LEFT,d0
    eor.b #128,d0
    move.b d0,T0
; T1 = RIGHT ^ 128
    move.b RIGHT,d0
    eor.b #128,d0
    move.b d0,T1
; ORDER = 1
    move.b #1,d0
    move.b d0,ORDER
; if T0 < T1:
    move.b T0,d0
    move.b T1,d1
    cmp.b d1,d0
    bcs signed_byte_order_L1
    jmp signed_byte_order_L2
signed_byte_order_L1:
; ORDER = 0
    move.b #0,d0
    move.b d0,ORDER
    jmp signed_byte_order_L3
signed_byte_order_L2:
signed_byte_order_L3:
; if T0 > T1:
    move.b T0,d0
    move.b T1,d1
    cmp.b d1,d0
    bhi signed_byte_order_L4
    jmp signed_byte_order_L5
signed_byte_order_L4:
; ORDER = 2
    move.b #2,d0
    move.b d0,ORDER
    jmp signed_byte_order_L6
signed_byte_order_L5:
signed_byte_order_L6:
    rts
component_end:
