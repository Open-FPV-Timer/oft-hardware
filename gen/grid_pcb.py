#!/usr/bin/env python3
"""Generate the 2, 4 and 8-Node boards, carrier-N/oft-carrier-N.kicad_pcb, from the netlist.

Run through tools/kicad.sh gen/build.sh N. Placement and routing are written out by hand
below; this bootstraps the first draft. Once a board is edited in KiCad, stop regenerating it.

Board coordinates are millimetres from the top-left corner. The Timer module lies across the
middle, RJ45 at the left edge. A row of XIAOs sits above it with their USB-C ports at the top
edge, and (4 and 8 Nodes) a second row below it with USB-C at the bottom edge. Antenna
connectors face the Timer.

Routing plan.
- UART: each XIAO's D6/D7 pads face the Timer. Every line runs pin -> resistor just outside
  the pin row -> a short top-layer lane in the channel between the Timer and the XIAOs -> pad.
  Pins and pads are matched left to right, so the lanes never cross and need no vias.
- SYNC, EN, BOOT: one bottom-layer line per row through that pad's plated hole on every XIAO.
  The two rows are joined by three verticals at the left, under the Timer's RJ45 end, and fed
  there from the Timer through top-layer lanes under the module.
- Power: VSYS runs along both outer edges on the bottom layer, joined by a spine at the right.
  The column beside each XIAO holds its diode, capacitor and GND via.

The bottom row is laid out in its own coordinates; the top row is the same cell turned 180
degrees about the centre of the Timer.
"""
import os
import sys

import carrier
import parts
from pcb import Board, F, B, SILK, BSILK, DOC, SIG, PWR

N = int(sys.argv[1])
assert N in (2, 4, 8), N
NAME = carrier.name(N)
HERE = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "carrier-%d" % N))
COLS = 4 if N == 8 else 2
ROWS = 1 if N == 2 else 2
RADIUS = 2.0

CHANNEL = 8.2                                   # Timer pin row to the XIAO body edge
YT = 2.0 + parts.XIAO_L + CHANNEL               # Timer top pin row (31.2)
YB = YT + parts.RP_ROWS                         # Timer bottom pin row
YC = (YT + YB) / 2
CYB = YB + CHANNEL + parts.XIAO_L / 2           # bottom row XIAO centres
CX0 = 14.0 if N == 8 else 22.0
CXS = [CX0 + carrier.PITCH * c for c in range(COLS)]
XC = (CXS[0] + CXS[-1]) / 2
W = 94.0 if N == 8 else 66.0
H = CYB + parts.XIAO_L / 2 + 2.0 if ROWS == 2 else YB + 4.0
RP_PIN1 = (parts.RP_L - parts.RP_PIN1_FROM_USB_END, YT)                             # (61.65, YT)
HOLES = [(4.0, YC - 5.5), (4.0, YC + 5.5)] + ([(90.0, YC - 5.5), (90.0, YC + 5.5)] if N == 8 else [(62.8, YC)])
assert len(HOLES) == carrier.HOLES[N]


def pin_x(pin):
    return RP_PIN1[0] - ((pin - 1) if pin <= 16 else (32 - pin)) * parts.RP_PITCH


def top(pin):
    return pin <= 16


class Slot:
    """One XIAO. Geometry is given in the bottom row's frame; t() maps it onto the board."""

    def __init__(self, n):
        self.n = n
        self.upper = n <= COLS
        col = (n - 1) % COLS
        self.cx = CXS[COLS - 1 - col] if self.upper else CXS[col]      # frame x; the top row is turned round
        self.ref, self.d, self.c = "U%d" % (n + 1), "D%d" % n, "C%d" % n
        self.gx = self.cx - carrier.PITCH / 2                           # parts column beside the XIAO

    def t(self, x, y):
        return (round(2 * XC - x, 4), round(2 * YC - y, 4)) if self.upper else (x, y)

    def rot(self, a):
        return (a + 180) % 360 if self.upper else a


