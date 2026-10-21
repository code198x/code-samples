PF_BUFFER = $80
PF = $c8
RESULT = $d8
* = $f000
start:
    sei
    cld
    ldx #$ff
    txs
    lda #2
    sta $01
    lda #0
    sta $00
    sta $09
    lda #MAZE_REFLECT
    sta $0a                   ; caller configuration: 0 repeat, 1 reflect
; BEGIN CUSTOM COLOUR
    lda #$46                  ; chosen NTSC foreground; background stays black
    sta $08
; END CUSTOM COLOUR
; BEGIN CUSTOM PICTURE
    jsr pf_clear
    lda #1
    sta PF+4
    lda #19
    sta PF+2
horizontal_walls:
    lda #0
    sta PF+3
    jsr pf_cell
    lda #23
    sta PF+3
    jsr pf_cell
    dec PF+2
    bpl horizontal_walls
    lda #22
    sta PF+3
vertical_walls:
    lda #0
    sta PF+2
    jsr pf_cell
    lda #19
    sta PF+2
    jsr pf_cell
    dec PF+3
    bne vertical_walls
    lda #9
    sta PF+2
    lda #13
    sta PF+3
inner_horizontal:
    lda PF+2
    cmp #4                    ; leave a passage
    beq next_horizontal
    jsr pf_cell
next_horizontal:
    dec PF+2
    bpl inner_horizontal
    lda #13
    sta PF+2
    lda #20
    sta PF+3
inner_vertical:
    lda PF+3
    cmp #16                   ; another passage
    beq next_vertical
    jsr pf_cell
next_vertical:
    dec PF+3
    lda PF+3
    cmp #7
    bne inner_vertical
    lda #4                    ; doorway: erase one top-wall cell
    sta PF+2
    lda #0
    sta PF+3
    sta PF+4
    jsr pf_cell
    lda #<glyph
    sta PF
    lda #>glyph
    sta PF+1
    lda #2
    sta PF+2
    lda #4
    sta PF+3
    jsr pf_stamp
    lda PF+5
    sta RESULT
    lda #$a5
    sta $e8
    sta $eb
; END CUSTOM PICTURE
ready:
frame:
    lda #2
    sta $01
    sta $02
    sta $00
    sta $02
    sta $02
    sta $02
    lda #0
    sta $00
    ldx #36                   ; kernel begins with its own WSYNC
blank:
    sta $02
    dex
    bne blank
    lda #0
    sta $0d
    sta $0e
    sta $0f
    sta $01
    jsr pf_kernel
    sta $02                   ; finish final picture line, then blank
    lda #2
    sta $01
    ldx #29                   ; one extra WSYNC at frame start = 30 overscan
overscan:
    sta $02
    dex
    bne overscan
    jmp frame
!source "../playfield.inc"
!source "../kernel.inc"
glyph:
; BEGIN CUSTOM GLYPH
    !byte 4,2,31,2,4,0,0      ; original right-pointing arrow
; END CUSTOM GLYPH
    !fill $fffc-*, $ff
    !word start,start
