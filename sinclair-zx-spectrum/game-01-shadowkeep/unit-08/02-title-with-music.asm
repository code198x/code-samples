;
; Shadowkeep Unit 8, Stage 2 — Title with Music
;
; Stage 1's title card was silent. Real 1980s title screens have music
; — Sabre Wulf, Manic Miner, Stormlord all play their theme under the
; presented title until the player presses a key. This stage adds the
; music: Unit 7's beeper driver, called after the title is drawn,
; looping forever via the $FF marker.
;
; Still no input handling yet — the music plays indefinitely; reset the
; machine to escape. Stage 3 adds the SPACE key to break out.
;

            org     32768

TITLE_ROW   equ     6
TITLE_COL   equ     11
TITLE_LEN   equ     10
TITLE_ATTR  equ     $07

ROM_FONT    equ     $3D00
SPEAKER     equ     $10

start:
            im      1
            ei
            xor     a
            out     ($FE), a

            call    clear_screen
            call    draw_title

            ; Play the title theme forever. play_theme loops internally
            ; via the $FF marker; it never returns under its own steam.
            jp      play_theme

; ============================================================================
; Screen rendering (Stage 1 verbatim)
; ============================================================================

clear_screen:
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), 0
            ld      bc, 767
            ldir
            ret

draw_title:
            ld      hl, $5800 + TITLE_ROW * 32 + TITLE_COL
            ld      b, TITLE_LEN
.fill_attr:
            ld      (hl), TITLE_ATTR
            inc     hl
            djnz    .fill_attr

            ld      hl, title_text
            ld      d, TITLE_ROW
            ld      e, TITLE_COL
.next_char:
            ld      a, (hl)
            or      a
            ret     z
            push    hl
            call    draw_char
            pop     hl
            inc     hl
            inc     e
            jr      .next_char

draw_char:
            push    de
            sub     32
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      bc, ROM_FONT
            add     hl, bc

            push    hl
            ld      a, d
            and     $18
            or      $40
            ld      h, a
            ld      a, d
            and     $07
            rrca
            rrca
            rrca
            or      e
            ld      l, a
            ex      de, hl
            pop     hl

            ld      b, 8
.line:
            ld      a, (hl)
            ld      (de), a
            inc     hl
            inc     d
            djnz    .line

            pop     de
            ret

; ============================================================================
; Beeper driver — verbatim from Unit 7 Stage 4. Plays melody table.
; ============================================================================

play_theme:
            ld      hl, melody
.next_note:
            ld      a, (hl)
            cp      $FF
            jr      z, play_theme       ; loop forever
            inc     hl
            ld      c, (hl)
            inc     hl

            cp      $00
            jr      z, .play_rest

            push    hl
            ld      d, 0
            ld      e, c
            sla     e
            rl      d
            sla     e
            rl      d
            call    play_note
            pop     hl
            jr      .next_note

.play_rest:
            push    hl
            xor     a
            out     ($FE), a
            ld      b, c
.rest_outer:
            ld      a, 150
.rest_inner:
            dec     a
            jr      nz, .rest_inner
            djnz    .rest_outer
            pop     hl
            jr      .next_note

play_note:
            ld      h, a
.cycle:
            ld      a, SPEAKER
            out     ($FE), a
            ld      b, h
.h_up:      djnz    .h_up
            xor     a
            out     ($FE), a
            ld      b, h
.h_dn:      djnz    .h_dn
            dec     de
            ld      a, d
            or      e
            jr      nz, .cycle
            ret

; ----------------------------------------------------------------------------
; Title theme — D minor, twelve notes plus loop marker. See Unit 7 Stage 4
; for the composition rationale.
; ----------------------------------------------------------------------------

melody:
            defb    227, 64             ; D5 quarter
            defb    191, 64             ; F5 quarter
            defb    151, 64             ; A5 quarter
            defb    112, 128            ; D6 half
            defb    126, 64             ; C6 quarter
            defb    151, 64             ; A5 quarter
            defb    191, 64             ; F5 quarter
            defb    202, 64             ; E5 quarter
            defb    227, 128            ; D5 half
            defb    $00, 32             ; rest
            defb    227, 255            ; D5 long
            defb    $FF                 ; loop marker

title_text:
            defm    "SHADOWKEEP", 0

            end     start
