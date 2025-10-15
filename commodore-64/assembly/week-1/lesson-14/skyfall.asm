; SKYFALL - Lesson 14
; Multi-digit score display

* = $0801

; BASIC stub: SYS 2061
!byte $0c,$08,$0a,$00,$9e
!byte $32,$30,$36,$31          ; "2061" in ASCII
!byte $00,$00,$00

* = $080d

; ===================================
; Constants
; ===================================
SCREEN_RAM = $0400
COLOR_RAM = $d800
VIC_BORDER = $d020
VIC_BACKGROUND = $d021
CIA1_PORT_A = $dc01
CIA1_PORT_B = $dc00
VIC_RASTER = $d012

SID_V1_FREQ_LO = $d400
SID_V1_FREQ_HI = $d401
SID_V1_CONTROL = $d404
SID_V1_AD = $d405
SID_V1_SR = $d406
SID_V3_FREQ_LO = $d40e
SID_V3_FREQ_HI = $d40f
SID_V3_CONTROL = $d412
SID_V3_OSC = $d41b
SID_VOLUME = $d418

BLACK = $00
WHITE = $01
YELLOW = $07
DARK_GREY = $0b

PLAYER_CHAR = $1e
PLAYER_COLOR = WHITE
PLAYER_ROW = 23
PLAYER_START_COL = 20

OBJECT_CHAR = $2a
OBJECT_COLOR = YELLOW

MAX_OBJECTS = 3
SPAWN_DELAY = 60

; Variables
PLAYER_COL = $02
MOVE_COUNTER = $03
FALL_COUNTER = $07
SCORE = $08
MISSES = $09
SPAWN_COUNTER = $0a
SOUND_TIMER = $0b

; Object arrays
OBJ_COL = $10                  ; 3 bytes
OBJ_ROW = $13                  ; 3 bytes
OBJ_ACTIVE = $16               ; 3 bytes

; ===================================
; Main Program
; ===================================
main:
    jsr init_screen
    jsr init_random
    jsr init_sound

    lda #PLAYER_START_COL
    sta PLAYER_COL

    lda #3
    sta MOVE_COUNTER

    lda #5
    sta FALL_COUNTER

    lda #SPAWN_DELAY
    sta SPAWN_COUNTER

    lda #$00
    sta SCORE
    sta MISSES
    sta SOUND_TIMER

    ; Clear all objects
    ldx #$00
clear_objects:
    lda #$00
    sta OBJ_ACTIVE,x
    inx
    cpx #MAX_OBJECTS
    bne clear_objects

    jsr draw_player
    jsr spawn_object
    jsr display_score
    jsr display_misses

game_loop:
    jsr wait_for_raster

    ; Update sound timer
    lda SOUND_TIMER
    beq no_sound_playing
    dec SOUND_TIMER
    bne no_sound_playing
    jsr stop_sound
no_sound_playing:

    ; Player movement
    dec MOVE_COUNTER
    bne skip_player_movement
    lda #3
    sta MOVE_COUNTER
    jsr check_keys
skip_player_movement:

    ; Object falling
    dec FALL_COUNTER
    bne skip_object_fall
    lda #5
    sta FALL_COUNTER
    jsr update_all_objects
    jsr draw_player           ; Redraw player (in case object erased it)
skip_object_fall:

    ; Spawn new objects
    dec SPAWN_COUNTER
    bne skip_spawn
    lda #SPAWN_DELAY
    sta SPAWN_COUNTER
    jsr spawn_object
skip_spawn:

    jmp game_loop

; ===================================
; Subroutines
; ===================================

wait_for_raster:
    lda VIC_RASTER
    cmp #250
    bne wait_for_raster
    rts

init_screen:
    jsr wait_for_raster
    lda #BLACK
    sta VIC_BACKGROUND
    lda #DARK_GREY
    sta VIC_BORDER
    jsr clear_screen
    rts

init_random:
    lda #$ff
    sta SID_V3_FREQ_LO
    sta SID_V3_FREQ_HI
    lda #$80
    sta SID_V3_CONTROL
    rts

init_sound:
    lda #$0f
    sta SID_VOLUME
    rts

play_catch_sound:
    lda #$3e
    sta SID_V1_FREQ_LO
    lda #$11
    sta SID_V1_FREQ_HI
    lda #$09
    sta SID_V1_AD
    lda #$00
    sta SID_V1_SR
    lda #$11
    sta SID_V1_CONTROL
    lda #10
    sta SOUND_TIMER
    rts

