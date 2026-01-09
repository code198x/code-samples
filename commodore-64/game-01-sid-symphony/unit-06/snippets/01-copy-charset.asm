; Copy ROM character set to RAM for modification
; Character ROM is at $D000 but hidden under I/O
; We temporarily disable I/O to access it

CHAR_ROM        = $d000         ; ROM character set location
CHAR_RAM        = $3000         ; Where we'll put our copy

setup_charset:
                sei                 ; Disable interrupts (critical!)
                lda $01             ; Get processor port
                pha                 ; Save current value
                and #%11111011      ; Clear bit 2 (CHAREN)
                sta $01             ; ROM now visible at $D000

                ; Copy all 2KB (256 characters * 8 bytes each)
                ldx #0
-               lda CHAR_ROM,x
                sta CHAR_RAM,x
                lda CHAR_ROM+$100,x
                sta CHAR_RAM+$100,x
                lda CHAR_ROM+$200,x
                sta CHAR_RAM+$200,x
                lda CHAR_ROM+$300,x
                sta CHAR_RAM+$300,x
                lda CHAR_ROM+$400,x
                sta CHAR_RAM+$400,x
                lda CHAR_ROM+$500,x
                sta CHAR_RAM+$500,x
                lda CHAR_ROM+$600,x
                sta CHAR_RAM+$600,x
                lda CHAR_ROM+$700,x
                sta CHAR_RAM+$700,x
                inx
                bne -

                pla                 ; Restore processor port
                sta $01             ; I/O visible again
                cli                 ; Re-enable interrupts

                rts
