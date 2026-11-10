#!/usr/bin/env python3
"""Generate the 1-Node stick, carrier-1/oft-carrier-1.kicad_pcb, from the schematic netlist.

Run through tools/kicad.sh gen/build.sh N. Placement and routing are written out by hand
below; this bootstraps the first draft. Once a board is edited in KiCad, stop regenerating it.

Board coordinates are millimetres from the top-left corner. The Timer module lies along the
board with its RJ45 at the left end; the Node slots follow to the right on a 22 mm pitch, each
with its USB-C at the bottom edge and its antenna connector at the top edge.

Routing plan. Every slot repeats one cell. The narrow column left of each XIAO holds, top to
bottom: two UART vias, a GND via, the slot's 10 uF capacitor and its diode. UART lanes run
under the XIAOs near the top edge and peel off upwards one slot at a time; three bus lines
(BOOT, SYNC, EN) run straight through the plated holes of every slot on the bottom layer; VSYS
runs along the bottom edge.

The code is written for a row of N slots; only N = 1 is built. grid_pcb.py makes the 2, 4 and
8-Node boards.
"""
import os
import sys

import carrier
import parts
from pcb import Board, F, B, SILK, BSILK, DOC, SIG, PWR

N = int(sys.argv[1])
assert N == 1, N
NAME = carrier.name(N)
HERE = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "carrier-%d" % N))
H, RADIUS = 25.0, 2.0
CY = H / 2
RP_PIN1 = (parts.RP_L - parts.RP_PIN1_FROM_USB_END, CY - parts.RP_ROWS / 2)        # (61.65, 3.61)
GAP = 6.0                                    # clear strip between the Timer and the Node, for a shield wall
CX = [parts.RP_L + GAP + parts.XIAO_W / 2 + carrier.PITCH * i for i in range(N)]  # XIAO centres
GX = [cx - carrier.PITCH / 2 for cx in CX]                                        # column left of each XIAO
W = CX[-1] + parts.XIAO_W / 2 + 9.2
HOLES = [(4.0, 4.5), (4.0, H - 4.5), (W - 3.5, 4.5), (W - 3.5, H - 4.5)]
S = "" if N == 1 else "s"

b = Board(os.path.join(HERE, NAME + ".kicad_pcb"), sys.argv[2], "OFT carrier, %d Node%s" % (N, S),
          "0.1 draft", "2026-11-10")


def pin_x(pin):
    return RP_PIN1[0] - ((pin - 1) if pin <= 16 else (32 - pin)) * parts.RP_PITCH


# Link resistors sit just inside the pin rows, each next to the Timer pin it serves.
RES = {}                                                # ref: Timer module pin
for n in range(1, N + 1):
    _, tx, _, rx = carrier.MAP[N][n]
    RES[carrier.res_ref(n, False)] = tx
    RES[carrier.res_ref(n, True)] = rx
for i, (_, _, pin, _, _) in enumerate(carrier.BUS):
    RES[carrier.bus_ref(N, i)] = pin
TOP_Y, BOT_Y = 6.8, 18.2
PLACE = {"U1": RP_PIN1 + (270,)}                        # USB-C end towards +X
for ref, pin in RES.items():
    PLACE[ref] = (pin_x(pin), TOP_Y, 270) if pin <= 16 else (pin_x(pin), BOT_Y, 90)    # pad 1 towards its pin
for i in range(N):
    PLACE["U%d" % (i + 2)] = (CX[i], CY, 180)          # USB-C end towards the bottom edge
    PLACE["D%d" % (i + 1)] = (GX[i], 20.25, 270)       # cathode up, anode down
    PLACE["C%d" % (i + 1)] = (GX[i], 15.9, 90)         # pad 1 (5 V) down
for i, (x, y) in enumerate(HOLES):
    PLACE["H%d" % (i + 1)] = (x, y, 0)
b.place_all(PLACE)
P = b.P

