# Optional turns using the Electron MOS clock

`make` delegates to `bbc-micro/patterns/assembly/framework/turn-deadline`; no copied clock or deadline driver lives here. Enter that folder's generated `build/loader.bas` into a fresh Electron BASIC program and RUN. Space takes a turn, T toggles timing, reset leaves. MODE 6, 32 KiB PAL, ordinary MOS IRQ/keyboard/VDU services and the loader's reserved memory layout are required.

Read the shared source folder's README for include/init/call contracts, twelve-byte helper state, five-byte OSWORD buffer, press edges, custom duration, wrong/repaired dispatcher, arithmetic boundaries, relocation and measured code/storage costs. The low 16 bits of the MOS centisecond clock are used; the Electron's physical real-time interrupt is 50 Hz. A common MOS API does not imply BBC timing or contention. This directory's separate configuration, records and captures establish Electron execution; BBC evidence is not reused as proof.
