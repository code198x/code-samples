# Action Cooldowns on Amiga

Only CCR changes; all data and address registers survive. Read GRANTED rather than carry. A direct call uses four return-address stack bytes.

Private byte fields REMAINING/REQUEST/AVAILABLE/GRANTED. init clears all; tick once every simulation update regardless of request, saturating at0; try clears grant and commits period only if ready with nonzero request+availability. Consume grant immediately. Caller owns truthful resource reservation, immediate action creation and one mutation owner. No hidden ammo/heap/input/frame wait. One fixed block; independent weapons require distinct bindings or a selected-state wrapper.

PERIOD0..255, qualified3/5. Zero period disables rate gating only. Default trace grants at0,3,6,9; custom5 grants0,6. Wrong only ticks on request, grants0,9 and freezes between taps. Repair matches working executable.

The A500 OCS/PAL caller cold-boots an OFS ADF with Kickstart1.3, takes over IRQ/DMA/Copper and a private bitplane, and explicitly disarms inherited sprites. Its code/data are a relocated Hunk; it does not restore the OS.

Measured 96 code bytes +4 state bytes, two bounded paths. Fixtures input table and packaging are not helper cost. make ASM198X=/path/to/asm198x BUILD198X=/path/to/build198x. Native verification: scripts/verify-game-rules.py --topic action-cooldown --system commodore-amiga. Packet1335bytes covers256 timer bytes,256 request bytes with/without availability,256 availability bytes and12 logical updates. Packed test rows require remaining<128 and grant0/1 before encoding; larger qualified periods need an unpacked observer. check-game-rules.py and test_game_rules.py require every declared target and reject corrupted claims. Firmware hashes only; no private snapshots distributed.
