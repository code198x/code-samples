; SPDX-License-Identifier: MIT
; Look Up Tile Properties. Contiguous private bytes: ATTRS, MATCH, VALID, TILE_ID, MASK.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; A/X/flags change; Y and decimal mode survive. D=0 for binary arithmetic.
tile_properties_init:
    lda #0
    sta ATTRS
    sta MATCH
    sta VALID
    sta TILE_ID
    sta MASK
    rts
tile_properties_step:
    lda #0
    sta ATTRS
    sta MATCH
    sta VALID
    ldx TILE_ID
    cpx #PROPERTY_COUNT
    bcs property_done
    lda property_table,x
    sta ATTRS
    and MASK
    beq property_valid
    inc MATCH
property_valid:
    inc VALID
property_done:
    rts
component_end:
