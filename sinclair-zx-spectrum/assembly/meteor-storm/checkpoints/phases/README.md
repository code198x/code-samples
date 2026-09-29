# Give the game clear phases

The first-dodge game gains a title, a flight and a result. `phase` names them: 0 title, 1 flight, 2 destroyed, 3 clear space. `title` draws four lines at hand-counted columns and waits for Space; `release_keys` waits until Space, Q and R are all up, so one press cannot start a flight and then skip a result. `new_game` clears the screen, zeroes every byte from `state_start` to `state_end` in one LDIR, then sets the few values that are not zero: phase 1, ship X 116, `hull` 1 and the meteor at (116,24). `hull` is the alive flag: contact clears it, and the main loop leaves for `lost` when it reads zero. `draw_ship` sets `ship_visible` and `erase_ship` removes the ship only while that flag says an image is on screen. Reaching y>=174 leaves for `won`. Both results share one screen.

Predict, then check: delete `ld a,1` and `ld (hull),a` from `new_game`. The block clear leaves `hull` at 0, so the first update after launch reads zero and shows SHIP DESTROYED at once. Restore the two lines. Left alone, the ship is hit on update 44, when the meteor reaches y=156, about 1.8 seconds after launch.

Space launches; O/P steer. One hit ends the run. R retries a result; Q returns to the title, in flight or at a result. Holding Space at the title starts nothing until it is released.

Repeat: R at a result starts the same run again from a cleared state; Q then Space starts it from the title.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
