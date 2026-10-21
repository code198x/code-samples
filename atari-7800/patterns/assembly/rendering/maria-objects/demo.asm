ML = $80
ML_CAPACITY = 4
LIST = $1900
RESULT = $1b00
DLL = $1800
EMPTY = $1920
* = $4000
start:
    sei
    cld
    ldx #$ff
    txs
    lda #7
    sta $01
    lda #0
    sta $3c
    sta $20                   ; background
    lda #14
    sta $21                   ; palette 0 colour 1
    lda #6
    sta $22
    lda #10
    sta $23
    lda #<LIST
    sta ML
    lda #>LIST
    sta ML+1
    jsr maria_begin
    lda #<graphics
    sta ML+2
    lda #>graphics
    sta ML+3
    lda #2
    sta ML+4
    lda #0
    sta ML+5
    lda #32
    sta ML+6
    jsr maria_append
    lda ML+8
    sta RESULT
    lda #152                  ; exactly fits eight pixels at right edge
    sta ML+6
    jsr maria_append
    lda ML+8
    sta RESULT+1
    inc ML+6                  ; reject visible overrun before writing
    jsr maria_append
    lda ML+8
    sta RESULT+2
    lda #$a5
    sta LIST+18
    lda #0
    sta EMPTY
    sta EMPTY+1
    ldx #47
copy_dll:
    lda dll_template,x
    sta DLL,x
    dex
    bpl copy_dll
    lda #>DLL
    sta $2c
    lda #<DLL
    sta $30
ready:
    bit $28
    bpl ready
    lda #$40
    sta $3c
running:
    jmp running               ; immutable lists: CPU has no raster work
irq:
    rti
!source "objects.inc"
    !align 255,0
dll_template:
    !for zone,0,15 {
        !if zone = 3 { !byte $0f,>LIST,<LIST } else { !byte $0f,>EMPTY,<EMPTY }
    }
    !align 255,0
graphics:
; Original glyph, row zero at base + 15*256; pixel zero is transparent.
    !byte $00,$00
    !fill 254,0
    !byte $10,$10
    !fill 254,0
    !byte $10,$10
    !fill 254,0
    !byte $10,$10
    !fill 254,0
    !byte $10,$10
    !fill 254,0
    !byte $10,$10
    !fill 254,0
    !byte $10,$10
    !fill 254,0
    !byte $15,$50
    !fill 254,0
    !byte $15,$50
    !fill 254,0
    !byte $10,$10
    !fill 254,0
    !byte $10,$10
    !fill 254,0
    !byte $10,$10
    !fill 254,0
    !byte $10,$10
    !fill 254,0
    !byte $05,$40
    !fill 254,0
    !byte $05,$40
    !fill 254,0
    !byte $00,$00
    !fill 254,0
    !fill $fffa-*, $ff
    !word irq,start,irq
