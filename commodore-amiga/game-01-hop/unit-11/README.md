# Unit 11: Sound Effects

Paula audio chip programming for game sounds.

## What This Unit Covers

- Paula audio hardware
- Sample playback
- Volume and period control
- Sound triggering
- Multiple sound effects

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. Sounds play on hop, death, and scoring.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Paula registers | AUDxLCH, AUDxLEN, AUDxPER, AUDxVOL |
| Sample data | 8-bit signed PCM audio |
| Period | Controls playback speed/pitch |
| DMA enable | DMACON bits 0-3 for audio channels |

## Playing a Sound

```asm
play_hop_sound:
    lea     CUSTOM,a5
    move.l  #hop_sample,AUD0LCH(a5)
    move.w  #hop_length/2,AUD0LEN(a5)
    move.w  #447,AUD0PER(a5)        ; ~8kHz
    move.w  #64,AUD0VOL(a5)         ; Max volume
    move.w  #$8001,DMACON(a5)       ; Enable audio 0
```

## Sound Effects

| Event | Sound |
|-------|-------|
| Hop | Short click |
| Death | Descending tone |
| Goal | Ascending arpeggio |
| Game over | Low buzz |

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
