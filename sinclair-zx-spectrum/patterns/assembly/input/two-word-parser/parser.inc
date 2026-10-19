; Pasmo Z80. Caller: initialise a valid stack, then CALL parser_init once.
; parse_command: HL=readable input, BC=exact byte length (0..63).
; Input may contain ASCII letters/digits/spaces; it is never changed or terminated.
; HL+BC must fit the address space. A=status; verb_id/noun_id=0 on EVERY error.
; AF/BC/DE/HL change; IX/IY survive. All state below must be writable.
; Non-reentrant: interrupt code must preserve registers and not call this parser.
; Supply validated verb_vocab/noun_vocab tables (generate_vocabulary.py).
; Records: length, ID, noun-policy, uppercase bytes; length0 ends a table.
; Init is a lifetime/reset action, not a per-command action. No ROM/IRQ/I/O required.
parser_begin:
parser_init:
    xor a
    ld (verb_id),a
    ld (noun_id),a
    ld (parse_status),a
    inc a
    ld (parser_ready),a
    ret
parse_command:
    ld (input_ptr),hl
    ld a,c
    ld (input_length),a
    xor a
    ld (verb_id),a
    ld (noun_id),a
    ld (parse_status),a
    ld (word1_length),a
    ld (word2_length),a
    ld de,0
    ld (word1_ptr),de
    ld (word2_ptr),de
    ld a,(parser_ready)
    cp 1
    jp nz,parse_not_ready
    ld a,b
    or a
    jp nz,parse_long
    ld a,c
    cp 64
    jp nc,parse_long
    or a
    jp z,parse_empty
    ld b,c
parse_validate:
    ld a,(hl)
    call upper_ascii
    cp ' '
    jr z,parse_valid_byte
    cp '0'
    jp c,parse_bad_char
    cp '9'+1
    jr c,parse_valid_byte
    cp 'A'
    jp c,parse_bad_char
    cp 'Z'+1
    jp nc,parse_bad_char
parse_valid_byte:
    inc hl
    djnz parse_validate
    ld hl,(input_ptr)
    ld a,(input_length)
    ld b,a
    ld c,0
parse_next:
    ld a,b
    or a
    jr z,parse_words_ready
    ld a,(hl)
    cp ' '
    jr nz,parse_word_start
    inc hl
    dec b
    jr parse_next
parse_word_start:
    inc c
    ld a,c
    cp 3
    jp nc,parse_extra
    cp 1
    jr nz,parse_second
    ld (word1_ptr),hl
    ld de,word1_length
    jr parse_word_byte
parse_second:
    ld (word2_ptr),hl
    ld de,word2_length
parse_word_byte:
    ld a,b
    or a
    jr z,parse_words_ready
    ld a,(hl)
    cp ' '
    jr z,parse_next
    ld a,(de)
    inc a
    ld (de),a
    inc hl
    dec b
    jr parse_word_byte
parse_words_ready:
    ld a,(word1_length)
    or a
    jp z,parse_empty
    ld b,a
    ld hl,(word1_ptr)
    ld de,verb_vocab
    call lookup_word
    or a
    jp z,parse_unknown_verb
    ld (candidate_verb),a
    ld a,(word2_length)
    or a
    jr nz,parse_has_noun
    ld a,(lookup_policy)
    cp 1
    jp z,parse_missing
    jr parse_success
parse_has_noun:
    ld a,(lookup_policy)
    or a
    jp z,parse_unexpected
    ld a,(word2_length)
    ld b,a
    ld hl,(word2_ptr)
    ld de,noun_vocab
    call lookup_word
    or a
    jp z,parse_unknown_noun
    ld (noun_id),a
parse_success:
    ld a,(candidate_verb)
    ld (verb_id),a
    xor a
    ret
parse_empty: ld a,1
    jr parser_fail
parse_long: ld a,2
    jr parser_fail
parse_bad_char: ld a,3
    jr parser_fail
parse_extra: ld a,4
    jr parser_fail
parse_unknown_verb: ld a,5
    jr parser_fail
parse_unknown_noun: ld a,6
    jr parser_fail
parse_missing: ld a,7
    jr parser_fail
parse_unexpected: ld a,8
    jr parser_fail
parse_not_ready: ld a,9
parser_fail:
    ld (parse_status),a
    ret

; Internal lookup. B=token length, HL=token, DE=validated table.
; Return A=ID or0, lookup_policy=matching record policy when ID is nonzero.
lookup_word:
    ld a,(de)
    or a
    ret z
    ld c,a
    inc de
    ld a,(de)
    ld (lookup_id),a
    inc de
    ld a,(de)
    ld (lookup_policy),a
    inc de
    ld a,c
    cp b
    jr nz,lookup_skip
    push hl
    push bc
    push de
lookup_compare:
    ld a,(hl)
    call upper_ascii
    ld c,a
    ld a,(de)
    cp c
    jr nz,lookup_miss
    inc hl
    inc de
    djnz lookup_compare
    pop de
    pop bc
    pop hl
    ld a,(lookup_id)
    ret
lookup_miss:
    pop de
    pop bc
    pop hl
lookup_skip:
    push hl
    ld l,c
    ld h,0
    add hl,de
    ex de,hl
    pop hl
    jr lookup_word
upper_ascii:
    cp 'a'
    ret c
    cp 'z'+1
    ret nc
    sub 32
    ret
parser_code_end:
parser_ready: defb 0
parse_status: defb 0
verb_id: defb 0
noun_id: defb 0
input_ptr: defw 0
input_length: defb 0
word1_ptr: defw 0
word1_length: defb 0
word2_ptr: defw 0
word2_length: defb 0
candidate_verb: defb 0
lookup_id: defb 0
lookup_policy: defb 0
parser_end:
