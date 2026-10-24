# Action Cooldowns on C64

A/flags change; X/Y and decimal mode survive. Unlike the damage subtraction routine, this helper has no decimal-clear precondition: it only tests and decrements the counter. A direct call uses two return-address stack bytes.

Private byte fields REMAINING/REQUEST/AVAILABLE/GRANTED. init clears all; tick once every simulation update regardless of request, saturating at0; try clears grant and commits period only if ready with nonzero request+availability. Consume grant immediately. Caller owns truthful resource reservation, immediate action creation and one mutation owner. No hidden ammo/heap/input/frame wait. One fixed block; independent weapons require distinct bindings or a selected-state wrapper.

PERIOD0..255, qualified3/5. Zero period disables rate gating only. Default trace grants at0,3,6,9; custom5 grants0,6. Wrong only ticks on request, grants0,9 and freezes between taps. Repair matches working executable.

The PAL PRG uses stock BASIC/KERNAL startup, then owns screen/font/colour RAM and disables IRQ sources. Diagnostics occupy $70–$83 and a packet at $C000; it does not restore BASIC.

Measured 47 code bytes +4 state bytes, two bounded paths. Fixtures input table and packaging are not helper cost. make ASM198X=/path/to/asm198x. Native verification: scripts/verify-game-rules.py --topic action-cooldown --system commodore-64. Packet1335bytes covers256 timer bytes,256 request bytes with/without availability,256 availability bytes and12 logical updates. Packed test rows require remaining<128 and grant0/1 before encoding; larger qualified periods need an unpacked observer. check-game-rules.py and test_game_rules.py require every declared target and reject corrupted claims. Firmware hashes only; no private snapshots distributed.
