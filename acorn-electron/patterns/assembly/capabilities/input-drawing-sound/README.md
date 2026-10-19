# Input, drawing and sound — acorn-electron

This caller reuses the BBC composition's MOS-facing routines, with Electron OS/BASIC and ULA hardware. Type build/loader.bas into BASIC and RUN; Q/A/O/P move and Space restarts. It exercises negative-INKEY scans, cursor-positioned text and queued SOUND. This is a separately executed Electron configuration, not a claim that every BBC hardware technique transfers.

The include paths deliberately point to the maintained MOS wrappers. The 16×10 cell scene, collision rules and resource contracts are described in the BBC composition README. MOS keeps its own IRQ/display/audio services. Reset to leave.
