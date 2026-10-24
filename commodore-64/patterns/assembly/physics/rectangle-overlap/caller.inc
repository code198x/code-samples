; Standalone PAL caller. Owns display, ROM banking, interrupts, $fb/$fc.
start:
    sei
    lda #$7f
    sta $dc0d
    sta $dd0d
    lda $dc0d
    lda $dd0d
    lda #$35
    sta $01
    lda #<nmi_return
    sta $fffa
    lda #>nmi_return
    sta $fffb
    lda #0
    sta $dc0e
    sta $dc0f
    sta $d015
    sta $d020
    sta $d021
    lda $dd02
    ora #3
    sta $dd02
    lda $dd00
    ora #3
    sta $dd00
    lda #$14
    sta $d018
    lda #$1b
    sta $d011
    lda #8
    sta $d016
    ldx #0
clear_screen:
    lda #32
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $06e8,x
    lda #1
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $dae8,x
    inx
    bne clear_screen
; A guest-owned second caller traverses supplied cases; the host only observes.
    lda #<case_table
    sta $fb
    lda #>case_table
    sta $fc
    ldx #0
case_loop:
    ldy #7
copy_case:
    lda ($fb),y
    sta rect_a,y
    dey
    bpl copy_case
    ldy #$5a
    jsr boxes_overlap
    lda #0
    rol
    sta results,x
    tya
    cmp #$5a
    beq preserved_y
    jmp failed
preserved_y:
    clc
    lda $fb
    adc #8
    sta $fb
    bcc next_case
    inc $fc
next_case:
    inx
    cpx #CASE_COUNT
    bne case_loop
    lda #$a5
    sta completed
; Customisation is data: replace B's four edges, leaving the routine unchanged.
    ldx #7
copy_example:
    lda example,x
    sta rect_a,x
    dex
    bpl copy_example
    jsr boxes_overlap
    lda #0
    rol
    sta result
    ora #48
    sta $0400
; Draw a small diagnostic grid. It is deliberately separate from collision.
    lda #<$0428
    sta $fb
    lda #>$0428
    sta $fc
    lda #0
    sta row
row_loop:
    ldy #0
column_loop:
    lda #32
    sta cell
    cpy rect_a
    bcc test_b
    cpy rect_a+2
    bcs test_b
    lda row
    cmp rect_a+1
    bcc test_b
    cmp rect_a+3
    bcs test_b
    lda #1
    sta cell
test_b:
    cpy rect_b
    bcc put_cell
    cpy rect_b+2
    bcs put_cell
    lda row
    cmp rect_b+1
    bcc put_cell
    cmp rect_b+3
    bcs put_cell
    lda cell
    cmp #1
    bne only_b
    lda #24
    bne save_cell
only_b:
    lda #2
save_cell:
    sta cell
put_cell:
    lda cell
    sta ($fb),y
    iny
    cpy #40
    bne column_loop
    clc
    lda $fb
    adc #40
    sta $fb
    bcc next_row
    inc $fc
next_row:
    inc row
    lda row
    cmp #10
    bne row_loop
    lda #$ef
    sta ready
hold:
    jmp hold
failed:
    jmp failed
nmi_return: rti
row: !byte 0
cell: !byte 0
completed: !byte 0
ready: !byte 0
result: !byte 0
results: !fill CASE_COUNT,0
