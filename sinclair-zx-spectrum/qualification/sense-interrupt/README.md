# Sense Interrupt Status diagnostic

The program loads normally through +3DOS, exercises public FDC ports and writes
an execution-created A5/5A signature with a deterministic striped screen.
It records every result byte, result length and following MSR for ten named
stages. Logical units0 and2 share physical driveA but retain independent PCNs.
Motor transitions exercise both READY polarities; an intentionally misplaced
Sense Drive Status tests the NEC requirement to acknowledge a seek interrupt.

All drains are bounded and record their terminal one-byte Invalid result.
Frame/event limits and host timeouts belong to the umbrella qualification runner.
The diagnostic injects no memory, restores no snapshot and calls no host FDC API.
It assumes the digital motor/READY profile; physical spin-up timing is separate.

Build with Asm198x, dialect pasmo, CPU z80, origin/entry32768. Use Build198x plus3
with loader.bas and the assembled CODE. The umbrella runner validates +3DOS/native
metadata, cold-loads the disk, checks loaded CODE, completion writes/PC, the full
trace and screen. Source/assets are MIT; firmware is a legitimate local input
and is never committed with this fixture.

Independent references deliberately remain observations: Fuse relaxes the
post-seek command-order rule for compatibility, and reference implementations
may differ in polling the US1-unconnected drive aliases. A successful process
or matching completion signature alone cannot qualify these transactions.
