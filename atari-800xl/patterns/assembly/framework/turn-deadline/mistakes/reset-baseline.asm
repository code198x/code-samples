; SPDX-License-Identifier: MIT
* = $8000
DURATION = 240
!source "caller.inc"
!source "mistakes/reset-baseline.inc"
!source "../../../../../cross-platform/patterns/framework/elapsed-deadline/6502.inc"
!source "dispatch.inc"
!source "input.inc"
code_end:
!if code_end > $8300 { !error "Code overlaps deadline context" }