SLOTS = [Slot(n) for n in range(1, N + 1)]
b = Board(os.path.join(HERE, NAME + ".kicad_pcb"), sys.argv[2], "OFT carrier, %d Nodes" % N, "0.1 draft", "2026-11-10")

# ---------------------------------------------------------------- placement
# A UART resistor sits just outside the pin row its slot faces. Nearly always that is the row
# its Timer pin is on; a pin on the far row is brought across on the bottom layer to a spot
# just left of the row end (VIRT_X).
RES_OUT, VIRT_X = 3.2, 21.3
PLACE = {"U1": RP_PIN1 + (270,)}                 # USB-C end towards +X
uart = []                                        # (slot, resistor ref, Timer pin, XIAO pad, resistor x)
for s in SLOTS:
    _, tx, _, rx = carrier.MAP[N][s.n]
    for rxline, pin, pad in ((False, tx, 8), (True, rx, 7)):
        ref = carrier.res_ref(s.n, rxline)
        x = pin_x(pin) if top(pin) == s.upper else VIRT_X
        PLACE[ref] = (x, YT - RES_OUT, 90) if s.upper else (x, YB + RES_OUT, 270)   # pad 1 towards the pin row
        uart.append((s, ref, pin, pad, x))
    PLACE[s.ref] = s.t(s.cx, CYB) + (s.rot(180),)          # bottom row: USB-C towards the bottom edge
    PLACE[s.d] = s.t(s.gx, CYB + 7.75) + (s.rot(270),)     # cathode towards the Timer
    PLACE[s.c] = s.t(s.gx, CYB + 3.4) + (s.rot(90),)       # pad 1 (5 V) towards the diode
BUS_PAD = {"SYNC": 19, "EN": 17, "BOOT": 21}
for i, (_, _, pin, _, _) in enumerate(carrier.BUS):       # bus resistors: under the Timer, inside the top row
    PLACE[carrier.bus_ref(N, i)] = (pin_x(pin), YT + RES_OUT, 270)
for i, (x, y) in enumerate(HOLES):
    PLACE["H%d" % (i + 1)] = (x, y, 0)
b.place_all(PLACE)
P = b.P

# The layout below depends on these; fail loudly if a footprint or rotation changes.
near = lambda p, q: abs(p[0] - q[0]) < 1e-3 and abs(p[1] - q[1]) < 1e-3
assert near(P("U1", 16), (23.55, YT)) and near(P("U1", 32), (61.65, YB)), P("U1", 32)
for s in SLOTS:
    assert near(P(s.ref, 14), s.t(s.cx - 8.1, CYB + 7.62)), (s.ref, P(s.ref, 14))       # 5V pad, outer corner
    assert near(P(s.d, 1), s.t(s.gx, CYB + 6.1)) and near(P(s.c, 1), s.t(s.gx, CYB + 4.35)), s.d
for s, ref, pin, pad, x in uart:
    row = YT if s.upper else YB
    assert abs(P(ref, 1)[1] - row) < abs(P(ref, 2)[1] - row), ref

# ---------------------------------------------------------------- UART fan-out
LEVEL0, LEVEL_PITCH = 5.2, 0.5                   # lane distance from the pin row


def fanout(row_y, sign, lines):
    """lines: (resistor x, resistor ref, pad position, net), any order. Lanes run in the channel
    on the top layer; a lane that starts under another one sits nearer the Timer."""
    lines = sorted(lines)
    dests = [l[2][0] for l in lines]
    assert dests == sorted(dests), dests                     # pins and pads in the same order
    level = {}
    for going_right in (True, False):
        mine = [l for l in lines if (l[2][0] > l[0]) == going_right]
        done = []
        for l in sorted(mine, reverse=going_right):          # outermost pin first
            x, dest = l[0], l[2][0]
            over = [level[o[1]] for o in done if (o[0] < dest + 0.6 if going_right else o[0] > dest - 0.6)]
            level[l[1]] = max(over) + 1 if over else 0
            done.append(l)
    for x, ref, dest, net in lines:
        y = row_y + sign * (LEVEL0 + LEVEL_PITCH * level[ref])
        b.track(net, F, SIG, P(ref, 2), (x, y), (dest[0], y), dest)
    return max(level.values()) + 1


