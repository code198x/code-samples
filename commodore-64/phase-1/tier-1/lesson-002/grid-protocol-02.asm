; GRID PROTOCOL: Mobile Data Entity Deployment  
; Lesson 2 - Deploy autonomous scouts into the Grid
; Year: 2085 - Post-Collapse Era
;
; Objective: Deploy and control hardware sprites as Mobile Data Entities
; Output: Black screen with cyan border, moving cyan diamond entity

;===============================================================================
; DIRECTIVES
;===============================================================================
!to "grid-protocol-02.prg", cbm

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
        lda #$00               ; Black void (data absence)
        sta $d021              ; Background register
        lda #$03               ; Cyan (Grid signature)
        sta $d020              ; Border register
        
        ; Purge data matrix
        jsr clear_screen
        
        ; Display deployment status
        ldx #0
show_status:
        lda status_msg,x
        beq deploy_start
        sta $0400+24*40+12,x   ; Bottom line, centered
        inx
        jmp show_status

;===============================================================================
; ENTITY DEPLOYMENT
;===============================================================================
deploy_start:
        jsr deploy_entity      ; Initialize entity
        
        ; Main patrol loop
patrol_loop:
        jsr wait_frame         ; Grid frequency sync
        jsr entity_patrol      ; Update position
        jmp patrol_loop        ; Continuous patrol

;===============================================================================
; SUBROUTINES
;===============================================================================

; Deploy Mobile Data Entity
deploy_entity:
        ; Set entity data pointer
        lda #$0d               ; $0340 (13 * 64)
        sta $07f8              ; Entity 0 pointer
        
        ; Load entity pattern
        ldx #0
load_pattern:
        lda entity_pattern,x
        sta $0340,x
        inx
        cpx #63
        bne load_pattern
        
        ; Enable entity
        lda #$01               ; Entity 0 active
        sta $d015              ; Enable register
        
        ; Set signature color
        lda #$03               ; Cyan (scout)
        sta $d027              ; Entity 0 color
        
        ; Initial deployment position
        lda #24                ; Left edge
        sta $d000              ; X position
        lda #0
        sta $d010              ; X MSB clear
        lda #120               ; Center Y
        sta $d001              ; Y position
        
        rts

; Autonomous patrol routine
entity_patrol:
        ; Update X position
        lda $d000
        clc
        adc #2                 ; Patrol speed
        sta $d000
        
        ; Check boundary
        bne no_wrap
        
        ; Handle X overflow
        lda $d010
        eor #$01               ; Toggle MSB
        sta $d010
        
no_wrap:
        ; Check right boundary
        lda $d010
        and #$01
        beq patrol_done
        
        lda $d000
        cmp #64                ; Right limit
        bcc patrol_done
        
        ; Reset to left edge
        lda #24
        sta $d000
        lda #0
        sta $d010
        
patrol_done:
        rts

; Clear screen matrix
clear_screen:
        ldx #0
clear_loop:
        lda #$20               ; Space character
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        lda #$03               ; Cyan color
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $db00,x
        inx
        bne clear_loop
        
        ; Final bytes (handle exact 1000)
        ldx #0
clear_final:
        lda #$20               ; Space
        sta $0700,x
        lda #$03               ; Cyan
        sta $db00,x
        inx
        cpx #232
        bne clear_final
        rts

; Wait for Grid frequency sync
wait_frame:
        lda #251               ; Raster line 251
wait_raster:
        cmp $d012
        bne wait_raster
        rts

;===============================================================================
; DATA SECTION
;===============================================================================

; Status message (screen codes)
status_msg:
        !byte 5,14,20,9,20,25,32,4,5,16,12,15,25,5,4  ; "ENTITY DEPLOYED"
        !byte 0

; Entity pattern - diamond scout configuration
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
; Entity Registers:
; - $D000-$D001: Entity 0 position (X/Y)
; - $D010: X position MSB for all entities
; - $D015: Entity enable register
; - $D027: Entity 0 color
; - $07F8: Entity 0 data pointer
;
; Grid Standards:
; - Cyan: Scout entities
; - Diamond: Standard patrol configuration
; - Speed 2: Normal patrol velocity