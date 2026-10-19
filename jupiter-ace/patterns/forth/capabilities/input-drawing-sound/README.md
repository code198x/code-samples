# Input, text-cell drawing and BEEP — Jupiter Ace

Enter demo.fth line by line into stock FORTH, allowing each definition to compile. TURNS waits for a fresh 1 key, increments a count, draws BOX and sounds. Holding 1 does not repeat; 0 is ignored. Reset to leave.

NEWKEY, BOX and TURNS reuse the earlier key/display caller. BOX leaves the count on the stack. BEEP consumes pitch 478 and length 120 milliseconds, then returns; sound occupies the CPU. The FORTH manual chapter 11 explains those operands, and chapter 26 describes the even-port read/write speaker control. [Jupiter Cantab's FORTH Programming manual](https://pestilenz.org/~bauerm/jupiter.pdf), printed pp. 63–68 and 152–153.

Emu198x PR #1882 corrects the speaker latch needed by stock ROM BEEP. Qualification on that fix does not claim it is already released. The verifier enters the source through the keyboard, checks idle/held/new-key behaviour, captures the box and actual PCM, and requires a caller without BEEP to reject the sound guard. It also retains the earlier fabricated-key negative control.

Run `python3 scripts/verify-ace-capabilities.py --native /path/to/native/binaries` from the repository root; supply the stock ROM locally with --firmware. No firmware is distributed.
