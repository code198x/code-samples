"""Independent occupancy-list model of the bounded Ace pool contract."""

NAMES = ("PB", "PC", "PS", "PK", "PF", "PX", "PI")


def valid(state: dict[str, int], here: int) -> bool:
    base, size = state["PB"], state["PS"]
    return 1 <= size <= 8 and 15441 <= base < here and here - base >= size


def step(
    state: dict[str, int],
    flags: list[int],
    here: int,
    operation: str,
    argument: int = 0,
    base: int = 0,
) -> list[int]:
    """Mutate only the model; return actual data-stack result cells."""
    argument &= 65535
    if operation == "init":
        state.update(PB=base & 65535, PC=argument, PS=0, PK=0, PF=0, PX=1)
        if not 1 <= argument <= 8:
            return [0]
        state["PS"] = argument
        if not valid(state, here):
            state["PS"] = 0
            return [0]
        flags[:argument] = [0] * argument
        state.update(PI=0, PK=argument, PF=1, PX=0)
        return [1]
    state["PK"] = state["PS"] if operation == "get" else argument
    state.update(PF=0, PX=1)
    if not valid(state, here):
        return [state["PK"], 0] if operation == "get" else [0]
    if operation == "get":
        free = [i for i, byte in enumerate(flags[: state["PS"]]) if byte == 0]
        state.update(PI=free[0] if free else state["PS"], PX=0)
        if free:
            state.update(PK=free[0], PF=1)
            flags[free[0]] = 1
        return [state["PK"], state["PF"]]
    if operation != "release":
        raise ValueError(operation)
    state["PX"] = 2
    if argument < state["PS"] and flags[argument]:
        flags[argument] = 0
        state.update(PF=1, PX=0)
    return [state["PF"]]