for upper in ((True, False) if ROWS == 2 else (True,)):
    row_y, sign = (YT, -1) if upper else (YB, 1)
    lines = []
    for s, ref, pin, pad, x in uart:
        if s.upper != upper:
            continue
        lines.append((x, ref, P(s.ref, pad), b.net_of(ref, 2)))
        net = b.net_of(ref, 1)
        if x == pin_x(pin):
            b.track(net, F, SIG, P("U1", pin), P(ref, 1))
        else:                                                # from the far row, round the end of this one
            p, v = P("U1", pin), (x, row_y + sign * 1.4)
            b.track(net, B, SIG, p, (x, p[1] + sign * (p[0] - x)), v)
            b.via(net, *v)
            b.track(net, F, SIG, v, P(ref, 1))
    levels = fanout(row_y, sign, lines)
    assert LEVEL0 + LEVEL_PITCH * (levels - 1) <= CHANNEL - 0.9, levels

# ---------------------------------------------------------------- SYNC, EN, BOOT
# Verticals just left of the first column's plated holes; BOOT (nearest the Timer in both rows)
# is innermost, so the three nest without crossing.
VX = {"BOOT": CX0 - 2.9, "SYNC": CX0 - 3.6, "EN": CX0 - 4.3}
TRUNK = {"BOOT": YT + 5.4, "EN": YT + 6.2, "SYNC": YT + 7.0}     # top-layer lanes under the Timer
for i, (bus, _, pin, _, _) in enumerate(carrier.BUS):
    ref = carrier.bus_ref(N, i)
    b.track(b.net_of(ref, 1), F, SIG, P("U1", pin), P(ref, 1))
    r, x, y = P(ref, 2), VX[bus], TRUNK[bus]
    b.track(bus, F, SIG, r, (r[0], y), (x, y))
    b.via(bus, x, y)
    ends = [y]
    for upper in ((True, False) if ROWS == 2 else (True,)):
        pads = sorted(P(s.ref, BUS_PAD[bus]) for s in SLOTS if s.upper == upper)
        b.track(bus, B, SIG, (x, pads[0][1]), *pads)
        ends.append(pads[0][1])
    b.track(bus, B, SIG, (x, min(ends)), (x, max(ends)))

# ---------------------------------------------------------------- power and ground
RAIL = 11.0                                       # VSYS rail, from the XIAO centre line outwards
vsys = P("U1", 31)
rail_y = {True: 2 * YC - (CYB + RAIL), False: CYB + RAIL}
rows = (True, False) if ROWS == 2 else (True,)
if N == 8:                                        # spine right of the Timer, under the last column
    SPINE_X = 86.5
    b.track("VSYS", B, 0.8, vsys, (vsys[0], YB - 1.9), (SPINE_X, YB - 1.9))
    for upper in rows:
        b.track("VSYS", B, 1.0, (SPINE_X, YB - 1.9), (SPINE_X, rail_y[upper]))
else:                                             # spine through the gaps between the Timer's pins
    SPINE_X = vsys[0] - parts.RP_PITCH / 2
    b.track("VSYS", B, 0.4, vsys, (SPINE_X, YB - parts.RP_PITCH / 2))
    for upper in rows:
        row_y, out = (YT, -1) if upper else (YB, 1)
        b.track("VSYS", B, 0.4, (SPINE_X, YB - parts.RP_PITCH / 2), (SPINE_X, row_y + out * 2.0))
        b.track("VSYS", B, 1.0, (SPINE_X, row_y + out * 2.0), (SPINE_X, rail_y[upper]))
for upper in rows:
    xs = [s.t(s.gx, 0)[0] for s in SLOTS if s.upper == upper] + [SPINE_X]
    b.track("VSYS", B, 1.0, (min(xs), rail_y[upper]), (max(xs), rail_y[upper]))
