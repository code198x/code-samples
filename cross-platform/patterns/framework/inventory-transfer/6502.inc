; SPDX-License-Identifier: MIT
; Transfer Inventory Stacks Atomically. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
inventory_transfer_init:
    lda #0
    sta MOVED
    sta VALID
    sta SOURCE_KIND
    sta SOURCE_COUNT
    sta DEST_KIND
    sta DEST_COUNT
    sta CAPACITY
    sta AMOUNT
    sta T0
    rts
inventory_transfer_step:
; MOVED = 0
    lda #0
    sta MOVED
; VALID = 0
    lda #0
    sta VALID
; if SOURCE_COUNT > CAPACITY:
    lda SOURCE_COUNT
    cmp CAPACITY
    beq inventory_transfer_L5
    bcs inventory_transfer_L4
inventory_transfer_L5:
    jmp inventory_transfer_L2
inventory_transfer_L4:
    jmp inventory_transfer_L1
inventory_transfer_L1:
; return
    rts
    jmp inventory_transfer_L3
inventory_transfer_L2:
inventory_transfer_L3:
; if DEST_COUNT > CAPACITY:
    lda DEST_COUNT
    cmp CAPACITY
    beq inventory_transfer_L10
    bcs inventory_transfer_L9
inventory_transfer_L10:
    jmp inventory_transfer_L7
inventory_transfer_L9:
    jmp inventory_transfer_L6
inventory_transfer_L6:
; return
    rts
    jmp inventory_transfer_L8
inventory_transfer_L7:
inventory_transfer_L8:
; if SOURCE_COUNT == 0:
    lda SOURCE_COUNT
    cmp #0
    beq inventory_transfer_L14
inventory_transfer_L15:
    jmp inventory_transfer_L12
inventory_transfer_L14:
    jmp inventory_transfer_L11
inventory_transfer_L11:
; if SOURCE_KIND != 0:
    lda SOURCE_KIND
    cmp #0
    bne inventory_transfer_L19
inventory_transfer_L20:
    jmp inventory_transfer_L17
inventory_transfer_L19:
    jmp inventory_transfer_L16
inventory_transfer_L16:
; return
    rts
    jmp inventory_transfer_L18
inventory_transfer_L17:
inventory_transfer_L18:
    jmp inventory_transfer_L13
inventory_transfer_L12:
; if SOURCE_KIND == 0:
    lda SOURCE_KIND
    cmp #0
    beq inventory_transfer_L24
inventory_transfer_L25:
    jmp inventory_transfer_L22
inventory_transfer_L24:
    jmp inventory_transfer_L21
inventory_transfer_L21:
; return
    rts
    jmp inventory_transfer_L23
inventory_transfer_L22:
inventory_transfer_L23:
inventory_transfer_L13:
; if DEST_COUNT == 0:
    lda DEST_COUNT
    cmp #0
    beq inventory_transfer_L29
inventory_transfer_L30:
    jmp inventory_transfer_L27
inventory_transfer_L29:
    jmp inventory_transfer_L26
inventory_transfer_L26:
; if DEST_KIND != 0:
    lda DEST_KIND
    cmp #0
    bne inventory_transfer_L34
inventory_transfer_L35:
    jmp inventory_transfer_L32
inventory_transfer_L34:
    jmp inventory_transfer_L31
inventory_transfer_L31:
; return
    rts
    jmp inventory_transfer_L33
inventory_transfer_L32:
inventory_transfer_L33:
    jmp inventory_transfer_L28
inventory_transfer_L27:
; if DEST_KIND == 0:
    lda DEST_KIND
    cmp #0
    beq inventory_transfer_L39
inventory_transfer_L40:
    jmp inventory_transfer_L37
inventory_transfer_L39:
    jmp inventory_transfer_L36
inventory_transfer_L36:
; return
    rts
    jmp inventory_transfer_L38
inventory_transfer_L37:
inventory_transfer_L38:
inventory_transfer_L28:
; VALID = 1
    lda #1
    sta VALID
; if SOURCE_COUNT == 0:
    lda SOURCE_COUNT
    cmp #0
    beq inventory_transfer_L44
inventory_transfer_L45:
    jmp inventory_transfer_L42
inventory_transfer_L44:
    jmp inventory_transfer_L41
inventory_transfer_L41:
; return
    rts
    jmp inventory_transfer_L43
inventory_transfer_L42:
inventory_transfer_L43:
; if DEST_COUNT != 0:
    lda DEST_COUNT
    cmp #0
    bne inventory_transfer_L49
inventory_transfer_L50:
    jmp inventory_transfer_L47
inventory_transfer_L49:
    jmp inventory_transfer_L46
inventory_transfer_L46:
; if DEST_KIND != SOURCE_KIND:
    lda DEST_KIND
    cmp SOURCE_KIND
    bne inventory_transfer_L54
inventory_transfer_L55:
    jmp inventory_transfer_L52
inventory_transfer_L54:
    jmp inventory_transfer_L51
inventory_transfer_L51:
; return
    rts
    jmp inventory_transfer_L53
inventory_transfer_L52:
inventory_transfer_L53:
    jmp inventory_transfer_L48
inventory_transfer_L47:
inventory_transfer_L48:
; T0 = CAPACITY - DEST_COUNT
    lda CAPACITY
    sec
    sbc DEST_COUNT
    sta T0
; if AMOUNT < T0:
    lda AMOUNT
    cmp T0
    bcc inventory_transfer_L59
inventory_transfer_L60:
    jmp inventory_transfer_L57
inventory_transfer_L59:
    jmp inventory_transfer_L56
inventory_transfer_L56:
; T0 = AMOUNT
    lda AMOUNT
    sta T0
    jmp inventory_transfer_L58
inventory_transfer_L57:
inventory_transfer_L58:
; if SOURCE_COUNT < T0:
    lda SOURCE_COUNT
    cmp T0
    bcc inventory_transfer_L64
inventory_transfer_L65:
    jmp inventory_transfer_L62
inventory_transfer_L64:
    jmp inventory_transfer_L61
inventory_transfer_L61:
; T0 = SOURCE_COUNT
    lda SOURCE_COUNT
    sta T0
    jmp inventory_transfer_L63
inventory_transfer_L62:
inventory_transfer_L63:
; if T0 == 0:
    lda T0
    cmp #0
    beq inventory_transfer_L69
inventory_transfer_L70:
    jmp inventory_transfer_L67
inventory_transfer_L69:
    jmp inventory_transfer_L66
inventory_transfer_L66:
; return
    rts
    jmp inventory_transfer_L68
inventory_transfer_L67:
inventory_transfer_L68:
; DEST_KIND = SOURCE_KIND
    lda SOURCE_KIND
    sta DEST_KIND
; DEST_COUNT = DEST_COUNT + T0
    lda DEST_COUNT
    clc
    adc T0
    sta DEST_COUNT
; SOURCE_COUNT = SOURCE_COUNT - T0
    lda SOURCE_COUNT
    sec
    sbc T0
    sta SOURCE_COUNT
; MOVED = T0
    lda T0
    sta MOVED
; if SOURCE_COUNT == 0:
    lda SOURCE_COUNT
    cmp #0
    beq inventory_transfer_L74
inventory_transfer_L75:
    jmp inventory_transfer_L72
inventory_transfer_L74:
    jmp inventory_transfer_L71
inventory_transfer_L71:
; SOURCE_KIND = 0
    lda #0
    sta SOURCE_KIND
    jmp inventory_transfer_L73
inventory_transfer_L72:
inventory_transfer_L73:
    rts
component_end:
