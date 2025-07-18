# Commodore 64 Keyboard Matrix Testing Guide

## Problem
The Q, O, and P keys in the current implementation don't work correctly. We need to find their actual matrix positions empirically since documentation sources may be incorrect.

## Known Working Reference
- **A Key**: Column 1 ($FD to $DC00), Row 2 (bit 2 of $DC01) - **CONFIRMED WORKING**

## Testing Tools Provided

### 1. Simple Real-Time Scanner (`simple-key-test.asm`)
**Recommended for quick testing**

**How to use:**
1. Build and run: `make test-simple`
2. The program continuously scans all matrix positions
3. Press Q, O, or P - their positions will be displayed immediately
4. Results show:
   - **COL**: Column number (0-7)
   - **ROW**: Row number (0-7)
   - **COL MASK**: Hex value to write to $DC00
   - **ROW MASK**: Hex bit to check in $DC01
   - **RAW DATA**: Raw value read from $DC01

### 2. Systematic Step-by-Step Tester (`keyboard-matrix-test.asm`)
**For detailed verification**

**How to use:**
1. Build and run: `make test-matrix`
2. Follow on-screen instructions for each key
3. Hold down the key being tested and press SPACE
4. Program will systematically test all 64 positions
5. Reports exact position when found

## C64 Keyboard Matrix Reference

### How the Matrix Works
- **$DC00 (CIA1 Port A)**: Column selection (write)
  - Clear bit to select column (active low)
  - $FE = Column 0, $FD = Column 1, $FB = Column 2, etc.
- **$DC01 (CIA1 Port B)**: Row reading (read)
  - Clear bit indicates key pressed (active low)
  - Bit 0 = Row 0, Bit 1 = Row 1, Bit 2 = Row 2, etc.

### Column Masks (write to $DC00)
```
Column 0: $FE (%11111110)
Column 1: $FD (%11111101) - A key is here
Column 2: $FB (%11111011)
Column 3: $F7 (%11110111)
Column 4: $EF (%11101111)
Column 5: $DF (%11011111)
Column 6: $BF (%10111111)
Column 7: $7F (%01111111)
```

### Row Masks (check in $DC01)
```
Row 0: Bit 0 (%00000001)
Row 1: Bit 1 (%00000010)
Row 2: Bit 2 (%00000100) - A key is here
Row 3: Bit 3 (%00001000)
Row 4: Bit 4 (%00010000)
Row 5: Bit 5 (%00100000)
Row 6: Bit 6 (%01000000)
Row 7: Bit 7 (%10000000)
```

## Expected Results to Record

After running the tests, record the findings:

### Q Key
- Column: ___
- Row: ___
- Column Mask: $___
- Row Mask: $___

### O Key  
- Column: ___
- Row: ___
- Column Mask: $___
- Row Mask: $___

### P Key
- Column: ___
- Row: ___
- Column Mask: $___
- Row Mask: $___

## Implementation Code Template

Once you find the correct positions, use this template:

```asm
check_keyboard_input:
        ; Check Q key (Up) - Column X, Row Y
        lda #$XX               ; Column mask from test
        sta $dc00
        lda $dc01
        and #$XX               ; Row mask from test
        bne not_q
        lda joystick_state
        and #%11111110         ; Clear joystick up bit
        sta joystick_state
not_q:
        
        ; Check O key (Left) - Column X, Row Y
        lda #$XX               ; Column mask from test
        sta $dc00
        lda $dc01
        and #$XX               ; Row mask from test
        bne not_o
        lda joystick_state
        and #%11111011         ; Clear joystick left bit
        sta joystick_state
not_o:
        
        ; Check P key (Right) - Column X, Row Y
        lda #$XX               ; Column mask from test
        sta $dc00
        lda $dc01
        and #$XX               ; Row mask from test
        bne not_p
        lda joystick_state
        and #%11110111         ; Clear joystick right bit
        sta joystick_state
not_p:
        
        ; Restore CIA1 Port A
        lda #$ff
        sta $dc00
        
        rts
```

## Troubleshooting

### If Keys Are Not Detected
1. **Check physical connection**: Ensure keyboard is properly connected
2. **Try different keys**: Test with known working keys first
3. **Check CIA configuration**: Ensure CIA1 is properly configured
4. **Verify power**: Low power can cause matrix scanning issues

### If Multiple Positions Are Detected
1. **Key ghosting**: Some key combinations can cause false positives
2. **Release all keys**: Make sure only the target key is pressed
3. **Check for stuck keys**: Ensure no other keys are stuck down

### If Results Are Inconsistent
1. **Timing issues**: Key bounce or scan timing problems
2. **Try multiple times**: Run the test several times to confirm
3. **Check for interference**: Other programs or interrupts might interfere

## Common C64 Keyboard Matrix Positions

Here are some commonly documented positions (may not be accurate):

| Key | Column | Row | Col Mask | Row Mask |
|-----|--------|-----|----------|----------|
| Q   | 7      | 6   | $7F      | $40      |
| O   | 6      | 2   | $BF      | $04      |
| P   | 5      | 1   | $DF      | $02      |
| A   | 1      | 2   | $FD      | $04      | ✓ Confirmed

**Note**: These are from documentation and may be incorrect. Use the test programs to verify actual positions.

## Quick Start Instructions

### Method 1: Real-Time Scanner (Recommended)
```bash
make test-simple
```
1. The program will show a real-time display
2. Press Q, O, or P - their positions appear immediately
3. Record the Column, Row, and mask values shown
4. Press CTRL+C to exit when done

### Method 2: Systematic Testing
```bash
make test-matrix
```
1. Follow the on-screen instructions
2. Hold down Q and press SPACE
3. Program shows Q's position
4. Press SPACE to continue to O key test
5. Repeat for P key

## Recording Results

After testing, you'll get results like:
- **Q Key**: Column 7, Row 6, Col Mask: $7F, Row Mask: $40
- **O Key**: Column 6, Row 2, Col Mask: $BF, Row Mask: $04  
- **P Key**: Column 5, Row 1, Col Mask: $DF, Row Mask: $02

## Using the Results

Replace the values in `pixel-patrol-04.asm` lines 198-240 with your discovered values:

```asm
check_keyboard_input:
        ; Check Q key (Up) - Use your discovered values
        lda #$7F               ; Your found column mask
        sta $dc00
        lda $dc01
        and #$40               ; Your found row mask
        bne not_q
        ; ... rest of Q key handling
```

The real-time scanner (`make test-simple`) is the fastest method - just run it and press the keys!