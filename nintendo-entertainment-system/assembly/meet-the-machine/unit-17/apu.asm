; ============================================================================
; Meet the Machine (NES) - Unit 17: The Machine Speaks Back
;
; Unit 10 taught the machine to hear you. This one teaches it to answer. The NES
; has a sound chip - the APU - built into the same 2A03 as the CPU. You set a
; pulse channel's volume, pitch and length, switch it on, and it holds the note
; on its own while the CPU does nothing.
; ============================================================================

.segment "HEADER"
    .byte "NES", $1a
    .byte 2
    .byte 1
    .byte $00, $00

.segment "CODE"

reset:
    sei
    cld
    ldx #$40
    stx $4017               ; silence the frame-counter IRQ
    ldx #$ff
    txs
    inx
    stx $2000               ; rendering + NMI off while we set up
    stx $2001
    stx $4010
warm1:
    bit $2002
    bpl warm1
warm2:
    bit $2002
    bpl warm2

    ; --- backdrop colour: blue, so the screen shows it's running ---
    bit $2002
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    lda #$11                ; blue
    sta $2007

    ; --- clear the nametable to the blank tile (a flat screen) ---
    bit $2002
    lda #$20
    sta $2006
    lda #$00
    sta $2006
    ldx #0
    ldy #4                  ; 4 pages = 1024 bytes (960 tiles + attributes)
clear:
    lda #$00
    sta $2007
    inx
    bne clear
    dey
    bne clear

    ; ----------------------------------------------- YOUR CODE START
    ; --- play a tone on pulse channel 1 ---
    lda #$01
    sta $4015               ; switch pulse 1 on
    lda #$bf
    sta $4000               ; 50% duty, hold the note, constant volume 15
    lda #$00
    sta $4001               ; sweep off (leave the pitch alone)
    lda #$fd
    sta $4002               ; timer low byte  -> the pitch
    lda #$08
    sta $4003               ; timer high + length  -> the note starts
    ; ------------------------------------------------- YOUR CODE END

    ; --- turn the picture on so the blue backdrop shows ---
    bit $2002
    lda #$00
    sta $2006
    sta $2006
    sta $2005
    sta $2005
    lda #$0a
    sta $2001

forever:
    jmp forever

nmi:
    rti
irq:
    rti

.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

.segment "CHARS"
    .res 8192, $00
