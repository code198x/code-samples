; Lesson 006: Match the Rhythm
; Rhythm matching game with timing detection and hit/miss feedback

        * = $0801       ; BASIC start address
        ; BASIC stub: 10 SYS 2064
        !byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00

        * = $0810       ; Machine code start

; ============================================================================
; CONSTANTS
; ============================================================================
SCREEN = $0400          ; Screen RAM
COLOR  = $d800          ; Color RAM

TIMER_LO = $2d          ; CIA Timer for 60Hz (PAL)
TIMER_HI = $40

TIMING_WINDOW = 5       ; ±5 frames = generous timing window
QUARTER_NOTE = 30       ; 30 frames at 60fps = 0.5 seconds at 120 BPM

; State machine
STATE_PLAY  = 0         ; Playing current note
STATE_WAIT  = 1         ; Waiting for player input
STATE_SHOW  = 2         ; Showing result

; ============================================================================
; FREQUENCY TABLE
; ============================================================================
freq_lo: !byte $67, $72, $89, $aa, $ed, $3b, $94, $13
freq_hi: !byte $11, $12, $13, $14, $15, $17, $18, $1a

; ============================================================================
; PATTERN DATA - Simple 8-beat pattern
; ============================================================================
pattern: !byte 0, 2, 4, 5, 7, 5, 4, 2, $ff
timing:  !byte QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE
         !byte QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE, 0

; ============================================================================
; VARIABLES
; ============================================================================
game_state:     !byte $00       ; Current game state
note_index:     !byte $00       ; Current position in pattern
frame_counter:  !byte $00       ; Global frame counter
note_start:     !byte $00       ; Frame when current note started
result_timer:   !byte $00       ; Countdown for result display

; ============================================================================
; INITIALIZATION
; ============================================================================
        jmp init

init:
        jsr clear_sid
        jsr init_timer
        jsr clear_screen
        jsr show_instructions

        lda #$00
        sta note_index
        sta frame_counter
        sta game_state          ; Start in PLAY state
        jmp main_loop

; ============================================================================
; MAIN LOOP
; ============================================================================
main_loop:
        jsr wait_frame
        inc frame_counter       ; Track frames for timing

        ; Handle result display timer
        lda result_timer
        beq check_state
        dec result_timer
        bne check_state
        jsr clear_message       ; Timer expired, clear message

check_state:
        lda game_state
        cmp #STATE_PLAY
        beq do_play
        cmp #STATE_WAIT
        beq do_wait
        jmp main_loop

; ============================================================================
; STATE: PLAY NOTE
; ============================================================================
do_play:
        ; Check if pattern complete
        ldx note_index
        lda pattern,x
        cmp #$ff
        beq game_complete

        ; Play the note
        jsr play_note

        ; Record when note started
        lda frame_counter
        sta note_start

        ; Move to waiting for input
        lda #STATE_WAIT
        sta game_state
        jmp main_loop

; ============================================================================
; STATE: WAIT FOR INPUT
; ============================================================================
do_wait:
        ; Check for spacebar press
        jsr scan_spacebar
        bcs key_pressed         ; Carry set = key pressed

        ; No key - check if note duration expired (automatic miss)
        lda frame_counter
        sec
        sbc note_start          ; A = frames since note started
        ldx note_index
        cmp timing,x
        bcc main_loop           ; Still time left

        ; Time's up - automatic miss
        jsr show_miss
        jmp next_note

key_pressed:
        ; Calculate timing: frames since note started
        lda frame_counter
        sec
        sbc note_start

        ; Check if within timing window
        cmp #TIMING_WINDOW
        bcc hit                 ; Within window = HIT!

        ; Too early or too late = MISS
        jsr show_miss
        jmp next_note

hit:
        jsr show_hit
        jmp next_note

; ============================================================================
; ADVANCE TO NEXT NOTE
; ============================================================================
next_note:
        ; Turn off current note
        lda #$20
        sta $d404

        ; Move to next note
        inc note_index

        ; Back to PLAY state
        lda #STATE_PLAY
        sta game_state
        jmp main_loop

; ============================================================================
; GAME COMPLETE
; ============================================================================
game_complete:
        jsr show_complete
freeze: jmp freeze              ; Freeze at end

; ============================================================================
; PLAY NOTE - Play current note from pattern
; ============================================================================
play_note:
        ldx note_index
        lda pattern,x
        tay                     ; Y = note index

        lda freq_lo,y
        sta $d400               ; Set frequency
        lda freq_hi,y
        sta $d401

        lda #$21                ; Sawtooth + gate ON
        sta $d404
        rts

; ============================================================================
; SCAN SPACEBAR - Check if spacebar pressed
; ============================================================================
scan_spacebar:
        lda #$7f                ; Select column 7
        sta $dc00
        lda $dc01               ; Read rows
        and #$10                ; Check row 4 (spacebar)
        beq space_down
        clc                     ; No key pressed
        rts
space_down:
        sec                     ; Key pressed
        rts

; ============================================================================
; SHOW HIT - Display HIT message in green
; ============================================================================
show_hit:
        ldx #$00
hit_loop:
        lda msg_hit,x
        beq hit_done
        sta SCREEN+40*12+17,x
        lda #$05                ; Green
        sta COLOR+40*12+17,x
        inx
        jmp hit_loop
hit_done:
        lda #60                 ; Show for 1 second
        sta result_timer
        rts

msg_hit: !text "hit!",0

; ============================================================================
; SHOW MISS - Display MISS message in red
; ============================================================================
show_miss:
        ldx #$00
miss_loop:
        lda msg_miss,x
        beq miss_done
        sta SCREEN+40*12+17,x
        lda #$02                ; Red
        sta COLOR+40*12+17,x
        inx
        jmp miss_loop
miss_done:
        lda #60                 ; Show for 1 second
        sta result_timer
        rts

msg_miss: !text "miss",0

; ============================================================================
; CLEAR MESSAGE - Clear result display area
; ============================================================================
clear_message:
        ldx #$05
clear_loop:
        lda #$20                ; Space
        sta SCREEN+40*12+17,x
        dex
        bpl clear_loop
        rts

; ============================================================================
; SHOW INSTRUCTIONS
; ============================================================================
show_instructions:
        ldx #$00
inst_loop:
        lda msg_inst,x
        beq inst_done
        sta SCREEN+40*2+7,x
        lda #$0e                ; Light blue
        sta COLOR+40*2+7,x
        inx
        jmp inst_loop
inst_done:
        rts

msg_inst: !text "press space on the beat!",0

; ============================================================================
; SHOW COMPLETE
; ============================================================================
show_complete:
        ldx #$00
comp_loop:
        lda msg_comp,x
        beq comp_done
        sta SCREEN+40*12+12,x
        lda #$07                ; Yellow
        sta COLOR+40*12+12,x
        inx
        jmp comp_loop
comp_done:
        rts

msg_comp: !text "pattern complete!",0

; ============================================================================
; CLEAR SCREEN
; ============================================================================
clear_screen:
        lda #$20                ; Space character
        ldx #$00
cs_loop1:
        sta SCREEN,x
        sta SCREEN+$100,x
        sta SCREEN+$200,x
        sta SCREEN+$2e8,x
        inx
        bne cs_loop1

        lda #$0e                ; Light blue
        ldx #$00
cs_loop2:
        sta COLOR,x
        sta COLOR+$100,x
        sta COLOR+$200,x
        sta COLOR+$2e8,x
        inx
        bne cs_loop2
        rts

; ============================================================================
; WAIT FRAME - Wait for 60Hz tick
; ============================================================================
wait_frame:
wf_loop:
        lda $dc0d
        and #$01
        beq wf_loop
        rts

; ============================================================================
; INIT TIMER - Set up CIA Timer A
; ============================================================================
init_timer:
        lda #$00
        sta $dc0e               ; Stop timer
        lda #TIMER_LO
        sta $dc04
        lda #TIMER_HI
        sta $dc05
        lda #$11                ; Start continuous
        sta $dc0e
        rts

; ============================================================================
; CLEAR SID
; ============================================================================
clear_sid:
        lda #$00
        ldx #$00
sid_loop:
        sta $d400,x
        inx
        cpx #$1d
        bne sid_loop

        lda #$08                ; Attack=0, Decay=8
        sta $d405
        lda #$b0                ; Sustain=11, Release=0
        sta $d406
        lda #$0f                ; Max volume
        sta $d418
        rts
