# Proportional text caller

See [the shared contract](../../../../../cross-platform/patterns/rendering/proportional-text/README.md).

`demo.asm` supplies the named reset/video setup, font/metrics and ordinary include/init/call. `customise.asm` changes the panel, message and spacing. `prepare.inc` is the callable setup to adapt; the diagnostic mailbox is verification transport, not a required game structure. Use this machine’s existing backend, memory addresses and native byte order.
