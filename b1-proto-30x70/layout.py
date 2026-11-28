#!/usr/bin/env python3
"""Draw layout-top.svg: the one-Node Timer on a 24 x 10 hole, 70 x 30 mm protoboard.

Run it here: `python3 layout.py`. Everything is placed from the numbers below, which are the
same ones the README's tables use, so the drawing and the tables cannot drift apart.
"""
PITCH_MM = 2.54
S = 26 / PITCH_MM                      # pixels per millimetre: 26 px between holes
COLS, ROWS = 24, 10                    # letters A..X along the board, numbers 1..10 across it
BOARD_L, BOARD_W = 70.0, 30.0
MX, MY = (BOARD_L - (COLS - 1) * PITCH_MM) / 2, (BOARD_W - (ROWS - 1) * PITCH_MM) / 2
OX, OY = 300, 70                       # pixel position of the board's top-left corner

# Timer (Waveshare RP2350-POE-ETH), on top: 16 pins a row, B to Q.
TIMER_FIRST = 1                        # column index of B
TIMER_ROW_A, TIMER_ROW_B = 9, 2        # the GP12..GP0 row and the GP13..VBUS row
ROW9 = ["GP12", "GP11", "GP10", "GND", "GP9", "GP8", "GP7", "GP6", "GND", "GP5", "GP4", "GP3", "GP2", "GND", "GP1", "GP0"]
ROW2 = ["GP13", "GP14", "GP15", "GND", "GP22", "RUN", "GP26", "GP27", "AGND", "GP28", "VREF", "3V3", "3V3_EN", "GND", "VSYS", "VBUS"]
TIMER_L, TIMER_W, TIMER_USB_END = 63.0, 21.0, 1.35   # PCB size; last pin to the USB-C end

# Node (Seeed XIAO ESP32-C5), underneath: 7 pins a row, R to X, USB-C at the X end.
C5_FIRST = 17                          # column index of R
C5_ROW_A, C5_ROW_B = 8, 2
C5_ROW8 = ["D7", "D8", "D9", "D10", "3V3", "GND", "5V"]
C5_ROW2 = ["D6", "D5", "D4", "D3", "D2", "D1", "D0"]
C5_L, C5_W = 21.0, 17.8

# The five connections: (name, colour, Timer pin, Node pin).
WIRES = [("5 V", "#d1343f", "VSYS", "5V"), ("Ground", "#30363a", "GND@O9", "GND"),
         ("Timer TX to Node RX", "#d9790b", "GP4", "D7"), ("Node TX to Timer RX", "#1b9654", "GP5", "D6"),
         ("SYNC", "#8a4fe0", "GP6", "D8")]


def col(i):
    return chr(ord("A") + i)


def xy(c, r):
    """Pixel centre of hole (column index c, row number r). Row 10 is at the top."""
    return OX + (MX + c * PITCH_MM) * S, OY + (MY + (ROWS - r) * PITCH_MM) * S


def hole(name):
    """'P2' -> pixel centre."""
    return xy(ord(name[0]) - ord("A"), int(name[1:]))


PINS = {}                              # pin name -> hole name
for i, n in enumerate(ROW9):
    PINS.setdefault(n, col(TIMER_FIRST + i) + str(TIMER_ROW_A))
for i, n in enumerate(ROW2):
    PINS.setdefault(n, col(TIMER_FIRST + i) + str(TIMER_ROW_B))
PINS["GND@O9"] = "O9"
NODE = {n: col(C5_FIRST + i) + str(C5_ROW_A) for i, n in enumerate(C5_ROW8)}
NODE.update({n: col(C5_FIRST + i) + str(C5_ROW_B) for i, n in enumerate(C5_ROW2)})

