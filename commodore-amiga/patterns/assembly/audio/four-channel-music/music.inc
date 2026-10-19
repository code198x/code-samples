; Four continuous waveform voices; a bounded sequencer, not a MOD decoder.
; A500 OCS PAL; caller owns all four Paula channels, their interrupt requests
; and audio-modulation bits. DMA must be off and settled before music_init.
; The instrument and routine state are writable/readable Chip RAM for playback.
; music_init changes A2/A5/D5/CCR; music_tick changes A0/A1/A2/D0/D5/D7/CCR.
; Call tick once per chosen update; six intervals separate row starts.
; 0 means HOLD, 1..24 index periods. The built-in table is complete and bounded.
MUSIC_TEMPO equ 6
MUSIC_ROWS equ 8
music_init:
    lea $dff000,a5
    move.w #$0780,$09a(a5)       ; no audio IRQ consumer in this polling caller
    move.w #$0780,$09c(a5)
    move.w #$00ff,$09e(a5)       ; disable audio period/volume modulation
    clr.w music_row
    move.w #1,music_timer
    lea $0a0(a5),a2
    moveq #3,d5
music_init_voice:
    move.l #instrument,(a2)      ; LC at channel base +0
    move.w #instrument_words,4(a2)
    move.w #856,6(a2)
    clr.w 8(a2)                 ; silent until the first note on this voice
    adda.w #$10,a2
    dbf d5,music_init_voice
    move.w #$820f,$096(a5)       ; start only after EVERY channel is configured
    rts

music_tick:
    subq.w #1,music_timer
    bne music_tick_done
    move.w #MUSIC_TEMPO,music_timer
    move.w music_row,d7
    mulu #8,d7                  ; row = four WORD note indices
    lea music_pattern,a0
    adda.w d7,a0
    lea $0a0(a5),a2
    moveq #3,d5
music_next_voice:
    move.w (a0)+,d0
    beq music_hold_voice
    subq.w #1,d0               ; note1 is the first table entry
    add.w d0,d0
    lea music_periods,a1
    move.w 0(a1,d0.w),6(a2)     ; PERIOD at channel base +6
    move.w #64,8(a2)            ; VOLUME at channel base +8
music_hold_voice:
    adda.w #$10,a2
    dbf d5,music_next_voice
    addq.w #1,music_row
    cmp.w #MUSIC_ROWS,music_row
    blo music_tick_done
    clr.w music_row
music_tick_done:
    rts

; Caller waits two sample periods after this before restarting/reusing data.
; A5 remains CUSTOM; other registers unchanged, CCR changes.
music_stop:
    move.w #$000f,$096(a5)
    rts

music_row: dc.w 0
music_timer: dc.w 0
music_periods:
    dc.w 856,808,762,720,678,640,604,570,538,508,480,453
    dc.w 428,404,381,360,339,320,302,285,269,254,240,226
music_pattern:
    dc.w 13,17,20,1
    dc.w 17,0,0,0
    dc.w 20,13,17,1
    dc.w 17,0,0,0
    dc.w 13,17,20,1
    dc.w 17,0,0,0
    dc.w 20,13,17,1
    dc.w 17,0,0,0
    even
instrument: dc.b 0,49,90,117,127,117,90,49,0,-49,-90,-117,-127,-117,-90,-49
instrument_words equ (*-instrument)/2