# The layout below depends on these; fail loudly if a footprint or rotation changes.
near = lambda p, q: abs(p[0] - q[0]) < 1e-3 and abs(p[1] - q[1]) < 1e-3
assert near(P("U1", 16), (23.55, 3.61)) and near(P("U1", 32), (61.65, 21.39)), P("U1", 32)
for i in range(N):
    assert P("D%d" % (i + 1), 1)[1] < P("D%d" % (i + 1), 2)[1] and P("C%d" % (i + 1), 1)[1] > P("C%d" % (i + 1), 2)[1]
    assert P("U%d" % (i + 2), 14)[1] > CY and P("U%d" % (i + 2), 14)[0] < CX[i]     # 5V pad bottom-left
for ref, pin in RES.items():
    assert near(P(ref, 1), (pin_x(pin), P(ref, 1)[1])) and abs(P(ref, 1)[1] - P("U1", pin)[1]) < abs(P(ref, 2)[1] - P("U1", pin)[1]), ref

# ---------------------------------------------------------------- routing
for ref, pin in RES.items():
    b.track(b.net_of(ref, 1), F, SIG, P("U1", pin), P(ref, 1))

# UART lanes. Lane k serves slot k // 2: even lanes are Timer TX -> Node D7 and leave just left
# of their XIAO, odd lanes are Node D6 -> Timer RX and leave just right of it. The topmost lane
# always leaves first, so nothing crosses.
LANE_W, LANE_PITCH = 0.15, 0.6
BAND = 5.7                                              # top lane under the XIAOs
VIA_Y = P("U2", 8)[1]                                   # UART vias sit level with the D7/D6 pads


def leave(layer, net, k, slot, last):
    """From `last` on the lane, along it to the slot's via column, up, and across to the pad."""
    y = BAND + LANE_PITCH * (k % 8)
    rx_lane = k % 2 == 0
    xr = GX[slot] + 0.7 if rx_lane else (GX[slot + 1] - 0.7 if slot + 1 < N else CX[slot] + 10.3)
    b.track(net, layer, LANE_W, last, (xr - 0.5, y), (xr, y - 0.5), (xr, VIA_Y))
    b.via(net, xr, VIA_Y)
    b.track(net, F, SIG, (xr, VIA_Y), P("U%d" % (slot + 2), 8 if rx_lane else 7))


# Each lane starts on the bottom layer at a via below its resistor, then all of them
# step up together before the first XIAO.
START, JOG_X = 8.6, 62.5
STEP = START - BAND
for k in range(2 * N):
    slot = k // 2
    ref = carrier.res_ref(slot + 1, k % 2 == 1)
    net, r = b.net_of(ref, 2), P(ref, 2)
    ym = START + LANE_PITCH * k
    b.track(net, F, SIG, r, (r[0], ym))
    b.via(net, r[0], ym)
    b.track(net, B, LANE_W, (r[0], ym), (JOG_X, ym), (JOG_X + STEP, ym - STEP))
    leave(B, net, k, slot, (JOG_X + STEP, ym - STEP))

# SYNC, EN, BOOT: down the top layer from each resistor to the height of the XIAO underside
# pad, then one straight bottom-layer line through that pad on every slot.
for i, pad in enumerate((19, 17, 21)):
    ref = carrier.bus_ref(N, i)
    net, r = b.net_of(ref, 2), P(ref, 2)
    y = P("U2", pad)[1]
    b.track(net, F, SIG, r, (r[0], y))
    b.via(net, r[0], y)
    b.track(net, B, SIG, (r[0], y), *[P("U%d" % (j + 2), pad) for j in range(N)])