for s in SLOTS:
    v = s.t(s.gx, CYB + RAIL)
    b.via("VSYS", *v)
    b.track("VSYS", F, PWR, v, P(s.d, 2))
    b.track("NODE%d_5V" % s.n, F, PWR, P(s.c, 1), P(s.d, 1), s.t(s.gx + 1.52, CYB + 7.62), P(s.ref, 14))
    # XIAO GND pad -> capacitor GND pad -> via into the bottom pour
    g = s.t(s.gx, CYB - 1.2)
    b.track("GND", F, SIG, P(s.ref, 13), s.t(s.gx + 1.15, CYB + 5.08), s.t(s.gx + 1.15, CYB + 2.85),
            s.t(s.gx + 0.75, CYB + 2.45), P(s.c, 2))
    b.track("GND", F, PWR, P(s.c, 2), g)
    b.via("GND", *g)
    b.solid(s.ref, 13)
for x, y in ((30.0, YC + 3.0), (50.0, YC + 3.0), (30.0, YC - 4.5)):
    b.via("GND", x, y)

# ---------------------------------------------------------------- outline, zones, keepouts
b.outline(W, H, RADIUS)
b.pour(F, 0, 0, W, H, "GND", "GND top")
b.pour(B, 0, 0, W, H, "GND", "GND bottom")
kx0, ky0, kx1, ky1 = parts.XIAO_KEEPOUT
for s in SLOTS:
    (x0, y0), (x1, y1) = s.t(s.cx + kx0, CYB + ky0), s.t(s.cx + kx1, CYB + ky1)
    b.keepout_rect([F], min(x0, x1), min(y0, y1), max(x0, x1), max(y0, y1), "XIAO %d underside pads: no top copper" % s.n)
# The scripted zone filler does not apply the board's hole clearance to NPTH holes, so give
# each mounting hole (and its screw head) an explicit copper-free ring.
for i, (x, y) in enumerate(HOLES):
    b.keepout_circle([F, B], x, y, 2.9, "M2.5 screw head %d" % (i + 1))

# ---------------------------------------------------------------- silkscreen and documentation
b.text("RP2350-POE-ETH", 34.0, YC + 6.0, size=1.2)
b.text("RJ45", 13.0, YC + 6.0, size=1.0)
b.text("USB", 56.0, YC + 3.0, size=1.0)
b.text("1", RP_PIN1[0] + 2.6, YT + 2.2, size=1.0)
b.text("32", RP_PIN1[0] + 2.6, YB - 2.2, size=1.0)
for s in SLOTS:
    tx, _, rx, _ = carrier.MAP[N][s.n]
    b.text("NODE %d" % s.n, *s.t(s.cx, CYB - 6.6), size=1.2)
    b.text("%s/%s" % (tx, rx[2:]), *s.t(s.cx, CYB - 4.4), size=1.0)
    b.text("ANT", *s.t(s.cx, CYB - 9.0), size=1.0)
    b.text("USB", *s.t(s.cx, CYB + 9.1), size=1.0)
    b.text("%d" % s.n, *s.t(s.cx - 4.5, CYB - 4.5), layer=BSILK, size=2.0, thick=0.3)
    for pad, name in ((17, "EN"), (19, "SYNC"), (21, "BOOT")):
        x, y = P(s.ref, pad)
        b.text(name, x + 3.0, y - 1.25, BSILK, size=0.8)
    b.text("solder EN SYNC", *s.t(s.cx, CYB - 8.4), layer=BSILK, size=0.8)
    b.text("BOOT this side", *s.t(s.cx, CYB - 7.2), layer=BSILK, size=0.8)
b.text("Open FPV Timer", 40.0, YC - 1.5, BSILK, size=1.5, thick=0.25)
b.text("carrier %d v0.1 draft" % N, 40.0, YC + 1.0, BSILK, size=1.0)

# Where the RJ45 and a USB-C plug overhang, for the case design.
b.rect(DOC, parts.RP_L, YC - 4.5, parts.RP_L + 2.0, YC + 4.5, 0.1)
b.rect(DOC, -2.88, YC - 8.05, 0, YC + 7.95, 0.1)

b.save()
