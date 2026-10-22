# BBC Micro: reusable ASSEMBLY input and sound

Target: BBC Model B MOS 1.20/BASIC II, MODE 6.

## Run

make -C bbc-micro/patterns/assembly/input/mos-controls ASM198X=/path/to/asm198x

Type build/loader.bas into the named BASIC, RUN it, then use Q/A/O/P and Space. The loader lowers HIMEM before installing code at $3000; MOS services remain active.

## Reuse

Copy input.inc, its tables/private key_index and the required OSBYTE constant; provide controls storage. The complete caller also supplies edge detection and game state. Copy sound.inc and define OSWORD=$FFF1 to use the queued effect.

Input: read_controls scans Q/A/O/P/Space through MOS OSBYTE 129. It returns controls bits 1/2/4/8/16 for up/down/left/right/action, without consuming the character buffer. A/X/Y/flags change; key_index is private scratch.

Audio: The SOUND block is eight bytes: channel 17 flushes and uses channel 1, amplitude -15, pitch 100, duration 2. OSWORD 7 copies it into MOS audio state. Playback is asynchronous; call from main with MOS IRQ services intact. A/X/Y/flags change.

The caller owns its numbered program, global variables and presentation. Keep initialisation outside the repeated command path.

## Adapt

Change the key-number/mask tables together. Read once, then derive pressed/released before replacing previous.

Change the SOUND block. Queuing versus flushing is a deliberate channel policy; copying the block gives the OS its own queued parameters.



## Error cases and limits

The muted control explicitly patches trigger_sound’s first RAM opcode to RTS after loading, then restores it. This diagnostic intervention is not presented as ordinary cartridge or firmware startup.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-mos.py --native /path/to/released-tools --only bbc
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Acorn, BBC Microcomputer Advanced User Guide / Electron technical documentation: OSBYTE &81 negative INKEY and OSWORD &07 SOUND block; MOS IRQ ownership.
