# Mega Drive colour display

This original test cartridge fills the display with red. It has no game, sound or controls. Source is covered by the repository’s MIT licence; it contains no firmware or game assets.

Run `make` with Asm198x on PATH. Load `demo.bin` as a cartridge on the Europe Mega Drive profile. The program enables the VDP display, selects background palette entry 1, writes red to that CRAM entry, then loops. The header and vectors occupy fixed offsets; padding uses explicit byte counts so the installed assembler does not need a current-location expression.

The initial runtime check uses the published browser player 0.46.2, Europe profile, at frame 300. This proves that configuration’s display path; it is not a claim of physical-console verification. The register sequence also matches the emulator’s `common-sega-mega-drive` backdrop regression.
