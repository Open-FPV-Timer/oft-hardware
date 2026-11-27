"""What the carrier boards have in common: which board has which slots on which Timer pins.

The 1-Node board is a stick. The 2, 4 and 8-Node boards put the Timer across the middle with
a row of XIAOs above it and (4 and 8) a row below; slots are numbered left to right, top row
first. Pin choice follows the layout: each row's UART pads are wired to the Timer pin row
facing it, in the same left-to-right order, so nothing crosses.

UART1 (GP4/GP5) is the pair oft-timer-rp2350 uses today; UART0 is GP0/GP1. Every other slot
needs a PIO UART.
"""
import parts

SIZES = (1, 2, 4, 8)
# board: {slot: (Timer TX pin name, module pin, Timer RX pin name, module pin)}
MAP = {
    1: {1: ("GP4", 6, "GP5", 7)},
    2: {1: ("GP4", 6, "GP5", 7), 2: ("GP0", 1, "GP1", 2)},
    4: {1: ("GP4", 6, "GP5", 7), 2: ("GP0", 1, "GP1", 2),
        3: ("GP13", 17, "GP15", 19), 4: ("GP22", 21, "GP28", 26)},
    8: {1: ("GP10", 14, "GP11", 15), 2: ("GP4", 6, "GP5", 7), 3: ("GP2", 4, "GP3", 5), 4: ("GP0", 1, "GP1", 2),
        5: ("GP12", 16, "GP13", 17), 6: ("GP14", 18, "GP15", 19), 7: ("GP22", 21, "GP26", 23),
        8: ("GP27", 24, "GP28", 26)},
}
# One line bussed to every slot. EN and BOOT are not wired: the Timer restarts a Node and reaches
# its bootloader over the Node's own UART, so no pad on the back of a XIAO is used.
BUS = (("SYNC", "GP6", 9, "220R", "C22962"),)
UART = {"GP4": "UART1", "GP0": "UART0"}
HOLES = {1: 4, 2: 3, 4: 3, 8: 4}

PITCH = 22.0                    # slot to slot along a row


def name(n):
    return "oft-carrier-%d" % n


def uart(n, slot):
    return UART.get(MAP[n][slot][0], "PIO")


def res_ref(slot, rx):
    """Link resistor on a slot's Timer-TX line (rx False) or Timer-RX line (rx True)."""
    return "R%d" % (2 * slot - (0 if rx else 1))


def bus_ref(n, i):
    return "R%d" % (2 * n + 1 + i)
