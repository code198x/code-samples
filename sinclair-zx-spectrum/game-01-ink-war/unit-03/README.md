# Unit 3: Movement

Keyboard scanning for cursor control.

## What This Unit Covers

- Keyboard matrix scanning via IN instruction
- Q/A/O/P key detection
- Cursor boundary checking
- Movement with screen update

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. Use Q (up), A (down), O (left), P (right) to move the cursor.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Keyboard matrix | IN (port), A reads row specified by high byte |
| Half-row ports | $FB (QWERT), $FD (ASDFG), $DF (POIUY) |
| Boundary check | Prevent cursor leaving board |
| Key debounce | HALT waits for frame to prevent repeat |

## Keyboard Matrix

| Port | Keys (bit 0-4) |
|------|----------------|
| $FB | Q W E R T |
| $FD | A S D F G |
| $DF | P O I U Y |

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
