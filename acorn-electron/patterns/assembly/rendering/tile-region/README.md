# acorn-electron: native region drawing

The maintained `demo.asm` separates original reset setup, map/assets and test cases from the reusable routine. See [calling contract, inclusion, initialisation, registers, ownership, costs, primary sources and configuration limits](../../../../../cross-platform/patterns/rendering/character-regions/README.md).

Build with `make ASM198X=/path/to/asm198x`. This produces an original reset fixture, not a stock-OS executable. `verification/results.json` locks the executed source and released tool identities; readbacks and native captures include completed failure controls. Run `python3 scripts/check-character-regions.py` from the repository root to check retained evidence.