play_miss_sound:
    lda #$f7
    sta SID_V1_FREQ_LO
    lda #$04
    sta SID_V1_FREQ_HI
    lda #$00
    sta SID_V1_AD
    lda #$a8
    sta SID_V1_SR
    lda #$21
    sta SID_V1_CONTROL
    lda #20
    sta SOUND_TIMER
    rts

stop_sound:
    lda SID_V1_CONTROL
    and #$fe
    sta SID_V1_CONTROL
    rts

divide_by_10:
    ; Input: A = number to divide
    ; Output: X = tens, A = ones
    ; Carry must be set before calling
    ldx #$00
divide_loop:
    cmp #10
    bcc done_divide
    sbc #10
    inx
    jmp divide_loop
done_divide:
    rts

get_random:
    lda SID_V3_OSC
    rts

get_random_column:
try_again:
    jsr get_random
    and #%00111111
    cmp #40
    bcs try_again
    rts

clear_screen:
    lda #$20
    ldx #$00
clear_screen_loop:
    sta SCREEN_RAM,x
    sta SCREEN_RAM + $100,x
    sta SCREEN_RAM + $200,x
    sta SCREEN_RAM + $300,x
    inx
    bne clear_screen_loop

    lda #WHITE
    ldx #$00
clear_color_loop:
    sta COLOR_RAM,x
    sta COLOR_RAM + $100,x
    sta COLOR_RAM + $200,x
    sta COLOR_RAM + $300,x
    inx
    bne clear_color_loop
    rts

check_keys:
    ; Check D key (column 2, row 2)
    lda #%11111011
    sta CIA1_PORT_B
    lda CIA1_PORT_A
    and #%00000100
    beq move_right

    ; Check A key (column 1, row 2)
    lda #%11111101
    sta CIA1_PORT_B
    lda CIA1_PORT_A
    and #%00000100
    beq move_left

    rts

move_left:
    lda PLAYER_COL
    beq skip_left
    jsr erase_player
    dec PLAYER_COL
    jsr draw_player
skip_left:
    rts

move_right:
    lda PLAYER_COL
    cmp #39
    beq skip_right
    jsr erase_player
    inc PLAYER_COL
    jsr draw_player
skip_right:
    rts

erase_player:
    ldx PLAYER_COL
    lda #$20
    sta SCREEN_RAM + (PLAYER_ROW * 40),x
    rts

draw_player:
    ldx PLAYER_COL
    lda #PLAYER_CHAR
    sta SCREEN_RAM + (PLAYER_ROW * 40),x
    lda #PLAYER_COLOR
    sta COLOR_RAM + (PLAYER_ROW * 40),x
    rts

spawn_object:
    ldx #$00
find_slot:
    lda OBJ_ACTIVE,x
    beq found_slot
    inx
    cpx #MAX_OBJECTS
    bne find_slot
    rts
found_slot:
    lda #$01
    sta OBJ_ACTIVE,x
    lda #$00
    sta OBJ_ROW,x
    stx $fd
    jsr get_random_column
    ldx $fd
    sta OBJ_COL,x
    jsr draw_object
    rts

update_all_objects:
    ldx #$00
update_loop:
    stx $fe
    lda OBJ_ACTIVE,x
    beq skip_this_object
    jsr erase_object
    ldx $fe
    inc OBJ_ROW,x
    lda OBJ_ROW,x
    cmp #24
    bne still_falling_check
    ldx $fe
    lda #$00
    sta OBJ_ACTIVE,x
    inc MISSES
    jsr display_misses
    jsr play_miss_sound
    jsr spawn_object
    jmp next_object
still_falling_check:
    ldx $fe
    jsr draw_object
skip_this_object:
next_object:
    ldx $fe
    inx
    cpx #MAX_OBJECTS
    bne update_loop
    rts

check_all_collisions:
    ldx #$00
collision_loop:
    stx $fe
    lda OBJ_ACTIVE,x
    beq skip_collision
    lda OBJ_ROW,x
    cmp #PLAYER_ROW
    bne skip_collision
    ldx $fe
    lda OBJ_COL,x
    cmp PLAYER_COL
    bne skip_collision
    ldx $fe
    jsr handle_catch
skip_collision:
    ldx $fe
    inx
    cpx #MAX_OBJECTS
    bne collision_loop
    rts

