# acorn-atom: wait for a delivered command

`make` builds `build/demo.bin` and generates `build/loader.bas`. Type the complete
listing in stock BASIC and RUN. Press G to advance, X to leave the count unchanged.
The Atom requires the full 32 KiB configuration; the CPC uses a CPC464.

The [shared contract](../../../../../cross-platform/patterns/framework/command-turns/README.md)
explains inclusion, initialisation, calls, state, clobbers, memory ownership,
customisation, the faulty dispatch, reproduction and primary sources. Start there
before relocating the code. The native record and captures are in `verification/`.
