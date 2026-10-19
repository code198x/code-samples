# Input, text-cell drawing and sound: dragon-32

This probe extends the maintained command-loop caller. It accepts the same command, draws a three-row box made of text cells, and sounds after an accepted command. This is blocking command input, not a held-direction reader or real-time renderer.

Type the listing into the stock BASIC and RUN. The command-loop README documents the machine configuration and input. `GOSUB 1000` draws using PRINT; `GOSUB 2000` owns the sound registers or firmware sound channel shown in the source. The FOR delay, where present, blocks and varies with interpreter speed. Do not use it as a game clock.

Firmware is supplied separately. The executable capability verifier records input and drawing separately from sound, including deliberately omitted drawing/sound calls. A listing alone does not establish execution.