if __name__ == "__main__":
    W, H = OX + BOARD_L * S + 60, OY + BOARD_W * S + 150
    o = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" font-family="Helvetica, Arial, sans-serif">' % (W, H),
         '<rect width="100%%" height="100%%" fill="#ffffff"/>']
    # board, with its corner mounting holes (positions indicative)
    o.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="6" fill="#dfe9e2" stroke="#9fb3a7" stroke-width="1.5"/>' % (OX, OY, BOARD_L * S, BOARD_W * S))
    for mx in (2.5, BOARD_L - 2.5):
        for my in (2.5, BOARD_W - 2.5):
            o.append('<circle cx="%.1f" cy="%.1f" r="%.1f" fill="#ffffff" stroke="#6f8278" stroke-width="1.2"/>' % (OX + mx * S, OY + my * S, 1.1 * S))
    for c in range(COLS):
        x, _ = xy(c, 1)
        o.append('<text x="%.1f" y="%.1f" font-size="12" text-anchor="middle" fill="#4f5f58">%s</text>' % (x, OY - 10, col(c)))
    for r in range(1, ROWS + 1):
        _, y = xy(0, r)
        o.append('<text x="%.1f" y="%.1f" font-size="12" text-anchor="start" fill="#4f5f58">%02d</text>' % (OX + BOARD_L * S + 10, y + 4, r))
    for c in range(COLS):
        for r in range(1, ROWS + 1):
            x, y = xy(c, r)
            o.append('<circle cx="%.1f" cy="%.1f" r="2.6" fill="#ffffff" stroke="#9fb3a7"/>' % (x, y))
    # Timer outline (top side, solid)
    xq, _ = xy(TIMER_FIRST + 15, 1)
    x1 = xq + TIMER_USB_END * S
    x0 = x1 - TIMER_L * S
    yc = (xy(0, TIMER_ROW_A)[1] + xy(0, TIMER_ROW_B)[1]) / 2
    o.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="5" fill="#2f6fb3" fill-opacity="0.12" stroke="#2f6fb3" stroke-width="1.8"/>' % (x0, yc - TIMER_W * S / 2, TIMER_L * S, TIMER_W * S))
    o.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="3" fill="#8a949a" fill-opacity="0.35" stroke="#5c666c"/>' % (x0 - 2.88 * S, yc - 8 * S, 21 * S, 16 * S))
    o.append('<text x="%.1f" y="%.1f" font-size="13" font-weight="bold" text-anchor="middle" fill="#30363a">RJ45</text>' % (x0 + 7.6 * S, yc + 4))
    o.append('<text x="%.1f" y="%.1f" font-size="11" text-anchor="middle" fill="#30363a">hangs off the A end</text>' % (x0 + 7.6 * S, yc + 20))
    o.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="2" fill="#8a949a" fill-opacity="0.5" stroke="#5c666c"/>' % (x1 - 6.3 * S, yc - 4.5 * S, 7.3 * S, 9 * S))
    o.append('<text x="%.1f" y="%.1f" font-size="14" font-weight="bold" text-anchor="middle" fill="#1f4f85">RP2350-POE-ETH Timer, on top</text>' % ((xy(8, 1)[0] + xy(9, 1)[0]) / 2, yc - 6))
    o.append('<text x="%.1f" y="%.1f" font-size="11" text-anchor="middle" fill="#1f4f85">USB-C points at X</text>' % ((xy(8, 1)[0] + xy(9, 1)[0]) / 2, yc + 11))
    # Node outline (underside, dashed)
    xr, xx = xy(C5_FIRST, 1)[0], xy(C5_FIRST + 6, 1)[0]
    ycn = (xy(0, C5_ROW_A)[1] + xy(0, C5_ROW_B)[1]) / 2
    cx = (xr + xx) / 2
    o.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="6" fill="none" stroke="#3b4350" stroke-width="1.8" stroke-dasharray="7 4"/>' % (cx - C5_L * S / 2, ycn - C5_W * S / 2, C5_L * S, C5_W * S))
    o.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="2" fill="none" stroke="#3b4350" stroke-dasharray="4 3"/>' % (cx + C5_L * S / 2 - 5.8 * S, ycn - 4.5 * S, 7.3 * S, 9 * S))
    o.append('<text x="%.1f" y="%.1f" font-size="13" font-weight="bold" text-anchor="middle" fill="#3b4350">XIAO ESP32-C5</text>' % (cx - 8, ycn - 12))
    o.append('<text x="%.1f" y="%.1f" font-size="11" text-anchor="middle" fill="#3b4350">Node, underneath</text>' % (cx - 8, ycn + 3))
    o.append('<text x="%.1f" y="%.1f" font-size="11" text-anchor="middle" fill="#3b4350">USB-C off the X end</text>' % (cx - 8, ycn + 17))
    # connections: straight lines between the two holes. Not routes.
    for name, colour, tp, npin in WIRES:
        (ax, ay), (bx, by) = hole(PINS[tp]), hole(NODE[npin])
        o.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="%s" stroke-width="2.4" stroke-dasharray="2 5" stroke-linecap="round"/>' % (ax, ay, bx, by, colour))
    used = {PINS[w[2]]: w[1] for w in WIRES}
    used.update({NODE[w[3]]: w[1] for w in WIRES})
    # pins and their names
    def pin(h, label, above, square):
        x, y = hole(h)
        if h in used:
            o.append('<circle cx="%.1f" cy="%.1f" r="9.5" fill="none" stroke="%s" stroke-width="3"/>' % (x, y, used[h]))
        if square:
            o.append('<rect x="%.1f" y="%.1f" width="9" height="9" fill="#c49a2e" stroke="#30363a" stroke-width="0.8"/>' % (x - 4.5, y - 4.5))
        else:
            o.append('<circle cx="%.1f" cy="%.1f" r="4.8" fill="#c49a2e" stroke="#30363a" stroke-width="0.8"/>' % (x, y))
        ty = y - 14 if above else y + 14
        o.append('<text x="%.1f" y="%.1f" font-size="9" font-weight="%s" fill="#30363a" text-anchor="%s" transform="rotate(-90 %.1f %.1f)">%s</text>'
                 % (x + 3, ty, "bold" if h in used else "normal", "start" if above else "end", x + 3, ty, label.replace("GND@O9", "GND")))
    for i, n in enumerate(ROW9):
        pin(col(TIMER_FIRST + i) + str(TIMER_ROW_A), n, True, True)
    for i, n in enumerate(ROW2):
        pin(col(TIMER_FIRST + i) + str(TIMER_ROW_B), n, False, True)
    for i, n in enumerate(C5_ROW8):
        pin(col(C5_FIRST + i) + str(C5_ROW_A), n, True, False)
    for i, n in enumerate(C5_ROW2):
        pin(col(C5_FIRST + i) + str(C5_ROW_B), n, False, False)
    # legend
    ly = OY + BOARD_W * S + 62
    lx = OX - 270
    o.append('<text x="%d" y="%.1f" font-size="12" fill="#30363a">Seen from the top. Square pads: Timer pins, on top. Round pads: Node pins, underneath (dashed outline).</text>' % (lx, ly))
    o.append('<text x="%d" y="%.1f" font-size="12" fill="#30363a">A dotted line joins the two ends of each wire. It is not a route.</text>' % (lx, ly + 17))
    for k, (name, colour, tp, npin) in enumerate(WIRES):
        x, y = lx + (k % 3) * 340, ly + 44 + (k // 3) * 24
        o.append('<line x1="%d" y1="%.1f" x2="%d" y2="%.1f" stroke="%s" stroke-width="4" stroke-linecap="round"/>' % (x, y - 4, x + 26, y - 4, colour))
        o.append('<text x="%d" y="%.1f" font-size="12" fill="#30363a">%s: %s to %s</text>' % (x + 34, y, name, PINS[tp], NODE[npin]))
    o.append("</svg>")
    open("layout-top.svg", "w").write("\n".join(o) + "\n")
    print("wrote layout-top.svg")
    for name, colour, tp, npin in WIRES:
        print("%-22s Timer %-7s %-4s Node %-4s %s" % (name, tp.split("@")[0], PINS[tp], npin, NODE[npin]))
