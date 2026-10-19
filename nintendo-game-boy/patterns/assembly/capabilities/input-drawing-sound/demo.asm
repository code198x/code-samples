; Capability caller: original input/frame service, explicit drawing and sound.
; DMG cartridge: video keeps running; only a new A press advances the turn.
; Owns LCD/VRAM, JOYP and $C000-$C003; maskable interrupts stay disabled.
SECTION "Entry", ROM0[$100]
    nop
    jp start
    ds $134-@,0
    db "TURNPROBE"
    ds $150-@,0
SECTION "Program", ROM0[$150]
start:
    di
    ld sp,$fffe
wait_to_disable:
    ld a,[$ff44]
    cp 144
    jr c,wait_to_disable
    xor a
    ld [$ff40],a             ; disable LCD in VBlank before clearing VRAM
    ld hl,$8000
    ld bc,$2000
clear_vram:
    xor a
    ld [hl+],a
    dec bc
    ld a,b
    or c
    jr nz,clear_vram
    xor a
    ld [$c000],a             ; turn counter
    ld [$c001],a             ; previous A state
    ld [$c002],a             ; accepted frame counter, low
    ld [$c003],a             ; high
    call init_picture
    ld a,$e4
    ld [$ff47],a
    ld a,$91
    ld [$ff40],a             ; background enabled, tile/map zero initialised
main:
    call wait_frame
    ld a,[$c002]
    inc a
    ld [$c002],a
    jr nz,sample
    ld a,[$c003]
    inc a
    ld [$c003],a
sample:
    ld a,$10
    ld [$ff00],a             ; select action buttons (P15 low)
    ld a,[$ff00]
    ld a,[$ff00]
    ld a,[$ff00]
    cpl
    and 1
    ld b,a
    ld a,[$c001]
    cpl
    and b
    jr z,no_action
    ld a,[$c000]
    inc a
    ld [$c000],a
    call trigger_sound
no_action:
    ld a,b
    ld [$c001],a
    call draw_picture
    call service_sound
    jp main

; AF clobbered. Requires LCD enabled. Waits beyond any current VBlank,
; then accepts the next VBlank. Does not count missed announcements.
wait_frame:
    ld a,[$ff44]
    cp 144
    jr nc,wait_frame
wait_vblank:
    ld a,[$ff44]
    cp 144
    jr c,wait_vblank
    ret
    INCLUDE "picture.inc"
    INCLUDE "sound.inc"
    ds $8000-@,0
