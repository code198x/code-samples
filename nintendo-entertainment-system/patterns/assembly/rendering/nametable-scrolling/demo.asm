; Original NROM-256/CHR-ROM scene. Vertical mirroring gives horizontal space.
.segment "HEADER"
    .byte "NES",$1a,2,1,1,0
    .byte 0,0,0,0,0,0,0,0
.segment "BSS"
scroll_x: .res 1
scroll_y: .res 1
nametable: .res 1
ppu_ctrl_shadow: .res 1
ready: .res 1
frames: .res 1
presented_objects: .res 1
object_count: .res 1
first_object: .res 1
oam_used: .res 1
oam_status: .res 1
objects_left: .res 1
object_index: .res 1
obj_x: .res 64
obj_y: .res 64
obj_tile: .res 64
obj_attr: .res 64
obj_active: .res 64
.segment "CODE"
oam_buffer = $0200
reset:
    sei
    cld
    ldx #$ff
    txs
    inx
    stx $2000
    stx $2001
    stx $4010
    stx $4015
    lda #$40
    sta $4017
    lda #0
clear_ram:
    sta $0000,x
    sta $0100,x
    sta $0200,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne clear_ram
warmup_one:
    bit $2002
    bpl warmup_one
warmup_two:
    bit $2002
    bpl warmup_two
    ; Full tables loaded with rendering off. Attributes zero use palette 0.
    bit $2002
    lda #$20
    sta $2006
    lda #0
    sta $2006
    ldy #8
fill_page:
    ldx #0
fill_byte:
    txa
    and #1
    clc
    adc #1
    sta $2007
    inx
    bne fill_byte
    dey
    bne fill_page
    ; Clear the two attribute tables.
    lda #$23
    jsr clear_attributes
    lda #$27
    jsr clear_attributes
    lda #$3f
    sta $2006
    lda #0
    sta $2006
    ldx #0
palette_loop:
    lda palette,x
    sta $2007
    inx
    cpx #32
    bne palette_loop
    ldx #0
init_objects:
    txa
    asl
    asl
    asl
    asl
    clc
    adc #20
    sta obj_x,x
    lda #99
    sta obj_y,x
    lda #3
    sta obj_tile,x
    lda #0
    sta obj_attr,x
    lda #1
    sta obj_active,x
    inx
    cpx #12
    bne init_objects
    lda #12
    sta object_count
    lda #$80
    sta ppu_ctrl_shadow
    sta $2000
main:
    lda ready
    bne main
    jsr scroll_right
    ; Two image frames share the same object state and OAM builder.
    lda frames
    lsr
    lsr
    lsr
    lsr
    and #1
    clc
    adc #3
    ldx #11
animate_objects:
    sta obj_tile,x
    dex
    bpl animate_objects
    jsr build_oam
    jsr advance_priority
    lda #1
    sta ready
    jmp main
clear_attributes:
    sta $2006
    lda #$c0
    sta $2006
    lda #0
    ldx #64
clear_attribute_byte:
    sta $2007
    dex
    bne clear_attribute_byte
    rts
nmi:
    pha
    txa
    pha
    tya
    pha
    lda ready
    beq nmi_done
    lda #0
    sta $2003
    lda #2
    sta $4014
    jsr set_scroll
    lda oam_used
    sta presented_objects
    lda #$1e
    sta $2001
    lda #0
    sta ready
    inc frames
nmi_done:
    pla
    tay
    pla
    tax
    pla
    rti
irq: rti
palette:
    .byte $0f,$12,$21,$30,$0f,$12,$21,$30,$0f,$12,$21,$30,$0f,$12,$21,$30
    .byte $0f,$27,$30,$16,$0f,$27,$30,$16,$0f,$27,$30,$16,$0f,$27,$30,$16
.include "scroll.inc"
.include "../multi-sprite-oam/oam.inc"
.segment "VECTORS"
    .word nmi,reset,irq
.segment "CHARS"
    .res 16,0
    .byte $aa,$55,$aa,$55,$aa,$55,$aa,$55
    .res 8,0
    .byte $ff,$81,$81,$81,$81,$81,$81,$ff
    .res 8,0
    .byte $18,$3c,$7e,$db,$ff,$5a,$24,0
    .res 8,0
    .byte $18,$3c,$7e,$db,$ff,$24,$42,$81
    .res 8,0
    .res 8112,0