handle_catch:
    jsr erase_object
    lda #$00
    sta OBJ_ACTIVE,x
    inc SCORE
    jsr display_score
    jsr play_catch_sound
    jsr spawn_object
    rts

; Row offset lookup table (low bytes)
row_offset_lo:
    !byte <(0*40), <(1*40), <(2*40), <(3*40), <(4*40)
    !byte <(5*40), <(6*40), <(7*40), <(8*40), <(9*40)
    !byte <(10*40), <(11*40), <(12*40), <(13*40), <(14*40)
    !byte <(15*40), <(16*40), <(17*40), <(18*40), <(19*40)
    !byte <(20*40), <(21*40), <(22*40), <(23*40), <(24*40)

; Row offset lookup table (high bytes)
row_offset_hi:
    !byte >(0*40), >(1*40), >(2*40), >(3*40), >(4*40)
    !byte >(5*40), >(6*40), >(7*40), >(8*40), >(9*40)
    !byte >(10*40), >(11*40), >(12*40), >(13*40), >(14*40)
    !byte >(15*40), >(16*40), >(17*40), >(18*40), >(19*40)
    !byte >(20*40), >(21*40), >(22*40), >(23*40), >(24*40)

draw_object:
    ; Save current X
    stx $fd

    ; Get row offset from table
    ldy OBJ_ROW,x
    lda row_offset_lo,y
    sta $fb
    lda row_offset_hi,y
    sta $fc

    ; Add column
    ldx $fd
    lda $fb
    clc
    adc OBJ_COL,x
    sta $fb
    bcc +
    inc $fc
+
    ; Add SCREEN_RAM base
    lda $fb
    clc
    adc #<SCREEN_RAM
    sta $fb
    lda $fc
    adc #>SCREEN_RAM
    sta $fc

    ; Draw character
    ldy #0
    lda #OBJECT_CHAR
    sta ($fb),y

    ; Calculate COLOR_RAM address
    lda $fb
    clc
    adc #<(COLOR_RAM-SCREEN_RAM)
    sta $fb
    lda $fc
    adc #>(COLOR_RAM-SCREEN_RAM)
    sta $fc

    ; Draw color
    lda #OBJECT_COLOR
    sta ($fb),y

    ldx $fd
    rts

erase_object:
    ; Save current X
    stx $fd

    ; Get row offset from table
    ldy OBJ_ROW,x
    lda row_offset_lo,y
    sta $fb
    lda row_offset_hi,y
    sta $fc

    ; Add column
    ldx $fd
    lda $fb
    clc
    adc OBJ_COL,x
    sta $fb
    bcc +
    inc $fc
+
    ; Add SCREEN_RAM base
    lda $fb
    clc
    adc #<SCREEN_RAM
    sta $fb
    lda $fc
    adc #>SCREEN_RAM
    sta $fc

    ; Erase with space
    ldy #0
    lda #$20
    sta ($fb),y

    ldx $fd
    rts

display_score:
    ; Clear score area
    lda #$20
    sta SCREEN_RAM
    sta SCREEN_RAM + 1

    ; Convert and display
    lda SCORE
    sec
    jsr divide_by_10

    sta $fb                    ; Save ones

    txa                        ; Get tens
    beq skip_tens              ; If zero, skip tens digit

    clc
    adc #$30
    sta SCREEN_RAM

    lda $fb
    clc
    adc #$30
    sta SCREEN_RAM + 1

    lda #WHITE
    sta COLOR_RAM
    sta COLOR_RAM + 1
    rts

skip_tens:
    lda $fb
    clc
    adc #$30
    sta SCREEN_RAM
    lda #WHITE
    sta COLOR_RAM
    rts

display_misses:
    ; Clear misses area
    lda #$20
    sta SCREEN_RAM + 5
    sta SCREEN_RAM + 6

    ; Convert and display
    lda MISSES
    sec
    jsr divide_by_10

    sta $fb

    txa
    beq skip_miss_tens

    clc
    adc #$30
    sta SCREEN_RAM + 5

    lda $fb
    clc
    adc #$30
    sta SCREEN_RAM + 6

    lda #WHITE
    sta COLOR_RAM + 5
    sta COLOR_RAM + 6
    rts

skip_miss_tens:
    lda $fb
    clc
    adc #$30
    sta SCREEN_RAM + 5
    lda #WHITE
    sta COLOR_RAM + 5
    rts
