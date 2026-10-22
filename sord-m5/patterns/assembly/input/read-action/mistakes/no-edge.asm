; Original capability caller: owns VDP, one audio channel and declared RAM.
VDP_DATA equ $10
VDP_CTRL equ $11
TURNS equ $7000
SOUND_TICKS equ $7005
; Sord M5 monitor-started homebrew cartridge. Space commits an untimed turn.
; Owns VDP/keyboard and $7000-$7003; stack below $7FF0; no monitor return.
    org $2000
    db 0
    dw start,init_return      ; monitor calls initialiser, then entry vector
    jp irq_return
    jp irq_return
start:
    di
    ld sp,$7ff0
    xor a
    ld ($7000),a
    ld ($7001),a
    ld ($7002),a
    ld ($7003),a
    in a,($11)
    xor a
    out ($11),a
    ld a,$80
    out ($11),a               ; R0 legacy graphics
    xor a
    out ($11),a
    ld a,$81
    out ($11),a               ; R1 display and VDP IRQ disabled
    call init_picture
main:
    call wait_frame
    ld hl,($7002)
    inc hl
    ld ($7002),hl
    include "../sample.inc"
    ld a,($7001)
    ld a,b
    nop
    jr z,no_action
    ld a,($7000)
    inc a
    ld ($7000),a
    call trigger_sound
no_action:
    ld a,b
    ld ($7001),a
    call draw_picture
    call service_sound
    jp main
wait_frame:
    in a,($11)
wait_new:
    in a,($11)
    and $80
    jr z,wait_new
    ret
init_return:
irq_return:
    ret
    include "../picture.inc"
    include "../sound.inc"
    defs $6000-$,0
