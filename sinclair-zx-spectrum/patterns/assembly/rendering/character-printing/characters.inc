; 48K Spectrum ROM visible at0..$3fff; caller provides stack and display ownership.
; print_char: A=ASCII32..127, B=row0..23, C=column0..31. Preserves AF/BC/DE/HL.
; Invalid character or position: no write. Uses the standard fixed font location.
; print_string: HL=null-terminated printable ASCII; B/C=start cell.
; Stops at the right edge without wrapping. Preserves BC/DE/HL, changes AF.
; Bitmap only: set attributes separately. No ROM routine call or IRQ requirement.
; =============================================================================
; CHARACTER PRINTING - ZX SPECTRUM
; Print characters using ROM character set
; Taught: Game 1 (Ink War), Unit 4
; =============================================================================

DISPLAY_FILE equ    $4000       ; Screen memory
CHAR_SET    equ     $3C00       ; ROM character set (chars 0-127)

; Print single character
; Input: A = ASCII character (32-127)
;        B = row (0-23), C = column (0-31)
print_char:
    push    bc
    push    de
    push    hl
    push    af
    ld a,b
    cp 24
    jr nc,print_char_done
    ld a,c
    cp 32
    jr nc,print_char_done
    pop af
    push af
    cp 32
    jr c,print_char_done
    cp 128
    jr nc,print_char_done

    ; Calculate character data address: CHAR_SET + char * 8
    ld      l, a
    ld      h, 0
    add     hl, hl              ; * 2
    add     hl, hl              ; * 4
    add     hl, hl              ; * 8
    ld      de, CHAR_SET
    add     hl, de              ; HL = character data source

    push    hl                  ; Save source address

    ; Calculate display file address
    ; The Spectrum's display is organised in thirds with interleaved lines
    ld      a, b                ; A = row (0-23)
    and     %00011000           ; Which third (0, 8, or 16)?
    add     a, $40              ; Add display file base ($4000 high byte)
    ld      d, a                ; D = high byte

    ld      a, b                ; A = row
    and     %00000111           ; Line within character row (0-7)
    rrca
    rrca
    rrca                        ; Move to bits 5-7
    add     a, c                ; Add column
    ld      e, a                ; E = low byte, DE = screen address

    pop     hl                  ; HL = character data

    ; Copy 8 bytes (8 pixel rows)
    ld      b, 8
character_scan:
    ld      a, (hl)             ; Get character row
    ld      (de), a             ; Write to screen
    inc     hl                  ; Next character row
    inc     d                   ; Next screen line (add 256)
    djnz    character_scan

print_char_done:
    pop     af
    pop     hl
    pop     de
    pop     bc
    ret

; Print null-terminated string
; Input: HL = string address, B = row, C = column
print_string:
    push    bc
    push    hl

character_string_next:
    ld a,b
    cp 24
    jr nc,character_string_done
    ld a,c
    cp 32
    jr nc,character_string_done
    ld      a, (hl)
    or      a                   ; Check for null terminator
    jr      z, character_string_done

    call    print_char
    inc     hl
    inc     c                   ; Next column
    jr      character_string_next

character_string_done:
    pop     hl
    pop     bc
    ret

; Example usage:
;   ld      hl, message
;   ld      b, 10               ; Row 10
;   ld      c, 5                ; Column 5
;   call    print_string
;
; message:
;   defm    "HELLO WORLD"
;   defb    0
