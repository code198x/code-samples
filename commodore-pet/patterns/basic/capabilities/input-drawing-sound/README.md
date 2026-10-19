# Input, text-cell drawing and VIA sound — PET

The stock 40-column runtime accepts GO, advances the displayed count, draws a three-row text-cell box and drives the VIA's CB2 output. Early PETs need a speaker attached to the user port to hear this signal; later models with a built-in speaker are separate configurations. The emulator capture measures its modelled CB2 audio, not an assertion that every PET has a speaker.

Type demo.bas into BASIC and RUN. GOSUB 1000 draws with PRINT. GOSUB 2000 owns VIA ACR, shift register and Timer 2 low registers ($E84B/$E84A/$E848), selects the free-running shift-register sound path, then disables it. The interpreter delay blocks. Do not combine this with another VIA shift-register/Timer 2 consumer without resolving ownership.

This reuses the command-loop input contract. It is blocking command input and text-cell drawing, not a held-direction reader or sprite renderer. The verifier compares sound against an invalid-command keyboard baseline, and requires the omitted sound call to fail the same guard. Source and configuration identities are retained separately from the code listing.
