; Lesson 007: Scoring System (Complete Game)
; First complete rhythm game with scoring, lives, levels, and HUD

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

QUARTER_NOTE = 30       ; 30 frames at 60fps = 0.5 seconds at 120 BPM

; State machine
STATE_PLAY  = 0         ; Playing current note
STATE_WAIT  = 1         ; Waiting for player input

; Timing windows per level (frames)
WINDOW_LEVEL1 = 5       ; Easy
WINDOW_LEVEL2 = 3       ; Medium
WINDOW_LEVEL3 = 2       ; Hard

; ============================================================================
; FREQUENCY TABLE
; ============================================================================
freq_lo: !byte $67, $72, $89, $aa, $ed, $3b, $94, $13, $a4, $45, $04, $da, $ce
freq_hi: !byte $11, $12, $13, $14, $15, $17, $18, $1a, $1b, $1d, $1f, $20, $22

; ============================================================================
; PATTERN DATA - Three levels of increasing difficulty
; ============================================================================
pattern1: !byte 0, 2, 4, 5, $ff                 ; Level 1: Simple 4-note
pattern2: !byte 4, 2, 0, 2, 4, 7, 5, $ff        ; Level 2: 7-note melody
pattern3: !byte 0, 4, 7, 12, 7, 4, 0, 2, 4, $ff ; Level 3: Octave jump

timing1:  !byte QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE, 0
timing2:  !byte QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE
          !byte QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE, 0
timing3:  !byte QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE
          !byte QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE, QUARTER_NOTE
          !byte QUARTER_NOTE, 0

; Level configuration (timing windows)
level_windows: !byte WINDOW_LEVEL1, WINDOW_LEVEL2, WINDOW_LEVEL3

; ============================================================================
; VARIABLES
; ============================================================================
game_state:     !byte $00       ; Current game state
note_index:     !byte $00       ; Current position in pattern
frame_counter:  !byte $00       ; Global frame counter
note_start:     !byte $00       ; Frame when current note started
result_timer:   !byte $00       ; Countdown for result display

; Game data
score:          !word $0000     ; 16-bit score
lives:          !byte $03       ; 3 lives to start
level:          !byte $01       ; Current level (1-3)
combo:          !byte $00       ; Consecutive hits

; Pattern pointers (16-bit) - must be in zero page for (ptr),y addressing
pattern_ptr = $fb               ; Zero page pointer
timing_ptr  = $fd               ; Zero page pointer

temp:           !byte $00       ; Temporary storage

; ============================================================================
; INITIALIZATION
; ============================================================================
        jmp init

init:
        jsr clear_sid
        jsr init_timer
        jsr clear_screen
        jsr init_game
        jmp main_loop

init_game:
        ; Reset game variables
        lda #$00
        sta score
        sta score+1
        sta note_index
        sta frame_counter
        sta combo
        sta game_state

        lda #$03
        sta lives

        lda #$01
        sta level

        ; Set pattern pointers to level 1
        lda #<pattern1
        sta pattern_ptr
        lda #>pattern1
        sta pattern_ptr+1

        lda #<timing1
        sta timing_ptr
        lda #>timing1
        sta timing_ptr+1

        jsr draw_hud
        jsr show_instructions
        rts

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
        jsr get_current_note
        cmp #$ff
        bne play_continue
        jmp level_complete

play_continue:
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
        jsr check_note_timeout
        bcc main_loop           ; Still time left

        ; Time's up - automatic miss
        jsr handle_miss
        jmp next_note

key_pressed:
        ; Calculate timing: frames since note started
        lda frame_counter
        sec
        sbc note_start

        ; Get current difficulty window
        ldx level
        dex
        lda level_windows,x
        sta temp

        ; Check timing accuracy
        lda frame_counter
        sec
        sbc note_start

        ; Perfect hit = exactly on beat (0-1 frames)
        cmp #$02
        bcc perfect_hit

        ; Good hit = within window
        cmp temp
        bcc good_hit

        ; Outside window = miss
        jsr handle_miss
        jmp next_note

