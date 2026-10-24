; SPDX-License-Identifier: MIT
; Transfer Inventory Stacks Atomically. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
inventory_transfer_init:
    move.b #0,d0
    move.b d0,MOVED
    move.b d0,VALID
    move.b d0,SOURCE_KIND
    move.b d0,SOURCE_COUNT
    move.b d0,DEST_KIND
    move.b d0,DEST_COUNT
    move.b d0,CAPACITY
    move.b d0,AMOUNT
    move.b d0,T0
    rts
inventory_transfer_step:
; MOVED = 0
    move.b #0,d0
    move.b d0,MOVED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if SOURCE_COUNT > CAPACITY:
    move.b SOURCE_COUNT,d0
    move.b CAPACITY,d1
    cmp.b d1,d0
    bhi inventory_transfer_L1
    jmp inventory_transfer_L2
inventory_transfer_L1:
; return
    rts
    jmp inventory_transfer_L3
inventory_transfer_L2:
inventory_transfer_L3:
; if DEST_COUNT > CAPACITY:
    move.b DEST_COUNT,d0
    move.b CAPACITY,d1
    cmp.b d1,d0
    bhi inventory_transfer_L4
    jmp inventory_transfer_L5
inventory_transfer_L4:
; return
    rts
    jmp inventory_transfer_L6
inventory_transfer_L5:
inventory_transfer_L6:
; if SOURCE_COUNT == 0:
    move.b SOURCE_COUNT,d0
    cmp.b #0,d0
    beq inventory_transfer_L7
    jmp inventory_transfer_L8
inventory_transfer_L7:
; if SOURCE_KIND != 0:
    move.b SOURCE_KIND,d0
    cmp.b #0,d0
    bne inventory_transfer_L10
    jmp inventory_transfer_L11
inventory_transfer_L10:
; return
    rts
    jmp inventory_transfer_L12
inventory_transfer_L11:
inventory_transfer_L12:
    jmp inventory_transfer_L9
inventory_transfer_L8:
; if SOURCE_KIND == 0:
    move.b SOURCE_KIND,d0
    cmp.b #0,d0
    beq inventory_transfer_L13
    jmp inventory_transfer_L14
inventory_transfer_L13:
; return
    rts
    jmp inventory_transfer_L15
inventory_transfer_L14:
inventory_transfer_L15:
inventory_transfer_L9:
; if DEST_COUNT == 0:
    move.b DEST_COUNT,d0
    cmp.b #0,d0
    beq inventory_transfer_L16
    jmp inventory_transfer_L17
inventory_transfer_L16:
; if DEST_KIND != 0:
    move.b DEST_KIND,d0
    cmp.b #0,d0
    bne inventory_transfer_L19
    jmp inventory_transfer_L20
inventory_transfer_L19:
; return
    rts
    jmp inventory_transfer_L21
inventory_transfer_L20:
inventory_transfer_L21:
    jmp inventory_transfer_L18
inventory_transfer_L17:
; if DEST_KIND == 0:
    move.b DEST_KIND,d0
    cmp.b #0,d0
    beq inventory_transfer_L22
    jmp inventory_transfer_L23
inventory_transfer_L22:
; return
    rts
    jmp inventory_transfer_L24
inventory_transfer_L23:
inventory_transfer_L24:
inventory_transfer_L18:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if SOURCE_COUNT == 0:
    move.b SOURCE_COUNT,d0
    cmp.b #0,d0
    beq inventory_transfer_L25
    jmp inventory_transfer_L26
inventory_transfer_L25:
; return
    rts
    jmp inventory_transfer_L27
inventory_transfer_L26:
inventory_transfer_L27:
; if DEST_COUNT != 0:
    move.b DEST_COUNT,d0
    cmp.b #0,d0
    bne inventory_transfer_L28
    jmp inventory_transfer_L29
inventory_transfer_L28:
; if DEST_KIND != SOURCE_KIND:
    move.b DEST_KIND,d0
    move.b SOURCE_KIND,d1
    cmp.b d1,d0
    bne inventory_transfer_L31
    jmp inventory_transfer_L32
inventory_transfer_L31:
; return
    rts
    jmp inventory_transfer_L33
inventory_transfer_L32:
inventory_transfer_L33:
    jmp inventory_transfer_L30
inventory_transfer_L29:
inventory_transfer_L30:
; T0 = CAPACITY - DEST_COUNT
    move.b CAPACITY,d0
    move.b DEST_COUNT,d1
    sub.b d1,d0
    move.b d0,T0
; if AMOUNT < T0:
    move.b AMOUNT,d0
    move.b T0,d1
    cmp.b d1,d0
    bcs inventory_transfer_L34
    jmp inventory_transfer_L35
inventory_transfer_L34:
; T0 = AMOUNT
    move.b AMOUNT,d0
    move.b d0,T0
    jmp inventory_transfer_L36
inventory_transfer_L35:
inventory_transfer_L36:
; if SOURCE_COUNT < T0:
    move.b SOURCE_COUNT,d0
    move.b T0,d1
    cmp.b d1,d0
    bcs inventory_transfer_L37
    jmp inventory_transfer_L38
inventory_transfer_L37:
; T0 = SOURCE_COUNT
    move.b SOURCE_COUNT,d0
    move.b d0,T0
    jmp inventory_transfer_L39
inventory_transfer_L38:
inventory_transfer_L39:
; if T0 == 0:
    move.b T0,d0
    cmp.b #0,d0
    beq inventory_transfer_L40
    jmp inventory_transfer_L41
inventory_transfer_L40:
; return
    rts
    jmp inventory_transfer_L42
inventory_transfer_L41:
inventory_transfer_L42:
; DEST_KIND = SOURCE_KIND
    move.b SOURCE_KIND,d0
    move.b d0,DEST_KIND
; DEST_COUNT = DEST_COUNT + T0
    move.b DEST_COUNT,d0
    move.b T0,d1
    add.b d1,d0
    move.b d0,DEST_COUNT
; SOURCE_COUNT = SOURCE_COUNT - T0
    move.b SOURCE_COUNT,d0
    move.b T0,d1
    sub.b d1,d0
    move.b d0,SOURCE_COUNT
; MOVED = T0
    move.b T0,d0
    move.b d0,MOVED
; if SOURCE_COUNT == 0:
    move.b SOURCE_COUNT,d0
    cmp.b #0,d0
    beq inventory_transfer_L43
    jmp inventory_transfer_L44
inventory_transfer_L43:
; SOURCE_KIND = 0
    move.b #0,d0
    move.b d0,SOURCE_KIND
    jmp inventory_transfer_L45
inventory_transfer_L44:
inventory_transfer_L45:
    rts
component_end:
