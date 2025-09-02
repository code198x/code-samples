; GRID PROTOCOL: Operator Control Interface
; Lesson 3 - Manual entity control via operator interface
; Year: 2085 - Post-Collapse Era
;
; Objective: Take direct control of Mobile Data Entities
; Output: Black screen, cyan border, manually controlled entity

;===============================================================================
; DIRECTIVES
;===============================================================================
!to "grid-protocol-03.prg", cbm

;===============================================================================
; GATEWAY PROTOCOL (BASIC STUB)
;===============================================================================
*=$0801
        !byte $0b,$08          ; Next line pointer
        !byte $0a,$00          ; Line number: 10
        !byte $9e              ; SYS token
        !byte $32,$30,$36,$31  ; "2061" as PETSCII
        !byte $00              ; End of line
        !byte $00,$00          ; End of program

;===============================================================================
; GRID INITIALIZATION
;===============================================================================
*=$080d
grid_init:
        ; Activate terminal visuals
        lda #$00               ; Black void
        sta $d021
        lda #$03               ; Cyan signature
        sta $d020
        
        ; Purge data matrix
        jsr clear_screen
        
        ; Display control status
        ldx #0
show_status:
        lda status_msg,x
        beq show_instructions
        sta $0400+22*40+10,x   ; Row 22, centered (21 chars)
        inx
        jmp show_status
        
show_instructions:
        ldx #0
show_instr_loop:
        lda instruction_msg,x
        beq deploy_start
        sta $0400+24*40+5,x    ; Bottom row, centered (30 chars)
        inx
        jmp show_instr_loop

;===============================================================================
; ENTITY DEPLOYMENT
;===============================================================================
deploy_start:
        jsr deploy_entity
        
        ; Main control loop
control_loop:
        jsr wait_frame
        jsr read_interface     ; Read operator input
        jsr control_entity     ; Apply manual control
        jmp control_loop

;===============================================================================
; SUBROUTINES
;===============================================================================

; Deploy entity
deploy_entity:
        ; Set entity data pointer
        lda #$0d               ; $0340
        sta $07f8
        
        ; Load pattern
        ldx #0
load_pattern:
        lda entity_pattern,x
        sta $0340,x
        inx
        cpx #63
        bne load_pattern
        
        ; Enable entity
        lda #$01
        sta $d015
        
        ; Set signature color
        lda #$03               ; Cyan
        sta $d027
        
        ; Center position
        lda #160
        sta $d000              ; X
        lda #0
        sta $d010              ; X MSB
        lda #120
        sta $d001              ; Y
        
        rts

; Read Operator Control Interface (joystick port 2)
read_interface:
        lda $dc00              ; CIA1 Port A (joystick 2)
        sta control_state
        rts

; Apply manual control
control_entity:
        ; Check up (bit 0)
        lda control_state
        and #$01
        bne check_down
        
        ; Move up
        lda $d001
        sec
        sbc #2
        cmp #50                ; Top boundary
        bcc skip_up
        sta $d001
skip_up:

check_down:
        ; Check down (bit 1)
        lda control_state
        and #$02
        bne check_left
        
        ; Move down
        lda $d001
        clc
        adc #2
        cmp #230               ; Bottom boundary
        bcs skip_down
        sta $d001
skip_down:

check_left:
        ; Check left (bit 2)
        lda control_state
        and #$04
        bne check_right
        
        ; Move left
        lda $d000
        sec
        sbc #2
        sta $d000
        bcs skip_left          ; No underflow
        
        ; Handle X underflow
        lda $d010
        eor #$01
        sta $d010
skip_left:

check_right:
        ; Check right (bit 3)
        lda control_state
        and #$08
        bne control_done
        
        ; Move right
        lda $d000
        clc
        adc #2
        sta $d000
        bcc skip_right         ; No overflow
        
        ; Handle X overflow
        lda $d010
        eor #$01
        sta $d010
skip_right:

control_done:
        rts

; Clear screen
clear_screen:
        ldx #0
clear_loop:
        lda #$20               ; Space
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        lda #$03               ; Cyan
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $db00,x
        inx
        bne clear_loop
        rts

; Wait for frame
wait_frame:
        lda #251
wait_raster:
        cmp $d012
        bne wait_raster
        rts

;===============================================================================
; DATA SECTION
;===============================================================================

; Control state storage
control_state:
        !byte 0

; Messages (screen codes)
status_msg:
        !byte 13,1,14,21,1,12,32,3,15,14,20,18,15,12,32  ; "MANUAL CONTROL "
        !byte 1,3,20,9,22,5                                ; "ACTIVE"
        !byte 0

instruction_msg:
        !byte 21,19,5,32,10,15,25,19,20,9,3,11,32,20,15,32  ; "USE JOYSTICK TO "
        !byte 3,15,14,20,18,15,12,32,5,14,20,9,20,25         ; "CONTROL ENTITY"
        !byte 0

; Entity pattern (diamond)
entity_pattern:
        !byte %00000000,%00011000,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%01111110,%00000000
        !byte %00000001,%11111111,%10000000
        !byte %00000011,%11111111,%11000000
        !byte %00000111,%11111111,%11100000
        !byte %00001111,%11111111,%11110000
        !byte %00011111,%11111111,%11111000
        !byte %00111111,%11111111,%11111100
        !byte %01111111,%11111111,%11111110
        !byte %11111111,%11111111,%11111111
        !byte %01111111,%11111111,%11111110
        !byte %00111111,%11111111,%11111100
        !byte %00011111,%11111111,%11111000
        !byte %00001111,%11111111,%11110000
        !byte %00000111,%11111111,%11100000
        !byte %00000011,%11111111,%11000000
        !byte %00000001,%11111111,%10000000
        !byte %00000000,%01111110,%00000000
        !byte %00000000,%00111100,%00000000
        !byte %00000000,%00011000,%00000000

;===============================================================================
; TECHNICAL NOTES
;===============================================================================
; Control Interface:
; - $DC00: CIA1 Port A (Joystick 2)
;   Bit 0: Up
;   Bit 1: Down
;   Bit 2: Left
;   Bit 3: Right
;   Bit 4: Fire
;   (0 = pressed, 1 = released)