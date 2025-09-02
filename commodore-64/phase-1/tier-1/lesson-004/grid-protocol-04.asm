; GRID PROTOCOL: Enhanced Entity Control
; Lesson 4 - Refined movement with boundary awareness
; Year: 2085 - Post-Collapse Era
;
; Objective: Improve entity control with smooth movement and boundaries
; Output: Black screen, cyan border, refined entity control

;===============================================================================
; DIRECTIVES
;===============================================================================
!to "grid-protocol-04.prg", cbm

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
        ; Activate terminal
        lda #$00               ; Black void
        sta $d021
        lda #$03               ; Cyan signature
        sta $d020
        
        ; Purge data matrix
        jsr clear_screen
        
        ; Display status
        ldx #0
show_status:
        lda status_msg,x
        beq init_entity
        sta $0400+1*40+7,x     ; Top line, centered
        inx
        jmp show_status

;===============================================================================
; ENTITY INITIALIZATION
;===============================================================================
init_entity:
        ; Initialize position
        lda #160
        sta entity_x
        lda #120
        sta entity_y
        
        ; Deploy entity
        jsr deploy_entity
        
        ; Update position
        jsr update_entity_position
        
        ; Enable entity
        lda #$01
        sta $d015
        
        ; Set signature color
        lda #$03               ; Cyan
        sta $d027

;===============================================================================
; MAIN CONTROL LOOP
;===============================================================================
control_loop:
        jsr read_interface
        jsr control_entity
        jsr update_entity_position
        jsr wait_frame
        jmp control_loop

;===============================================================================
; SUBROUTINES
;===============================================================================

; Deploy entity
deploy_entity:
        ; Set data pointer
        lda #$0d
        sta $07f8
        
        ; Load pattern
        ldx #0
load_pattern:
        lda entity_pattern,x
        sta $0340,x
        inx
        cpx #63
        bne load_pattern
        rts

; Read control interface
read_interface:
        lda $dc00
        sta control_state
        rts

; Enhanced entity control with boundaries
control_entity:
        ; Check up
        lda control_state
        and #$01
        bne check_down
        
        ; Move up with boundary
        lda entity_y
        cmp #50                ; Top boundary
        bcc check_down
        sec
        sbc #2
        sta entity_y

check_down:
        lda control_state
        and #$02
        bne check_left
        
        ; Move down with boundary
        lda entity_y
        cmp #230               ; Bottom boundary
        bcs check_left
        clc
        adc #2
        sta entity_y

check_left:
        lda control_state
        and #$04
        bne check_right
        
        ; Move left with boundary check
        lda entity_x_msb
        bne skip_left          ; Already at X=0, can't go further left
        lda entity_x
        cmp #24                ; Left boundary
        bcc check_right
        sec
        sbc #2
        sta entity_x
        jmp check_right
skip_left:
        ; We're in MSB territory, move left
        lda entity_x
        sec
        sbc #2
        sta entity_x
        bcs check_right        ; No underflow
        ; Handle underflow - crossed from 256+ to <256
        lda #0
        sta entity_x_msb

check_right:
        lda control_state
        and #$08
        bne control_done
        
        ; Move right with proper MSB handling
        lda entity_x_msb
        bne move_right_msb     ; Already using MSB
        
        ; Check if we'll cross into MSB territory
        lda entity_x
        clc
        adc #2
        bcc no_msb_needed      ; No overflow, normal move
        ; We overflowed - need to set MSB
        sta entity_x
        lda #1
        sta entity_x_msb
        jmp control_done
        
no_msb_needed:
        sta entity_x
        jmp control_done
        
move_right_msb:
        ; Already in MSB territory, check screen limit
        lda entity_x
        cmp #64                ; 320-256=64 (screen width 344 minus sprite width 24)
        bcs control_done
        clc
        adc #2
        sta entity_x

control_done:
        rts

; Update entity position in hardware
update_entity_position:
        lda entity_x
        sta $d000
        
        ; Handle X MSB for sprite 0
        lda entity_x_msb
        beq clear_msb
        lda #$01               ; Set bit 0 for sprite 0
        sta $d010
        jmp update_y
clear_msb:
        lda #$00
        sta $d010
update_y:
        lda entity_y
        sta $d001
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

; Entity position
entity_x:       !byte 160
entity_y:       !byte 120
entity_x_msb:   !byte 0        ; X position MSB (9th bit)

; Control state
control_state:  !byte 0

; Status message (screen codes)
status_msg:
        !byte 2,15,21,14,4,1,18,25,32  ; "BOUNDARY "
        !byte 3,15,14,20,18,15,12,32   ; "CONTROL "
        !byte 1,3,20,9,22,5             ; "ACTIVE"
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
; Boundary System:
; - Top: Y = 50
; - Bottom: Y = 230
; - Left: X = 24
; - Right: X = 320 (64 with MSB set, accounts for 24-pixel sprite width)
; 
; The VIC-II uses 9-bit X coordinates for sprites:
; - Bits 0-7: stored in $D000/$D002/$D004/etc
; - Bit 8 (MSB): stored in $D010 (one bit per sprite)
; Sprite boundaries account for sprite width to prevent off-screen rendering