# Power. VSYS runs along the bottom edge on the bottom layer and comes up below each diode.
vsys = P("U1", 31)
VY = 23.5
b.track("VSYS", B, 1.0, vsys, (vsys[0], VY - 1.11), (vsys[0] + 1.11, VY), (GX[-1], VY))
SPINE_Y = 11.3                                          # GND strip between the lanes and the BOOT holes
for i in range(N):
    n, gx = i + 1, GX[i]
    a, k, c5, cg = P("D%d" % n, 2), P("D%d" % n, 1), P("C%d" % n, 1), P("C%d" % n, 2)
    v5, xg = P("U%d" % (i + 2), 14), P("U%d" % (i + 2), 13)
    b.via("VSYS", gx, VY)
    b.track("VSYS", F, PWR, (gx, VY), a)
    b.track("NODE%d_5V" % n, F, PWR, c5, k, (v5[0] - (v5[1] - k[1]), v5[1]), v5)
    # XIAO GND pad -> capacitor GND pad -> via down to the ground strip (or plane)
    b.track("GND", F, SIG, xg, (gx + 1.15, xg[1]), (gx + 1.15, cg[1] + 0.4), (gx + 0.75, cg[1]), cg)
    b.track("GND", F, PWR, cg, (gx, SPINE_Y))
    b.via("GND", gx, SPINE_Y)
    b.solid("U%d" % (i + 2), 13)
STITCH = [(10.0, 12.5), (18.0, 2.5), (18.0, 22.5), (30.0, 6.5), (W - 6.0, 12.5), (W - 8.5, 2.0), (W - 8.5, 21.5)]
STITCH += [(53.0, 15.0), (50.0, 19.5), (30.0, 21.0)]
for x, y in STITCH:
    b.via("GND", x, y)

# ---------------------------------------------------------------- outline, zones, keepouts
b.outline(W, H, RADIUS)
b.pour(F, 0, 0, W, H, "GND", "GND top")
b.pour(B, 0, 0, W, H, "GND", "GND bottom")
kx0, ky0, kx1, ky1 = parts.XIAO_KEEPOUT
for i in range(N):
    b.keepout_rect([F], CX[i] + kx0, CY + ky0, CX[i] + kx1, CY + ky1, "XIAO %d underside pads: no top copper" % (i + 1))
# The scripted zone filler does not apply the board's hole clearance to NPTH holes, so give
# each mounting hole (and its screw head) an explicit copper-free ring.
for i, (x, y) in enumerate(HOLES):
    b.keepout_circle([F, B], x, y, 2.9, "M2.5 screw head %d" % (i + 1))

# ---------------------------------------------------------------- silkscreen and documentation
b.text("RP2350-POE-ETH", 14.0, 12.5, size=1.2, angle=90)
b.text("RJ45 end", 9.0, 12.5, size=1.0, angle=90)
b.text("USB end", 57.5, 13.5, size=1.0)
b.text("1", RP_PIN1[0] + 3.3, RP_PIN1[1], size=1.0)
b.text("32", RP_PIN1[0] + 3.3, RP_PIN1[1] + parts.RP_ROWS, size=1.0)
for i in range(N):
    tx, _, rx, _ = carrier.MAP[N][i + 1]
    b.text("NODE %d" % (i + 1), CX[i], 7.0, size=1.2)
    b.text("%s/%s" % (tx, rx[2:]), CX[i], 9.2, size=1.0)
    b.text("ANT", CX[i], 3.6, size=1.0)
    b.text("USB", CX[i], 21.6, size=1.0)
    b.text("%d" % (i + 1), CX[i] - 4.5, 15.5, BSILK, size=2.0, thick=0.3)
    for pad, name in ((17, "EN"), (19, "SYNC"), (21, "BOOT")):
        x, y = P("U%d" % (i + 2), pad)
        b.text(name, x + 3.0, y - 1.25, BSILK, size=0.8)
    b.text("solder EN SYNC", CX[i] + 1.0, 20.9, BSILK, size=0.8)
    b.text("BOOT this side", CX[i] + 1.0, 22.1, BSILK, size=0.8)
b.text("Open FPV Timer", 12.0, 12.5, BSILK, size=1.5, thick=0.25, angle=90)
b.text("carrier %d v0.1 draft" % N, 15.0, 12.5, BSILK, size=1.0, angle=90)

# Where the RJ45 and a USB-C plug overhang, for the case design.
b.rect(DOC, parts.RP_L, CY - 4.5, parts.RP_L + 2.0, CY + 4.5, 0.1)
b.rect(DOC, -2.88, CY - 8.05, 0, CY + 7.95, 0.1)

b.save()