perfect_hit:
        jsr add_score_100
        jsr show_perfect
        inc combo
        jmp next_note

good_hit:
        jsr add_score_50
        jsr show_hit
        inc combo
        jmp next_note

; ============================================================================
; HANDLE MISS
; ============================================================================
handle_miss:
        jsr show_miss
        dec lives
        lda #$00
        sta combo               ; Reset combo on miss

        ; Check game over
        lda lives
        bne hm_done
        jsr show_game_over
        jmp freeze              ; Freeze at game over

hm_done:
        jsr update_hud
        rts

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
        jsr update_hud
        jmp main_loop

; ============================================================================
; LEVEL COMPLETE
; ============================================================================
level_complete:
        ; Turn off sound
        lda #$20
        sta $d404

        jsr show_level_clear

        ; Check if all levels complete
        lda level
        cmp #$03
        beq victory

        ; Advance to next level
        inc level
        lda #$00
        sta note_index

        ; Update pattern pointer based on new level
        lda level
        cmp #$02
        beq set_level2
        cmp #$03
        beq set_level3

set_level2:
        lda #<pattern2
        sta pattern_ptr
        lda #>pattern2
        sta pattern_ptr+1
        lda #<timing2
        sta timing_ptr
        lda #>timing2
        sta timing_ptr+1
        jsr update_hud
        ; Wait for key, then continue
        jsr wait_for_key
        jsr clear_message
        lda #STATE_PLAY
        sta game_state
        jmp main_loop

set_level3:
        lda #<pattern3
        sta pattern_ptr
        lda #>pattern3
        sta pattern_ptr+1
        lda #<timing3
        sta timing_ptr
        lda #>timing3
        sta timing_ptr+1
        jsr update_hud
        ; Wait for key, then continue
        jsr wait_for_key
        jsr clear_message
        lda #STATE_PLAY
        sta game_state
        jmp main_loop

; ============================================================================
; VICTORY
; ============================================================================
victory:
        jsr show_victory
freeze: jmp freeze              ; Freeze at end

; ============================================================================
; GET CURRENT NOTE
; ============================================================================
get_current_note:
        ldy note_index
        lda (pattern_ptr),y
        rts

; ============================================================================
; PLAY NOTE - Play current note from pattern
; ============================================================================
play_note:
        jsr get_current_note
        tay                     ; Y = note index

        lda freq_lo,y
        sta $d400               ; Set frequency
        lda freq_hi,y
        sta $d401

        lda #$21                ; Sawtooth + gate ON
        sta $d404
        rts

; ============================================================================
; CHECK NOTE TIMEOUT
; ============================================================================
check_note_timeout:
        lda frame_counter
        sec
        sbc note_start          ; A = frames since note started
        sta temp                ; Save elapsed frames
        ldy note_index
        lda (timing_ptr),y      ; Load timing value
        cmp temp                ; Compare with elapsed
        ; If timing <= elapsed, carry is set (timeout)
        ; If timing > elapsed, carry is clear (still time)
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
; WAIT FOR KEY - Wait for spacebar press (for level transitions)
; ============================================================================
wait_for_key:
wfk_loop:
        jsr wait_frame
        jsr scan_spacebar
        bcc wfk_loop
        ; Key down, now wait for release
wfk_release:
        jsr wait_frame
        jsr scan_spacebar
        bcs wfk_release
        rts

; ============================================================================
; SCORING ROUTINES
; ============================================================================
add_score_100:
        clc
        lda score
        adc #$64                ; 100 decimal = $64
        sta score
        lda score+1
        adc #$00
        sta score+1
        jsr update_hud
        rts

add_score_50:
        clc
        lda score
        adc #$32                ; 50 decimal = $32
        sta score
        lda score+1
        adc #$00
        sta score+1
        jsr update_hud
        rts

