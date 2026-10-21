# sinclair-zx81: place fixed-ROM characters

Use `characters.inc` in your own project. `demo.asm` is the complete executed caller. `caller.bas` invokes it through the stock ROM; qualification uses 16 KiB RAM and debugger placement, not a cassette loader.

The component is 164 code bytes, with 24 private context bytes.

See [the contracts, ownership, costs, primary/secondary sources and limits](../../../../../cross-platform/patterns/rendering/fixed-characters/README.md). Run `make`, then the shared verifier with your own firmware. [Retained results](verification/results.json) record actual calls and completed fault controls.
