#!/usr/bin/env python3
"""Write the shared module footprints (lib/oft.pretty) and their pin tables.

Two plug-in modules are used by every OFT carrier:

RP2350-POE-ETH (Waveshare). Numbers from Waveshare's dimension drawing: PCB 21 x 63 mm, two
rows of 16 pins on a 2.54 mm pitch, rows 17.78 mm apart, first pin 1.35 mm from the USB-C end
and 1.61 mm in from the long edge. Pin numbers from Waveshare's pinout drawing. The module
plugs into two 1x16 female sockets.

XIAO ESP32-C5 (Seeed). Pad positions from Seeed's own XIAO-ESP32-C5-SMD footprint
(github.com/Seeed-Studio/OSHW-XIAO-Series, MIT licence): 17.8 x 21 mm, 14 castellated edge
pads, and round pads on the underside. The module is soldered flat by its edge pads alone:
none of the underside pads is used, and they get no copper at all. (Any listed in
XIAO_BACK_USED would become a plated hole, soldered from the back of the carrier; EN, MTMS
and BOOT were, until SYNC moved to D8 and the Timer learned to restart a Node over its UART.)
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
LIB = os.path.normpath(os.path.join(HERE, "..", "lib"))
PRETTY = os.path.join(LIB, "oft.pretty")

# ---------------------------------------------------------------- RP2350-POE-ETH
RP_FP = "RP2350-POE-ETH_Socket"
RP_PITCH, RP_ROWS, RP_N = 2.54, 17.78, 16
RP_W, RP_L = 21.0, 63.0
RP_PIN1_FROM_USB_END = 1.35
RP_PIN1_FROM_EDGE = (RP_W - RP_ROWS) / 2            # 1.61
# Pin 1 is the origin, USB-C end up, seen from the component side: pins 1..16 run down the
# left row, pins 32..17 run down the right row.
RP_LEFT = ["GP0", "GP1", "GND", "GP2", "GP3", "GP4", "GP5", "GND", "GP6", "GP7", "GP8", "GP9", "GND",
           "GP10", "GP11", "GP12"]                                                      # pins 1..16
RP_RIGHT = ["VBUS", "VSYS", "GND", "3V3_EN", "3V3", "ADC_VREF", "GP28", "AGND", "GP27", "GP26", "RUN",
            "GP22", "GND", "GP15", "GP14", "GP13"]                                      # pins 32..17
RP_PINS = {str(i + 1): n for i, n in enumerate(RP_LEFT)}
RP_PINS.update({str(32 - i): n for i, n in enumerate(RP_RIGHT)})


def rp_pin_xy(num):
    """Footprint-local position of a module pin."""
    num = int(num)
    return (0.0, (num - 1) * RP_PITCH) if num <= 16 else (RP_ROWS, (32 - num) * RP_PITCH)


# ---------------------------------------------------------------- XIAO ESP32-C5
XIAO_FP = "XIAO-ESP32-C5_SMD"
XIAO_W, XIAO_L = 17.8, 21.0
# Origin at the body centre, USB-C end up, seen from the component side. Seeed's footprint has
# its origin at the bottom-left body corner, so x' = x - 8.9 and y' = y + 10.5.
XIAO_XL, XIAO_XR = 0.835 - 8.9, 17.0 - 8.9          # edge pad centres, left and right columns
XIAO_EDGE_PAD = (2.75, 2.0)
XIAO_LEFT = ["D0", "D1", "D2", "D3", "D4", "D5", "D6"]              # pads 1..7, top to bottom
XIAO_RIGHT = ["5V", "GND", "3V3", "D10", "D9", "D8", "D7"]          # pads 14..8, top to bottom
# Underside pads, Seeed pad number: (name, x, y). Left column is the D0 side.
XIAO_BACK = {
    "15": ("MTDI", 7.6166 - 8.9, -19.1415 + 10.5),
    "16": ("MTDO", 10.1566 - 8.9, -19.1415 + 10.5),
    "17": ("EN", 7.6166 - 8.9, -16.6015 + 10.5),
    "18": ("GND", 10.1566 - 8.9, -16.6015 + 10.5),
    "19": ("MTMS", 7.6166 - 8.9, -14.0615 + 10.5),
    "20": ("MTCK", 10.1566 - 8.9, -14.0615 + 10.5),
    "21": ("BOOT", 7.6166 - 8.9, -11.5215 + 10.5),
    "22": ("3V3", 10.064 - 8.9, -11.5783 + 10.5),
}
XIAO_BACK_USED = ()
XIAO_BACK_PAD, XIAO_BACK_DRILL = 1.7, 0.9
XIAO_PINS = {str(i + 1): n for i, n in enumerate(XIAO_LEFT)}
XIAO_PINS.update({str(14 - i): n for i, n in enumerate(XIAO_RIGHT)})
XIAO_PINS.update({k: XIAO_BACK[k][0] for k in XIAO_BACK_USED})
# No carrier copper on the top layer under the module body: its other underside pads (3V3,
# GND, JTAG, BAT, thermal) would sit on it with only solder mask in between.
XIAO_KEEPOUT = (-6.3, -10.3, 6.3, 10.3)


def xiao_pad_xy(num):
    n = int(num)
    if n <= 7:
        return (XIAO_XL, (n - 4) * 2.54)
    if n <= 14:
        return (XIAO_XR, (11 - n) * 2.54)
    return XIAO_BACK[str(n)][1:]


# ---------------------------------------------------------------- writer
ST = '(stroke (width %s) (type solid))'


def _head(name, descr, attr):
    return ('(footprint "%s"\n\t(version 20241229)\n\t(generator "pcbnew")\n\t(generator_version "9.0")\n'
            '\t(layer "F.Cu")\n\t(descr "%s")\n\t(attr %s)\n' % (name, descr, attr))


def _prop(key, value, x, y, layer, size=1.0):
    return ('\t(property "%s" "%s" (at %.3f %.3f 0) (layer "%s") (effects (font (size %s %s) (thickness %.2f))))\n'
            % (key, value, x, y, layer, size, size, size * 0.15))


def _rect(x0, y0, x1, y1, layer, width):
    return '\t(fp_rect (start %.3f %.3f) (end %.3f %.3f) %s (fill no) (layer "%s"))\n' % (
        x0, y0, x1, y1, ST % width, layer)


def _line(x0, y0, x1, y1, layer, width):
    return '\t(fp_line (start %.3f %.3f) (end %.3f %.3f) %s (layer "%s"))\n' % (x0, y0, x1, y1, ST % width, layer)


def _text(s, x, y, layer, size=1.0, angle=0):
    return ('\t(fp_text user "%s" (at %.3f %.3f %d) (layer "%s") (effects (font (size %s %s) (thickness %.2f))))\n'
            % (s, x, y, angle, layer, size, size, size * 0.15))


def write_rp():
    x0, y0 = -RP_PIN1_FROM_EDGE, -RP_PIN1_FROM_USB_END
    x1, y1 = x0 + RP_W, y0 + RP_L
    last = (RP_N - 1) * RP_PITCH
    s = _head(RP_FP, "Waveshare RP2350-POE-ETH on two 1x16 2.54 mm female sockets, rows 17.78 mm apart. "
                     "Origin at pin 1, USB-C end towards -Y, RJ45 end towards +Y.", "through_hole")
    s += _prop("Reference", "REF**", RP_ROWS / 2, -3.0, "F.SilkS")
    s += _prop("Value", RP_FP, RP_ROWS / 2, last / 2, "F.Fab")
    for cx in (0.0, RP_ROWS):
        s += _rect(cx - 1.33, -1.33, cx + 1.33, last + 1.33, "F.SilkS", "0.12")
        s += _rect(cx - 1.52, -1.52, cx + 1.52, last + 1.52, "F.CrtYd", "0.05")
        s += _rect(cx - 1.27, -1.27, cx + 1.27, last + 1.27, "F.Fab", "0.1")
    s += _line(-1.33, -1.75, 1.33, -1.75, "F.SilkS", "0.2")                 # pin 1 bar
    # module outline, USB-C and RJ45 bodies
    s += _rect(x0, y0, x1, y1, "F.Fab", "0.1")
    s += _rect(RP_ROWS / 2 - 4.475, y0 - 1.0, RP_ROWS / 2 + 4.475, y0 + 6.3, "F.Fab", "0.1")
    s += _rect(x0 + 2.45, y1 - 20.75, x1 - 2.55, y1 + 2.88, "F.Fab", "0.1")
    s += _text("USB-C", RP_ROWS / 2, y0 + 3.0, "F.Fab", 0.8)
    s += _text("RJ45", RP_ROWS / 2, y1 - 9.0, "F.Fab", 1.0)
    for num in sorted(RP_PINS, key=int):
        x, y = rp_pin_xy(num)
        shape = "rect" if num == "1" else "circle"
        s += ('\t(pad "%s" thru_hole %s (at %.3f %.3f) (size 1.7 1.7) (drill 1.0) (layers "*.Cu" "*.Mask"))\n'
              % (num, shape, x, y))
    s += "\t(embedded_fonts no)\n)\n"
    open(os.path.join(PRETTY, RP_FP + ".kicad_mod"), "w").write(s)


def write_xiao():
    hw, hl = XIAO_W / 2, XIAO_L / 2
    s = _head(XIAO_FP, "Seeed XIAO ESP32-C5 soldered flat by its castellated edges. No underside pad "
                       "is used. "
                       "Origin at the body centre, USB-C end towards -Y. Pad positions from Seeed's "
                       "XIAO-ESP32-C5-SMD footprint.", "smd")
    s += _prop("Reference", "REF**", 0, -hl - 1.2, "F.SilkS")
    s += _prop("Value", XIAO_FP, 0, 6.5, "F.Fab", 0.8)
    s += _rect(-hw, -hl, hw, hl, "F.Fab", "0.1")
    s += _rect(-hw - 0.75, -hl - 0.25, hw + 0.75, hl + 0.25, "F.CrtYd", "0.05")
    s += _rect(-4.5, -hl - 1.5, 4.5, -hl + 5.8, "F.Fab", "0.1")
    s += _text("USB-C", 0, -hl + 2.2, "F.Fab", 0.8)
    s += _text("u.FL", 0, hl - 1.5, "F.Fab", 0.8)
    for y in (-hl - 0.12, hl + 0.12):                                       # silk across both ends
        s += _line(-hw, y, hw, y, "F.SilkS", "0.12")
    s += _line(-hw - 0.9, -hl - 0.12, -hw - 0.9, -7.62, "F.SilkS", "0.2")   # pin 1 (D0) mark
    for num in [str(n) for n in range(1, 15)]:
        x, y = xiao_pad_xy(num)
        s += ('\t(pad "%s" smd roundrect (at %.4f %.4f) (size %s %s) (layers "F.Cu" "F.Mask" "F.Paste") '
              '(roundrect_rratio 0.25))\n' % ((num, x, y) + XIAO_EDGE_PAD))
    for num in XIAO_BACK_USED:
        x, y = xiao_pad_xy(num)
        s += ('\t(pad "%s" thru_hole circle (at %.4f %.4f) (size %s %s) (drill %s) (layers "*.Cu" "*.Mask"))\n'
              % (num, x, y, XIAO_BACK_PAD, XIAO_BACK_PAD, XIAO_BACK_DRILL))
    s += "\t(embedded_fonts no)\n)\n"
    open(os.path.join(PRETTY, XIAO_FP + ".kicad_mod"), "w").write(s)


if __name__ == "__main__":
    os.makedirs(PRETTY, exist_ok=True)
    write_rp()
    write_xiao()
    print("wrote", PRETTY)
