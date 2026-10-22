; DMG default reset, 32 KiB ROM-only cartridge, no boot ROM.
; Takes over LCD/VRAM, JOYP, four WRAM bytes and descending stack from $FFFE.
start:
    di
    ld sp,$FFFE
    ld a,[$FF40]
    bit 7,a
    jr z,lcd_off
wait_to_disable:
    ld a,[$FF44]
    cp 144
    jr c,wait_to_disable
lcd_off:
    xor a
    ld [$FF40],a
    ld [$FF42],a
    ld [$FF43],a
    ld hl,$8000
    ld bc,$2000
clear_vram:
    xor a
    ld [hl+],a
    dec bc
    ld a,b
    or c
    jr nz,clear_vram
    ld a,INITIAL
    call turn_init
    xor a
    ld [CTX+1],a
    ld [CTX+2],a
    ld [CTX+3],a
    call show_turn
    ld a,$91
    ld [$FF40],a
main:
    call wait_frame
    ld a,[CTX+2]
    inc a
    ld [CTX+2],a
    jr nz,service_done
    ld a,[CTX+3]
    inc a
    ld [CTX+3],a
service_done:
    ld a,RESET_EACH
    or a
    jr z,keep_state
    xor a
    call turn_init
keep_state:
    call sample_action
    or a
    jr z,no_action
    call turn_advance
no_action:
    call show_turn
    jp main
