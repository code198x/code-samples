# Neo Geo AES colour display

This original test cartridge fills the display with red. It has no game, sound or controls. Source is covered by the repository’s MIT licence. It contains no BIOS, commercial game assets, or sound program.

Run `make` with Asm198x on PATH. Load `demo.bin` as a bare P-ROM on the AES profile, with your own AES BIOS. The BIOS starts normally; the cartridge does not replace the BIOS or jump around startup. With the original Europe AES BIOS, the image remains black during startup before the display appears. The recorded trace shows sound command 2 with reply 0 during this wait; a sound-program timeout is a possible explanation, not an established cause. No wall-clock startup time is promised.

The [SNK Neo Geo Development Manual](https://db.hfsplay.fr/files/2019/07/05/Neo-Geo_Development_Manual_uuts5xr.pdf), System Program pp. 6–9, specifies the header offsets and 61-word recognition sequence. Those protocol words are reproduced in `demo.asm`; the display program is ours. System Program pp. 11 and 21 specify USER dispatch and vertical-blank handling. Initialisation and eyecatcher requests return to SYSTEM_RETURN; demonstration/title requests set palette entry 4095 to red. The interrupt handler delegates BIOS startup interrupts and calls SYSTEM_IO during the display.

The initial check uses genuine AES firmware through the published browser player 0.46.2 at frame 600. The recorded BIOS-to-USER trace and red image prove that configuration’s startup/display path, not physical-console behaviour or sound support.
