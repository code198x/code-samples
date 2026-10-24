; SPDX-License-Identifier: MIT
; Allocate Slots with a Bitset. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bitset_slot_allocation_init:
    ld a,0
    ld (SLOT),a
    ld (RESULT),a
    ld (VALID),a
    ld (USED),a
    ld (MODE),a
    ld (REQUEST),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ret
bitset_slot_allocation_step:
; SLOT = 255
    ld a,255
    ld (SLOT),a
; RESULT = 0
    ld a,0
    ld (RESULT),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if MODE > 1:
    ld a,(MODE)
    cp 1
    jp z,bitset_slot_allocation_L2
    jp nc,bitset_slot_allocation_L1
    jp bitset_slot_allocation_L2
bitset_slot_allocation_L1:
; return
    ret
    jp bitset_slot_allocation_L3
bitset_slot_allocation_L2:
bitset_slot_allocation_L3:
; if MODE == 1:
    ld a,(MODE)
    cp 1
    jp z,bitset_slot_allocation_L4
    jp bitset_slot_allocation_L5
bitset_slot_allocation_L4:
; if REQUEST >= 8:
    ld a,(REQUEST)
    cp 8
    jp nc,bitset_slot_allocation_L7
    jp bitset_slot_allocation_L8
bitset_slot_allocation_L7:
; return
    ret
    jp bitset_slot_allocation_L9
bitset_slot_allocation_L8:
bitset_slot_allocation_L9:
    jp bitset_slot_allocation_L6
bitset_slot_allocation_L5:
bitset_slot_allocation_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = 0
    ld a,0
    ld (T0),a
; T1 = 1
    ld a,1
    ld (T1),a
; if MODE == 0:
    ld a,(MODE)
    cp 0
    jp z,bitset_slot_allocation_L10
    jp bitset_slot_allocation_L11
bitset_slot_allocation_L10:
; while T0 < 8:
bitset_slot_allocation_L13:
    ld a,(T0)
    cp 8
    jp c,bitset_slot_allocation_L14
    jp bitset_slot_allocation_L15
bitset_slot_allocation_L14:
; T2 = USED & T1
    ld a,(USED)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    and c
    ld (T2),a
; if T2 == 0:
    ld a,(T2)
    cp 0
    jp z,bitset_slot_allocation_L16
    jp bitset_slot_allocation_L17
bitset_slot_allocation_L16:
; USED = USED | T1
    ld a,(USED)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    or c
    ld (USED),a
; SLOT = T0
    ld a,(T0)
    ld (SLOT),a
; RESULT = 1
    ld a,1
    ld (RESULT),a
; return
    ret
    jp bitset_slot_allocation_L18
bitset_slot_allocation_L17:
bitset_slot_allocation_L18:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
; T1 = T1 << 1
    ld a,(T1)
    sla a
    ld (T1),a
    jp bitset_slot_allocation_L13
bitset_slot_allocation_L15:
    jp bitset_slot_allocation_L12
bitset_slot_allocation_L11:
; T0 = REQUEST
    ld a,(REQUEST)
    ld (T0),a
; while T0 != 0:
bitset_slot_allocation_L19:
    ld a,(T0)
    cp 0
    jp nz,bitset_slot_allocation_L20
    jp bitset_slot_allocation_L21
bitset_slot_allocation_L20:
; T1 = T1 << 1
    ld a,(T1)
    sla a
    ld (T1),a
; T0 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T0),a
    jp bitset_slot_allocation_L19
bitset_slot_allocation_L21:
; T2 = USED & T1
    ld a,(USED)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    and c
    ld (T2),a
; if T2 != 0:
    ld a,(T2)
    cp 0
    jp nz,bitset_slot_allocation_L22
    jp bitset_slot_allocation_L23
bitset_slot_allocation_L22:
; T1 = T1 ^ 255
    ld a,(T1)
    xor 255
    ld (T1),a
; USED = USED & T1
    ld a,(USED)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    and c
    ld (USED),a
; SLOT = REQUEST
    ld a,(REQUEST)
    ld (SLOT),a
; RESULT = 1
    ld a,1
    ld (RESULT),a
    jp bitset_slot_allocation_L24
bitset_slot_allocation_L23:
bitset_slot_allocation_L24:
bitset_slot_allocation_L12:
    ret
component_end:
