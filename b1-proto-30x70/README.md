# b1-proto-30x70: one-Node Timer on a 30 x 70 mm protoboard

The compact build of B1: one Waveshare RP2350-POE-ETH Timer on top of a small protoboard and
one Seeed XIAO ESP32-C5 Node underneath it, joined by five wires. Built by Ryan on 2026-11-28;
the positions below are his, read off the built board.

It replaces the first protoboard build (57 x 51 mm, both boards side by side on top; the case
for that one is [`case-b1-proto`](../case-b1-proto/)). There is no case for this one yet.

![Top view of the board](layout-top.svg)

## The board

| | |
|---|---|
| Size | 30 x 70 mm |
| Holes | 10 x 24 on a 2.54 mm grid |
| Hole names | numbers `01` to `10` across the short side, letters `A` to `X` along the long side |
| Mounting | a hole in each corner. They look like M2; not measured |

A hole is named letter then number: `B2` is the second hole along, second across.

## Where the two boards go

**Timer, on top**, component side up, RJ45 at the `A` end, USB-C pointing at `X`.

| Timer pin | Hole |
|---|---|
| GP13 (pin 17) | `B2` |
| GP12 (pin 16) | `B9` |
| VBUS (pin 32) | `Q2` |
| GP0 (pin 1) | `Q9` |

Its two rows of 16 pins run from `B` to `Q`, in rows `2` and `9`.

**Node, underneath**, component side facing away from the board, USB-C at the `X` end.

| Node pin | Hole |
|---|---|
| D0 | `X2` |
| 5V | `X8` |
| D6 | `R2` |
| D7 | `R8` |

Its two rows of 7 pins run from `R` to `X`, in rows `2` and `8`. The two boards share no
column: the Timer ends at `Q`, the Node starts at `R`.

Every pin, both boards:

| Row | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **9** (Timer) | GP12 | GP11 | GP10 | GND | GP9 | GP8 | GP7 | **GP6** | GND | **GP5** | **GP4** | GP3 | GP2 | GND | GP1 | GP0 |
| **2** (Timer) | GP13 | GP14 | GP15 | GND | GP22 | RUN | GP26 | GP27 | AGND | GP28 | ADC_VREF | 3V3 | 3V3_EN | GND | **VSYS** | VBUS |

| Row | R | S | T | U | V | W | X |
|---|---|---|---|---|---|---|---|
| **8** (Node) | **D7** | **D8** | D9 | D10 | 3V3 | **GND** | **5V** |
| **2** (Node) | **D6** | D5 | D4 | D3 | D2 | D1 | D0 |

## The five wires

These are the Timer's default pins, so a freshly flashed Timer needs no setup.

| Signal | Timer pin | Hole | Node pin | Hole |
|---|---|---|---|---|
| 5 V | VSYS (pin 31) | `P2` | 5V | `X8` |
| Ground | GND | `O9`, or any Timer GND | GND | `W8` |
| Timer TX to Node RX | GP4 (pin 6) | `L9` | D7 | `R8` |
| Node TX to Timer RX | GP5 (pin 7) | `K9` | D6 | `R2` |
| SYNC | GP6 (pin 9) | `I9` | D8 | `S8` |

- **Take 5 V from VSYS at `P2`, not VBUS beside it at `Q2`.** VBUS is the Timer's USB power
  only, and is dead on PoE.
- **Which GND pin the built board uses was not recorded.** The Timer has GND at `E9`, `J9`,
  `O9`, `E2` and `O2`; `O9` is the one drawn.
- **How the wires are routed was not recorded either.** Only the ends matter. The drawing
  joins each pair with a dotted line, which is not a route.
- Nothing is wired to the pads on the back of the XIAO: SYNC is on D8, and the Timer restarts
  and updates the Node over the two data wires
  ([oft-timer-rp2350](https://github.com/Open-FPV-Timer/oft-timer-rp2350)).

## Things to keep reachable

- **Recovery jumper:** GP9 at `F9` to the GND next to it at `E9`. Fitted at power-up, it makes
  the Timer use DHCP and the default Node pins for that start.
- **The Timer's RESET and BOOT buttons.** A Timer that hangs needs RESET; the first firmware
  install needs BOOT.
- **The Node's BOOT and RESET buttons, or its USB-C port** at the `X` end, underneath. They
  are the way back for a Node whose firmware update was cut off by a power loss.

## Worked out from the drawings, not measured

From Waveshare's and Seeed's dimension drawings (the same numbers `gen/parts.py` uses).
Check them against the built board.

- **Overhang at the `A` end:** the Timer's board runs about 15 mm past the end of the
  protoboard, and the RJ45 jack about 3 mm further.
- **The Node's back faces the protoboard.** Its underside pads (EN, BOOT, battery, JTAG) look
  at the protoboard's underside. The Timer's solder joint at `Q2`, which is VBUS, comes
  through one column from the Node's end and under its corner. Trim it flush and make sure
  nothing on the Node's back can touch it.
- **The Timer's USB-C plug lies over columns `R` to `X` on the top side**, between rows 3 and
  8 or so. The Node's joints in rows `2` and `8` come through there: trim them low so a plug
  fits.
- **The Node's USB-C port** ends about 3 mm inside the protoboard's `X` end, so a plug goes in
  from the end, underneath.

## The drawing

`layout.py` writes `layout-top.svg` from the hole positions at its top, the same ones the
tables above use. Change a position there and run `python3 layout.py`.

An earlier drawing of this idea, on an 11-row board with the Node one row further in, is the
artifact "B1 Protoboard Layout". This document is the board as built.

## Licence

GPL-3.0-or-later, the same as the rest of this repo. See [LICENSE](../LICENSE).
