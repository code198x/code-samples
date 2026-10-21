# Word-aware text on dragon-32

Build `demo.asm` or `customise.asm` with the local Makefile and Asm198x.
These complete original reset callers reuse the existing bitmap-text font and
backend. `prepare.inc` shows the normal game-facing call; the mailbox is only
verification transport.

Read the [shared contract](../../../../../cross-platform/patterns/rendering/word-wrap/README.md)
for copying, include order, inputs/outputs, byte order, bounds, ownership, stack,
customisation, soft breaks, overlong words, costs and deliberate error examples.
Use the bitmap-text README beside this directory for this machine's exact video
configuration and original hardware sources. No stock-OS loading or frame budget
is established by these reset fixtures.

Retained evidence lives in `verification/`; fresh verification uses
`scripts/verify-word-wrap.py`, retained replay `scripts/check-word-wrap.py`.