; ============================================================================
; HUD ROUTINES
; ============================================================================
draw_hud:
        ; Display static HUD text at top of screen
        ldx #$00
dh_loop:
        lda hud_text,x
        beq dh_done
        sta SCREEN,x
        lda #$0e                ; Light blue
        sta COLOR,x
        inx
        jmp dh_loop
dh_done:
        jsr update_hud
        rts

update_hud:
        ; Update score display (4 hex digits)
        lda score+1
        jsr hex_to_screen
        stx SCREEN+7
        sty SCREEN+8

        lda score
        jsr hex_to_screen
        stx SCREEN+9
        sty SCREEN+10

        ; Update lives display
        lda lives
        clc
        adc #$30                ; Convert to PETSCII digit
        sta SCREEN+19

        ; Update level display
        lda level
        clc
        adc #$30
        sta SCREEN+28
        rts

hex_to_screen:
        ; Convert A register to two PETSCII digits in X,Y
        pha
        lsr
        lsr
        lsr
        lsr
        clc
        adc #$30
        tax
        pla
        and #$0f
        clc
        adc #$30
        tay
        rts

; ============================================================================
; MESSAGE DISPLAY ROUTINES
; ============================================================================
show_perfect:
        ldx #$00
sp_loop:
        lda msg_perfect,x
        beq sp_done
        sta SCREEN+40*12+15,x
        lda #$07                ; Yellow
        sta COLOR+40*12+15,x
        inx
        jmp sp_loop
sp_done:
        lda #60                 ; Show for 1 second
        sta result_timer
        rts

show_hit:
        ldx #$00
sh_loop:
        lda msg_hit,x
        beq sh_done
        sta SCREEN+40*12+17,x
        lda #$05                ; Green
        sta COLOR+40*12+17,x
        inx
        jmp sh_loop
sh_done:
        lda #60                 ; Show for 1 second
        sta result_timer
        rts

show_miss:
        ldx #$00
sm_loop:
        lda msg_miss,x
        beq sm_done
        sta SCREEN+40*12+17,x
        lda #$02                ; Red
        sta COLOR+40*12+17,x
        inx
        jmp sm_loop
sm_done:
        lda #60                 ; Show for 1 second
        sta result_timer
        rts

show_level_clear:
        ldx #$00
slc_loop:
        lda msg_level_clear,x
        beq slc_done
        sta SCREEN+40*12+12,x
        lda #$0e                ; Light blue
        sta COLOR+40*12+12,x
        inx
        jmp slc_loop
slc_done:
        rts

show_game_over:
        ldx #$00
sgo_loop:
        lda msg_game_over,x
        beq sgo_done
        sta SCREEN+40*12+15,x
        lda #$02                ; Red
        sta COLOR+40*12+15,x
        inx
        jmp sgo_loop
sgo_done:
        rts

show_victory:
        ldx #$00
sv_loop:
        lda msg_victory,x
        beq sv_done
        sta SCREEN+40*12+10,x
        lda #$07                ; Yellow
        sta COLOR+40*12+10,x
        inx
        jmp sv_loop
sv_done:
        rts

show_instructions:
        ldx #$00
si_loop:
        lda msg_inst,x
        beq si_done
        sta SCREEN+40*2+7,x
        lda #$0e                ; Light blue
        sta COLOR+40*2+7,x
        inx
        jmp si_loop
si_done:
        rts

clear_message:
        ldx #$14                ; Clear 20 characters
cm_loop:
        lda #$20                ; Space
        sta SCREEN+40*12+10,x
        dex
        bpl cm_loop
        rts

; ============================================================================
; MESSAGES (PETSCII)
; ============================================================================
hud_text:       !text "score:     lives:   level:  ",0
msg_perfect:    !text "perfect!",0
msg_hit:        !text "hit!",0
msg_miss:       !text "miss",0
msg_level_clear: !text "level complete!",0
msg_game_over:  !text "game over",0
msg_victory:    !text "all levels complete!",0
msg_inst:       !text "press space on the beat!",0

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
