# mattel-aquarius: place fixed-ROM characters

Use `characters.inc` in your own project. `demo.asm` is the complete executed caller. The caller is an original reset driver, using the separately supplied local stock character ROM. It is not a stock-OS loading example.

The component is 103 code bytes, with 24 private context bytes.

See [the contracts, ownership, costs, primary/secondary sources and limits](../../../../../cross-platform/patterns/rendering/fixed-characters/README.md). Run `make`, then the shared verifier with your own firmware. [Retained results](verification/results.json) record actual calls and completed fault controls.
