# Software-sprite lifecycle across machines

Continue the approved rendering families after merging samples116/website852. The shared problem is a moving software object over a persistent background, including overlapping objects; Amiga blitter objects are the largest unqualified gap.

1. Add reusable Spectrum rectangle save/restore alongside the existing masked renderer, and a two-object caller. Add an Amiga synchronous chip-RAM rectangle save/restore and masked bob component, with an original ADF caller. Add explicit-buffer cell save/restore on BBC Micro while reusing its existing masked drawing. Preserve existing interfaces and evidence.
2. Verify actual guest bitmap/bitplane bytes against independent masked-composition and restoration expectations, including overlap, source preservation, boundary/zero cases and wrong-order or broken-mask controls. Retain configuration/tool/source identities; firmware stays local. Measure no universal frame budget.
3. Add one shared lifecycle entry with distinct Spectrum, BBC and Amiga implementations. Explain mask conventions, reverse-order erasure, stale backgrounds, camera ordering, hardware sprites' different lifecycle and onward dirty-tile/back-buffer approaches. Link the existing family and machine entries without duplicating their concepts.
4. Build the website, validate included code/content, exercise new desktop/phone pages, inspect actual captures, push verified commits and prepare draft PRs. Do not merge or deploy the new tranche without approval.

Planned sample paths: */patterns/assembly/rendering/sprite-lifecycle/{*.inc,demo.asm,Makefile,README.md}; scripts/verify-sprite-lifecycle.py; docs/sprite-lifecycle/verification/. Website: cross-platform/rendering/sprite-lifecycle.mdx and the three machine implementations, plus links/coverage updates. Exact helper paths follow existing code after inspection. No dependencies or schema/layout changes.

Temporary worktrees: /tmp/sprite-lifecycle-samples and /tmp/sprite-lifecycle-website. Tools, verification roots, servers and build caches use the same task prefix; retain review evidence and remote commits, then remove all temporary work before completion.
