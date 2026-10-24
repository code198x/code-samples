# Damage and Recovery on NES

A/flags change; X/Y and decimal mode survive. Damage subtraction requires decimal mode clear on C64; the native caller executes CLD. NES ignores decimal arithmetic, but retains the same clear-D calling convention. The helper uses no scratch pointer. A direct call uses two return-address stack bytes.

Five private byte fields HEALTH/REMAINING/AMOUNT/APPLIED/KILLED. damage_init sets health3 and clears others. Supply AMOUNT0..255, service once per entity/update after aggregating contacts. A positive recovery counter decrements first. Accept only alive, ready, nonzero amount; saturate health0, APPLIED pulse on accepted damage, KILLED on positive-to-zero. Reload PERIOD only on accepted nonfatal hit. Both pulses clear on next step; AMOUNT is caller-owned and must be0 without a request. One owner, no IRQ mutation.

PERIOD0..255; maintained configurations3/5 only. Default hits at indices0,3,6 under continuous contact, one death pulse. Custom period5 delays death to10. Wrong re-arms recovery each contact and prevents all hits. Exact repair restores executable identity. No healing, armour, revival or object disposal hidden inside.

The standalone NTSC NROM cartridge disables NMI, DMC and audio and draws background text. Diagnostics use $70–$84 and $0200–$07D0; this conflicts with a usual $0200 OAM buffer. The fixture performs no OAM DMA.

Measured 72 code bytes +5 state bytes; bounded branch path, no scan/wait. The display/client/input table is not component cost. make ASM198X=/path/to/asm198x. scripts/verify-game-rules.py --topic damage-rules --system nintendo-entertainment-system produces native configuration and records. scripts/check-game-rules.py and unittest test_game_rules.py require all declared targets, reject corruption and verify loaded code/images. Packet1248bytes: dirty initialization,256 health values at amount1,36 edge pairs,6 recovery boundaries,12 updates. This is selected logical coverage, not all state combinations or physical hardware timings. Firmware hashes only; never commit private snapshots.
