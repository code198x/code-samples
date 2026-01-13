; Copy Character ROM to RAM
; The C64's character ROM is read-only. To modify characters, we copy
; the ROM to RAM and point the VIC-II to our RAM copy.

CHARSET     = $3000             ; Our custom charset location

copy_charset:
            ; Disable interrupts - ROM switching must be atomic
            sei

            ; The C64's processor port at $01 controls memory mapping
            ; Bit 2 (CHAREN) = 0 makes character ROM visible at $D000
            lda $01
            pha                 ; Save current state
            and #$FB            ; Clear bit 2
            sta $01             ; Character ROM now at $D000-$DFFF

            ; Copy all 256 characters (256 * 8 = 2048 bytes)
            ldx #0
copy_loop:
            lda $D000,x         ; Copy 256 bytes at a time
            sta CHARSET,x       ; To our RAM location
            lda $D100,x
            sta CHARSET+$100,x
            ; ... (continues for all 8 pages)
            inx
            bne copy_loop

            ; Restore processor port
            pla
            sta $01

            ; Re-enable interrupts
            cli
            rts
