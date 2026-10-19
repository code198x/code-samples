# Numeric input and text-cell drawing

The stock 1 KiB machine accepts a number, adds it to a running total and redraws a three-row text-cell box. Input blocks. ZX80 display interruption while calculating and ZX81 display service are different hardware behaviours; this caller does not promise continuous animation.

The stock machine has no built-in speaker/sound generator. Sound is hardware-absent for this configuration, not a successful audio probe. Expansion audio is a separate configuration.

Enter the listing using the keyword keyboard, then RUN. The retained verifier checks real input and rendered numeric state and captures the box. The command-loop version remains the smaller input-only example.
