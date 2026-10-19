; 48K PAL tape caller. ROM IM1 supplies the key latch; reset to leave.
; Editor capacity63 bytes. A rejected extra character latches overflow: Enter
; returns status2 instead of executing a truncated command; Delete clears it.
    org $8000
start:
    di
    ld sp,$ff00
    ld iy,$5c3a
    im 1
    ld hl,$4000
    ld de,$4001
    ld bc,6143
    ld (hl),0
    ldir
    ld hl,$5800
    ld de,$5801
    ld bc,767
    ld (hl),7
    ldir
    call parser_init
    call clear_input
    ld hl,title_text
    ld b,1
    ld c,0
    call print_string
    ld hl,help_text
    ld b,3
    call print_string
    ld hl,output_text
    ld b,12
    call print_string
    ld hl,legend_text
    ld b,16
    call print_string
    ld hl,$cafe
    ld (ready),hl
    xor a
    ld ($5c08),a
    ei
main:
    call wait_frame
    ld a,($5c08)
    or a
    jr z,main
    ld (pending_key),a
    xor a
    ld ($5c08),a
    ld a,(new_line)
    or a
    call nz,clear_input
    ld a,(pending_key)
    cp 13
    jr z,submit
    cp 12
    jr z,delete_key
    cp 32
    jr c,main
    cp 127
    jr nc,main
    ld e,a
    ld a,(input_count)
    cp 63
    jr nc,overflow
    ld l,a
    ld h,0
    ld bc,buffer
    add hl,bc
    ld (hl),e
    inc a
    ld (input_count),a
    call draw_input
    jr main
submit:
    ld a,(input_overflow)
    or a
    jr nz,submit_overflow
    ld hl,buffer
    ld a,(input_count)
    ld c,a
    ld b,0
    call parse_command
    jr show_result
submit_overflow:
    ld a,2
    ld (parse_status),a
    xor a
    ld (verb_id),a
    ld (noun_id),a
show_result:
    ld a,(parse_status)
    ld b,13
    ld c,0
    call print_two_digits
    ld a,(verb_id)
    ld l,a
    ld h,0
    ld c,8
    call print_three_digits
    ld a,(noun_id)
    ld l,a
    ld h,0
    ld c,15
    call print_three_digits
    ld a,1
    ld (new_line),a
    jp main
 overflow:
    ld a,1
    ld (input_overflow),a
    ld a,2
    out ($fe),a
    jp main
delete_key:
    ld a,(input_overflow)
    or a
    jr nz,clear_editor
    ld a,(input_count)
    or a
    jp z,main
    dec a
    ld (input_count),a
    ld l,a
    ld h,0
    ld de,buffer
    add hl,de
    ld (hl),' '
    call draw_input
    jp main
clear_editor:
    call clear_input
    jp main
clear_input:
    xor a
    ld (input_count),a
    ld (input_overflow),a
    ld (new_line),a
    out ($fe),a
    ld hl,buffer
    ld de,buffer+1
    ld bc,63
    ld (hl),' '
    ldir
    jp draw_input
draw_input:
    ld hl,buffer
    ld b,6
    ld c,0
    ld d,64
editor_cell:
    ld a,(hl)
    call print_char
    inc hl
    inc c
    ld a,c
    cp 32
    jr nz,editor_next
    ld c,0
    inc b
editor_next:
    dec d
    jr nz,editor_cell
    ret
ready: defw 0
pending_key: defb 0
input_count: defb 0
input_overflow: defb 0
new_line: defb 0
score_bcd: defb 0
buffer: defs 64,' '
title_text: defm "TWO-WORD COMMAND INSPECTOR"
    defb 0
help_text: defm "Enter submits. Delete edits."
    defb 0
output_text: defm "STATUS  VERB   NOUN"
    defb 0
legend_text: defm "Try TAKE LAMP, LOOK, SEARCH KEY"
    defb 0
    include "parser.inc"
    include "build/vocabulary.inc"
    include "../../framework/game-loop/frame.inc"
    include "../../rendering/character-printing/characters.inc"
    include "../../rendering/numeric-display/numeric.inc"
    end start
