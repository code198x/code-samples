; SPDX-License-Identifier: MIT
; Look Up Tile Properties. Contiguous private bytes: ATTRS, MATCH, VALID, TILE_ID, MASK.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; D0-D3/A0-A1/CCR change; D4-D7/A2-A6 survive.
tile_properties_init:
    clr.b ATTRS
    clr.b MATCH
    clr.b VALID
    clr.b TILE_ID
    clr.b MASK
    rts
tile_properties_step:
    clr.b ATTRS
    clr.b MATCH
    clr.b VALID
    moveq #0,d0
    move.b TILE_ID,d0
    cmp.b #PROPERTY_COUNT,d0
    bhs.s property_done
    lea property_table,a0
    move.b 0(a0,d0.w),d1
    move.b d1,ATTRS
    and.b MASK,d1
    beq.s property_valid
    move.b #1,MATCH
property_valid:
    move.b #1,VALID
property_done:
    rts
component_end:
