; SPDX-License-Identifier: MIT
; Parse a Bounded Decimal Number. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
decimal_parser_init:
    ld a,0
    ld (VALUE),a
    ld (CHARACTER),a
    ld (STATUS),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ret
decimal_parser_step:
; STATUS = 2
    ld a,2
    ld (STATUS),a
; if CHARACTER < 48:
    ld a,(CHARACTER)
    cp 48
    jp c,decimal_parser_L1
    jp decimal_parser_L2
decimal_parser_L1:
; return
    ret
    jp decimal_parser_L3
decimal_parser_L2:
decimal_parser_L3:
; if CHARACTER > 57:
    ld a,(CHARACTER)
    cp 57
    jp z,decimal_parser_L5
    jp nc,decimal_parser_L4
    jp decimal_parser_L5
decimal_parser_L4:
; return
    ret
    jp decimal_parser_L6
decimal_parser_L5:
decimal_parser_L6:
; T0 = CHARACTER - 48
    ld a,(CHARACTER)
    sub 48
    ld (T0),a
; STATUS = 3
    ld a,3
    ld (STATUS),a
; if VALUE > 25:
    ld a,(VALUE)
    cp 25
    jp z,decimal_parser_L8
    jp nc,decimal_parser_L7
    jp decimal_parser_L8
decimal_parser_L7:
; return
    ret
    jp decimal_parser_L9
decimal_parser_L8:
decimal_parser_L9:
; if VALUE == 25:
    ld a,(VALUE)
    cp 25
    jp z,decimal_parser_L10
    jp decimal_parser_L11
decimal_parser_L10:
; if T0 > 5:
    ld a,(T0)
    cp 5
    jp z,decimal_parser_L14
    jp nc,decimal_parser_L13
    jp decimal_parser_L14
decimal_parser_L13:
; return
    ret
    jp decimal_parser_L15
decimal_parser_L14:
decimal_parser_L15:
    jp decimal_parser_L12
decimal_parser_L11:
decimal_parser_L12:
; T1 = VALUE << 1
    ld a,(VALUE)
    sla a
    ld (T1),a
; T2 = VALUE << 3
    ld a,(VALUE)
    sla a
    sla a
    sla a
    ld (T2),a
; T1 = T1 + T2
    ld a,(T1)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    add a,c
    ld (T1),a
; VALUE = T1 + T0
    ld a,(T1)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    add a,c
    ld (VALUE),a
; STATUS = 1
    ld a,1
    ld (STATUS),a
    ret
component_end:
