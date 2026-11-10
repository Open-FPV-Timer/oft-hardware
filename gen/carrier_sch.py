#!/usr/bin/env python3
"""Generate carrier-N/oft-carrier-N.kicad_sch: one RP2350-POE-ETH Timer and N XIAO ESP32-C5 Nodes.

Run through tools/kicad.sh gen/build.sh N. This bootstraps the first draft; once a schematic
is edited by hand in KiCad, stop regenerating it.
"""
import os
import sys

import carrier
import parts
from sch import Sheet, C0805

N = int(sys.argv[1])
assert N in carrier.SIZES, N
HERE = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "carrier-%d" % N))
s = Sheet(carrier.name(N), HERE, "0f7b1ca2-41d5-4b5e-9a57-b1c0de0001%02d" % N)
SLOTS = range(1, N + 1)

RP_NETS = {"VSYS": "VSYS", "GND": "GND", "AGND": "GND"}
for n in SLOTS:
    tx, _, rx, _ = carrier.MAP[N][n]
    RP_NETS[tx] = "T_TX%d" % n
    RP_NETS[rx] = "T_RX%d" % n
for net, gp, _, _, _ in carrier.BUS:
    RP_NETS[gp] = "T_" + net

# ================================================================ Timer module
s.text("TIMER: Waveshare RP2350-POE-ETH (socketed, two 1x16 female sockets)", 14, 14, 1.6)
s.text("W6300 Ethernet uses GP16 to GP21 on the module itself. PoE module plugs on top.\n"
       "%s. All links 921600 baud.\n"
       "UART1 (GP4/GP5) is the pair the single-Node firmware uses.\n"
       "GP6 = SYNC, GP7 = EN, GP8 = BOOT, shared by every slot."
       % ", ".join("slot %d = %s" % (n, carrier.uart(N, n)) for n in SLOTS), 14, 17)
s.module_symbol("RP2350-POE-ETH",
                [(i + 1, n) for i, n in enumerate(parts.RP_LEFT)],
                [(32 - i, n) for i, n in enumerate(parts.RP_RIGHT)],
                "oft:" + parts.RP_FP, "Waveshare RP2350-POE-ETH: RP2350A, W6300 Ethernet, PoE module header")
s.place("oft:RP2350-POE-ETH", "U1", "RP2350-POE-ETH", 50, 50, footprint="oft:" + parts.RP_FP,
        ref_at=(-9, -19), val_at=(-9, 19), fields={"MPN": "Waveshare RP2350-POE-ETH"})
for num, pname in parts.RP_PINS.items():
    s.stub("U1", num, RP_NETS.get(pname))
s.flag_stub("U1", 31, 6, 18)                   # VSYS and GND are driven by the module
s.flag_stub("U1", 30, 10, 22)

# ================================================================ series resistors
s.text("LINK RESISTORS", 100, 14, 1.6)
s.text("220R on each data line limits the current when one board is powered and\n"
       "the other is not. SYNC, EN and BOOT are single lines bussed to every\n"
       "slot, so a reset or boot button on any XIAO acts on all of them.", 100, 17)
row = 0
for n in SLOTS:
    for rx, a, b_ in ((False, "T_TX%d" % n, "NODE%d_RX" % n), (True, "T_RX%d" % n, "NODE%d_TX" % n)):
        s.series(carrier.res_ref(n, rx), "220R", 122, 30 + 8 * row, a, b_, fields={"LCSC": "C22962"})
        row += 1
for i, (net, _, _, val, lcsc) in enumerate(carrier.BUS):
    s.series(carrier.bus_ref(N, i), val, 122, 36 + 8 * (row + i), "T_" + net, net, fields={"LCSC": lcsc})
res_bottom = 36 + 8 * (row + 3)

# ================================================================ Node modules
s.text("NODES: Seeed XIAO ESP32-C5 (soldered flat). Leave unused slots empty.", 170, 14, 1.6)
s.text("Edge pads are hand-soldered castellations. EN, MTMS and BOOT are pads on the underside:\n"
       "each lands on a plated hole, soldered from the back of the carrier.\n"
       "D6/D7 = UART0 TX/RX (GPIO11/12). MTMS = GPIO2 = OFT_SYNC_GPIO default.", 170, 17)
s.module_symbol("XIAO-ESP32-C5",
                [(i + 1, n) for i, n in enumerate(parts.XIAO_LEFT)] + [(17, "EN"), (19, "MTMS"), (21, "BOOT")],
                [(14 - i, n) for i, n in enumerate(parts.XIAO_RIGHT)],
                "oft:" + parts.XIAO_FP, "Seeed XIAO ESP32-C5, castellated, underside EN/MTMS/BOOT pads", half_width=7)
COLS = 4 if N > 4 else 2
for n in SLOTS:
    ref = "U%d" % (n + 1)
    x, y = 200 + 60 * ((n - 1) % COLS), 44 + 44 * ((n - 1) // COLS)
    nets = {"5V": "NODE%d_5V" % n, "GND": "GND", "D7": "NODE%d_RX" % n, "D6": "NODE%d_TX" % n,
            "MTMS": "SYNC", "EN": "EN", "BOOT": "BOOT"}
    s.place("oft:XIAO-ESP32-C5", ref, "XIAO ESP32-C5 slot %d" % n, x, y, footprint="oft:" + parts.XIAO_FP,
            ref_at=(-7, -13), val_at=(-7, 13), fields={"MPN": "Seeed 100010048"})
    for num, pname in parts.XIAO_PINS.items():
        s.stub(ref, num, nets.get(pname))

# ================================================================ node power
py = max(150, res_bottom + 28)
px = 20 if N > 4 else 100
s.text("NODE POWER", px, py - 18, 1.6)
s.text("Each XIAO runs from VSYS (USB or PoE, about 4.7 V) through its own diode, so a laptop on one XIAO's\n"
       "USB-C powers only that XIAO. Measure the Node current against the PoE module's 5 V rating.", px, py - 15)
for n in SLOTS:
    x0 = px + 50 * (n - 1)
    s.place("Device:D_Schottky", "D%d" % n, "B5819W", x0 + 12, py, 180, footprint="Diode_SMD:D_SOD-123",
            ref_at=(0, -4), val_at=(0, -2.5), fields={"LCSC": "C8598", "MPN": "B5819W"}, just="")
    a, k = s.pin("D%d" % n, 2), s.pin("D%d" % n, 1)
    assert a[0] < k[0], (a, k)
    s.wire((a[0] - 4, py), a)
    s.label("VSYS", a[0] - 4, py, left=True)
    s.wire(k, (x0 + 22, py), (x0 + 28, py))            # broken at the junction
    s.label("NODE%d_5V" % n, x0 + 28, py)
    s.shunt("C%d" % n, "10uF", x0 + 22, py, C0805, {"LCSC": "C15850"})

# ================================================================ mechanical
for i in range(carrier.HOLES[N]):
    s.place("Mechanical:MountingHole", "H%d" % (i + 1), "M2.5", 20 + 14 * i, 100,
            footprint="MountingHole:MountingHole_2.7mm_M2.5", ref_at=(3, -1), val_at=(3, 1), bom=False)

s.text("DRAFT v0.1. Generated by gen/carrier_sch.py %d. The UART1 slot matches oft-timer-rp2350/src/board.rs;\n"
       "the other slots are a proposal (the Timer firmware drives one Node today).\n"
       "U1 goes on two hand-soldered 1x16 sockets, the XIAOs are hand-soldered;\n"
       "R, C and D are fab-assembled SMD, top side." % N, 14, 116)

s.save("OFT carrier, %d Node%s" % (N, "" if N == 1 else "s"), "0.1 draft", "2026-11-10",
       "RP2350-POE-ETH Timer + %d XIAO ESP32-C5 Node%s" % (N, "" if N == 1 else "s"), paper="A2" if N > 4 else "A3")
