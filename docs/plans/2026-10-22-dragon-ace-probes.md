# Dragon and Jupiter Ace: current-release language probes

Status: authorised implementation, not merge approval.

1. Reuse Dragon BASIC and Ace FORTH command-loop and input/drawing/sound sources. Refresh through released Emu198x 0.44.1; retain exact tool/firmware/source identities, RAM observations, captures and failing controls.
2. Add stock-firmware-compatible Dragon 6809 and Ace Z80 assembly callers under each system/patterns/assembly/framework/command-loop, with reusable routines, caller ownership, load instructions, customisation and wrong/fixed examples. Reuse existing assembler dialects and transport; verify source-to-loaded-byte agreement and actual keyboard/display behaviour. Exercise drawing/sound separately where supported.
3. Extend verification scripts and additive inventory records without conflating language routes. Validate retained evidence independently and falsify the checks with changed evidence/source.
4. Add website entries from maintained source, test listings, links, narrow/mobile layout and build. Keep existing baseline failures distinct. Push samples and website review PRs; update docs issue 117.
5. Refresh the machine/language matrix with exact review/publication states. Preserve native evidence, inspect all owned temporary worktrees and ignored files, retain remote commits, then remove owned workspaces/tools and stop processes.

Verification: native cold boots, idle/accepted/ignored/held input as appropriate, nonzero initial state and wrap where applicable, custom step, wrong/reset and repaired control; rendered counters independently decoded from video RAM; captures visually inspected; input/drawing/audio negative controls; source and executable hashes, release producer locks; website production and targeted browser checks.
