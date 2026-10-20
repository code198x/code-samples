# Amiga: fixed-width bitmap text at pixel positions

Start with demo.asm: own the one-plane display, reserve T/BP, include the text
component and CPU span backend once, supply a readable font/string, then make
the normal text_string call. The mailbox afterwards is optional diagnostic
transport, not an integration requirement.

The [Amiga text contract](../../../../../cross-platform/patterns/rendering/bitmap-text/amiga/README.md)
defines its distinct 32-bit-pointer layout, 24-bit address arithmetic, source and
display ownership, state/clobbers, clipping, logical advance and measured costs.
Use this table rather than the other CPUs' 16-bit-address context offsets.

The font and reset fixture are original MIT-licensed code/data. Retained complete
observations and native captures are in verification/; a fresh native run writes
build/verification/. Stock-OS loading, real-hardware timing and coexistence are
separate checks.
