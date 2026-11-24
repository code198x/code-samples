; Read the action row of JOYP, not the directions. Bits are 0 when
; pressed on the hardware; return 1 for down in each named button bit.
rJOYP EQU $FF00
SELECT_ACTION_ROW EQU $10
BUTTON_A EQU %0001
BUTTON_B EQU %0010
BUTTON_START EQU %1000

read_buttons:
    ld a,SELECT_ACTION_ROW
    ld [rJOYP],a
    ; Let the selected row settle. Only the last read is used.
    ld a,[rJOYP]
    ld a,[rJOYP]
    ld a,[rJOYP]
    ld a,[rJOYP]
    ld a,[rJOYP]
    ld a,[rJOYP]
    cpl
    ret
