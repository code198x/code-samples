; OSWORD7 copies this eight-byte SOUND block into MOS's sound system.
; Flush channel 1, amplitude -15, pitch 100, duration 2 twentieths of a second.
; MOS services audio asynchronously. Call only from main, not inside IRQ.
; Changes A/X/Y/flags. Caller owns channel 1; no music arbitration here.
trigger_sound:
    lda #7
    ldx #<sound_block
    ldy #>sound_block
    jmp OSWORD
sound_block: !word 17,-15,100,2
