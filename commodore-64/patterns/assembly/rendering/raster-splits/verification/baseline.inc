; =============================================================================
; RASTER SPLITS - C64
; A raster interrupt changes the background colour part-way down the screen
; CPU: A handful of cycles per split | Memory: ~70 bytes
; =============================================================================

VIC_RASTER  = $D012     ; Raster compare line (low 8 bits)
VIC_CTRL1   = $D011     ; Bit 7 = raster compare line bit 8
VIC_IRQ     = $D019     ; Interrupt status — write a 1 to a bit to acknowledge
VIC_IRQEN   = $D01A     ; Interrupt enable — bit 0 = raster
BGCOLOR     = $D021     ; Background colour
CIA1_ICR    = $DC0D     ; CIA #1 interrupt control
IRQVEC      = $0314     ; KERNAL IRQ vector (low byte / high byte)

SPLIT_LINE  = 130       ; Split the screen here

setup:
    sei                     ; no interrupts while we wire this up

    lda #<raster_irq        ; point the IRQ vector at our handler
    sta IRQVEC
    lda #>raster_irq
    sta IRQVEC+1

    lda #$7f                ; switch off CIA #1 timer interrupts...
    sta CIA1_ICR
    lda CIA1_ICR            ; ...and acknowledge any that were pending

    lda #$01                ; enable the VIC-II raster interrupt
    sta VIC_IRQEN

    lda #0                  ; first interrupt at the top of the screen
    sta VIC_RASTER
    lda VIC_CTRL1           ; clear compare-line bit 8 (our lines are < 256)
    and #$7f
    sta VIC_CTRL1

    lda #$01                ; acknowledge any pending raster interrupt
    sta VIC_IRQ

    cli                     ; interrupts back on
    rts

; The handler fires twice a frame: once at the top, once at SPLIT_LINE.
; Read the raster line to tell which, paint that zone, and aim at the other.
raster_irq:
    lda #$01
    sta VIC_IRQ             ; acknowledge the raster interrupt

    lda VIC_RASTER
    cmp #SPLIT_LINE
    bcs at_split

at_top:
    lda #$00               ; black above the split
    sta BGCOLOR
    lda #SPLIT_LINE        ; next interrupt: the split line
    sta VIC_RASTER
    jmp $EA81              ; KERNAL exit — restore registers and RTI

at_split:
    lda #$06               ; blue below the split
    sta BGCOLOR
    lda #0                 ; next interrupt: top of the next frame
    sta VIC_RASTER
    jmp $EA81
