; SPDX-License-Identifier: MIT
; Transfer Inventory Stacks Atomically. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
inventory_transfer_init:
    ld a,0
    ld (MOVED),a
    ld (VALID),a
    ld (SOURCE_KIND),a
    ld (SOURCE_COUNT),a
    ld (DEST_KIND),a
    ld (DEST_COUNT),a
    ld (CAPACITY),a
    ld (AMOUNT),a
    ld (T0),a
    ret
inventory_transfer_step:
; MOVED = 0
    ld a,0
    ld (MOVED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if SOURCE_COUNT > CAPACITY:
    ld a,(SOURCE_COUNT)
    ld b,a
    ld a,(CAPACITY)
    ld c,a
    ld a,b
    cp c
    jp z,inventory_transfer_L2
    jp nc,inventory_transfer_L1
    jp inventory_transfer_L2
inventory_transfer_L1:
; return
    ret
    jp inventory_transfer_L3
inventory_transfer_L2:
inventory_transfer_L3:
; if DEST_COUNT > CAPACITY:
    ld a,(DEST_COUNT)
    ld b,a
    ld a,(CAPACITY)
    ld c,a
    ld a,b
    cp c
    jp z,inventory_transfer_L5
    jp nc,inventory_transfer_L4
    jp inventory_transfer_L5
inventory_transfer_L4:
; return
    ret
    jp inventory_transfer_L6
inventory_transfer_L5:
inventory_transfer_L6:
; if SOURCE_COUNT == 0:
    ld a,(SOURCE_COUNT)
    cp 0
    jp z,inventory_transfer_L7
    jp inventory_transfer_L8
inventory_transfer_L7:
; if SOURCE_KIND != 0:
    ld a,(SOURCE_KIND)
    cp 0
    jp nz,inventory_transfer_L10
    jp inventory_transfer_L11
inventory_transfer_L10:
; return
    ret
    jp inventory_transfer_L12
inventory_transfer_L11:
inventory_transfer_L12:
    jp inventory_transfer_L9
inventory_transfer_L8:
; if SOURCE_KIND == 0:
    ld a,(SOURCE_KIND)
    cp 0
    jp z,inventory_transfer_L13
    jp inventory_transfer_L14
inventory_transfer_L13:
; return
    ret
    jp inventory_transfer_L15
inventory_transfer_L14:
inventory_transfer_L15:
inventory_transfer_L9:
; if DEST_COUNT == 0:
    ld a,(DEST_COUNT)
    cp 0
    jp z,inventory_transfer_L16
    jp inventory_transfer_L17
inventory_transfer_L16:
; if DEST_KIND != 0:
    ld a,(DEST_KIND)
    cp 0
    jp nz,inventory_transfer_L19
    jp inventory_transfer_L20
inventory_transfer_L19:
; return
    ret
    jp inventory_transfer_L21
inventory_transfer_L20:
inventory_transfer_L21:
    jp inventory_transfer_L18
inventory_transfer_L17:
; if DEST_KIND == 0:
    ld a,(DEST_KIND)
    cp 0
    jp z,inventory_transfer_L22
    jp inventory_transfer_L23
inventory_transfer_L22:
; return
    ret
    jp inventory_transfer_L24
inventory_transfer_L23:
inventory_transfer_L24:
inventory_transfer_L18:
; VALID = 1
    ld a,1
    ld (VALID),a
; if SOURCE_COUNT == 0:
    ld a,(SOURCE_COUNT)
    cp 0
    jp z,inventory_transfer_L25
    jp inventory_transfer_L26
inventory_transfer_L25:
; return
    ret
    jp inventory_transfer_L27
inventory_transfer_L26:
inventory_transfer_L27:
; if DEST_COUNT != 0:
    ld a,(DEST_COUNT)
    cp 0
    jp nz,inventory_transfer_L28
    jp inventory_transfer_L29
inventory_transfer_L28:
; if DEST_KIND != SOURCE_KIND:
    ld a,(DEST_KIND)
    ld b,a
    ld a,(SOURCE_KIND)
    ld c,a
    ld a,b
    cp c
    jp nz,inventory_transfer_L31
    jp inventory_transfer_L32
inventory_transfer_L31:
; return
    ret
    jp inventory_transfer_L33
inventory_transfer_L32:
inventory_transfer_L33:
    jp inventory_transfer_L30
inventory_transfer_L29:
inventory_transfer_L30:
; T0 = CAPACITY - DEST_COUNT
    ld a,(CAPACITY)
    ld b,a
    ld a,(DEST_COUNT)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; if AMOUNT < T0:
    ld a,(AMOUNT)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp c,inventory_transfer_L34
    jp inventory_transfer_L35
inventory_transfer_L34:
; T0 = AMOUNT
    ld a,(AMOUNT)
    ld (T0),a
    jp inventory_transfer_L36
inventory_transfer_L35:
inventory_transfer_L36:
; if SOURCE_COUNT < T0:
    ld a,(SOURCE_COUNT)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp c,inventory_transfer_L37
    jp inventory_transfer_L38
inventory_transfer_L37:
; T0 = SOURCE_COUNT
    ld a,(SOURCE_COUNT)
    ld (T0),a
    jp inventory_transfer_L39
inventory_transfer_L38:
inventory_transfer_L39:
; if T0 == 0:
    ld a,(T0)
    cp 0
    jp z,inventory_transfer_L40
    jp inventory_transfer_L41
inventory_transfer_L40:
; return
    ret
    jp inventory_transfer_L42
inventory_transfer_L41:
inventory_transfer_L42:
; DEST_KIND = SOURCE_KIND
    ld a,(SOURCE_KIND)
    ld (DEST_KIND),a
; DEST_COUNT = DEST_COUNT + T0
    ld a,(DEST_COUNT)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    add a,c
    ld (DEST_COUNT),a
; SOURCE_COUNT = SOURCE_COUNT - T0
    ld a,(SOURCE_COUNT)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    sub c
    ld (SOURCE_COUNT),a
; MOVED = T0
    ld a,(T0)
    ld (MOVED),a
; if SOURCE_COUNT == 0:
    ld a,(SOURCE_COUNT)
    cp 0
    jp z,inventory_transfer_L43
    jp inventory_transfer_L44
inventory_transfer_L43:
; SOURCE_KIND = 0
    ld a,0
    ld (SOURCE_KIND),a
    jp inventory_transfer_L45
inventory_transfer_L44:
inventory_transfer_L45:
    ret
component_end:
