# Original console display cartridges

Approved scope: two original silent red-display programs; no firmware, game assets, dependencies, or emulator changes. The initial local integration plan preceded source work; this tracked plan makes the review scope durable in the repository.

1. Add `sega-mega-drive/demos/colour-screen/{demo.asm,Makefile,README.md}`: reset vectors, VDP display enable and red background, no controls/sound. Build clean outputs with existing Asm198x and compare bytes with an independently installed reference assembler.
2. Add `snk-neo-geo/demos/colour-screen/{demo.asm,Makefile,README.md}`: manual-cited cartridge recognition/header, genuine BIOS USER requests and interrupt contract, red background. Do not substitute synthetic firmware or bypass startup. Verify full 4096-byte image and header/entry offsets.
3. Run both on the exact published player 0.46.2: Europe Mega Drive frame 300 and AES frame 600 with original, privately supplied AES firmware. Preserve BIOS-to-USER PC trace, black frame-300 startup control, invalid-header control, source/media/capture hashes and visual review. Firmware stays private. Report sound wait as observation, possible timeout as inference.
4. Push checked samples PR, await all current hosted checks and parent approval before merging. Website integration is separate: fail-closed staging, default media via existing src API, genuine posters and independent source/hash/frame receipts. No historical evidence refresh.
