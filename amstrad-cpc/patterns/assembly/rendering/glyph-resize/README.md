# Glyph shrinking: amstrad-cpc

Complete original reset caller for the [shared component](../../../../../cross-platform/patterns/rendering/glyph-resize/README.md). `make` builds the normal 5x7 and customised 8x4 F examples. `prepare.inc` shows the ordinary init/call and existing scaled renderer. The mailbox is verification transport.

Read the shared contract for bounds, overlap, byte order, clobbers, costs, customisation and wrong/fixed sampling. From the repository root, use the documented fresh verifier with `--only amstrad-cpc`. Retained configuration-specific records live in `verification/`. Stock OS and cycle timing are not qualified.
