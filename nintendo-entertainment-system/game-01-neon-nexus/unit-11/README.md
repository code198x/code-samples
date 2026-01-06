# Unit 11: Difficulty

Progressive difficulty based on score.

## What This Unit Covers

- Difficulty levels
- Speed scaling
- Enemy count increases
- Score thresholds

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. Game gets harder as score increases.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Difficulty variable | Current level (0-4) |
| Speed tables | Lookup enemy speed by difficulty |
| Threshold check | Compare score to level-up values |
| Max cap | Prevent overflow at highest level |

## Difficulty Scaling

| Level | Score | Enemy Speed | Count |
|-------|-------|-------------|-------|
| 0 | 0+ | 1 | 2 |
| 1 | 500+ | 1 | 3 |
| 2 | 1500+ | 2 | 3 |
| 3 | 3000+ | 2 | 4 |
| 4 | 5000+ | 3 | 4 |

## Difficulty Check

```asm
check_difficulty:
    lda score+1
    cmp #$50            ; 5000
    bcs @level4
    cmp #$30            ; 3000
    bcs @level3
    ; etc...
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
