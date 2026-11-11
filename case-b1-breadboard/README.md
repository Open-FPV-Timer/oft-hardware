# case-b1-breadboard: printable case for the breadboard build of B1

A box for the first OFT test build ([HBOM](../../oft-spec/hbom-b1-single-pilot.md)): one
solderless breadboard carrying the Waveshare RP2350-POE-ETH Timer (with its PoE module) and one
Seeed XIAO ESP32-C5 Node, clipped to 1/2 in PVC pipe. Parametric OpenSCAD, one file:
[`case.scad`](case.scad).

**First draft, never printed, drawn with no hardware to measure.** Like the carrier boards,
treat every dimension as provisional. It is meant for a test fit: print it, see what is wrong,
change a parameter.

> **Assumption to check first: the breadboard size.** "Standard breadboard" was taken to mean
> a **full-size 830-point board, 165 x 55 x 9.5 mm**. That is the default (`bb_preset = "full"`).
> A half-size 400-point preset (82 x 55 mm) is included (`bb_preset = "half"`), and
> `"custom"` takes any size. Measure yours, including the thickness with its foam backing,
> before printing anything. The case also assumes **where on the breadboard the two boards are
> plugged**; see "How the boards must sit".

## Parts

| Part | Qty | What it is | Print orientation |
|---|---|---|---|
| `base` | 1 | Tub, 200 x 62 x 35 mm (75 mm over the screw ears). RJ45 notch, PoE vents, pigtail notch, clip screw holes | Open side up, as exported |
| `lid` | 1 | Flat lid with a locating lip, four legs that hold the breadboard down, the antenna window skin, and the opening for the hatch | Outer face on the bed, as exported |
| `hatch` | 1 | Cover over the Timer's USB-C end and its BOOT and RESET buttons, with a pinhole over each | Outer face on the bed, as exported |
| `bulkhead` | 1 | 1.6 mm card that slides in between the Timer and the Node. Wrap it in foil | Flat, as exported |
| `clip` | 2 | Snap-on C-clip for the pipe, screwed under the base | Pipe axis vertical, as exported |

No supports are needed for any part. The STLs are exported in print orientation.

Hardware: 6x M3x10 pan-head screws (lid, self-tapping into 2.8 mm holes), 2x M3x8 (hatch, no
longer or they poke into the box), 8x M3x8 countersunk screws with 8x M3 nuts (clips), and a
few 2.5 to 4 mm zip ties.

## How it mounts to the pipe

Each clip is a C that wraps 240 degrees of the pipe and snaps on sideways; the bore is 0.2 mm
under the pipe diameter so it grips. It bolts to the underside of the base with four M3
countersunk screws put in from inside the box (heads flush with the floor, under the
breadboard) into nuts in hex pockets on the clip.

- **Pipe along the case** (the normal way, on the gate's top bar or a leg): two clips, 70 mm
  apart.
- **Pipe across the case:** the screw holes are on a 30 mm square, so a clip can be turned 90
  degrees. Use one clip in that case (the two stations would not be in line), plus a zip tie.
  The unused station leaves four open holes; tape over them.
- **Zip tie:** each clip has a tunnel through its neck. Thread a tie through and round the
  pipe. **Always do this when the case hangs under a horizontal bar**: the clip's mouth then
  faces down and gravity pulls the pipe straight out of it. The snap alone is only trustworthy
  with the case on top of or beside the pipe.
- 3/4 in pipe (26.67 mm, the HBOM's other size): set `pipe_od = 26.67` and re-export `clip`.
  Checked that the geometry builds; nothing else changes.

The lid always faces away from the pipe. That is the face the antenna looks through, so hang
the case **under** the top bar (lid down) or on the **gate side** of a leg.

## How the boards must sit

The openings only line up if the boards are plugged in the way the model assumes. Open
`out/top-open.png` next to this list.

1. **Timer, component side up**, straddling the centre channel, RJ45 pointing out of the end
   of the breadboard, PoE module on top.
2. **Full-size board:** the Timer's last pins (16 and 17, nearest the RJ45) go in **row 9**
   from that end. The Timer's PCB then ends about level with the breadboard and the RJ45
   sticks out 2.3 mm past it, through the end wall. **Half-size board:** row 1, with the RJ45 part of
   the Timer hanging 19 mm past the end of the breadboard. `timer_last_pin_row` sets this.
3. **XIAO at the other end**, antenna (u.FL) end pointing away from the Timer, its last pins in
   the last row. Its USB-C therefore points at the Timer, inside the box.
4. Jumpers run flat along the breadboard between them and pass under the bulkhead card through
   a 22 x 6 mm slot.

If your boards are plugged differently, either move them or change `timer_last_pin_row` and
`xiao_row_from_end`.

## What the openings are for

- **Ethernet:** a U-shaped notch in the end wall, 19 mm wide, open to the rim so the populated
  breadboard drops straight in. It runs from 2 mm below the Timer's PCB to the lid, so a booted
  plug and its latch have room whichever way up the latch is. A tongue on the lid closes the
  notch above the jack. The jack face sits 0.5 mm inside the outer wall face.
- **Timer USB-C and BOOT (recovery):** the Timer's USB-C is at the inner end of the Timer,
  63 mm from the Ethernet wall and pointing down the length of the breadboard, so no hole in a
  wall can reach it. Instead the lid has an 18 x 56 mm opening over the USB-C end of the Timer
  and the 42 mm of breadboard beyond it, closed by the `hatch` cover (two screws). Take the
  hatch off, lower a USB-C plug into the trench and push it home. Keep jumpers out of that
  trench. The hatch has 2 mm pinholes over BOOT (marked with a dot) and RESET.
  **Caveat:** in Waveshare's photo the PoE module appears to cover the buttons. If it does, the
  pinholes are useless and BOOT has to be reached with the hatch off, at an angle from the
  USB-C end. See "Measure before printing".
- **XIAO USB-C:** sealed inside. There is no opening for it, because it faces the Timer. Take
  the lid off to flash it over USB.
- **Antenna:** see the next section.
- **Vents:** six 2 x 11 mm slots in each side wall beside the PoE module.
- **Breadboard removal:** nothing is glued. Four legs on the lid press on the breadboard's
  long edges; with the lid off it lifts out. There is a finger scoop in the floor under its
  antenna end and a 9 mm push-out hole through the floor in the middle.

## Antenna and foil (HBOM box rules)

The case is plain plastic; the shielding is a foil liner you add. Every wall has 1 mm of spare
room for it (`liner_gap`).

| Box rule | What the case does |
|---|---|
| Window at least 3 to 5 cm | The lid has a 40 x 39 mm pocket over the antenna bay and the XIAO's antenna end where the plastic is thinned to 0.8 mm. Line the lid with foil and leave this pocket bare: that is the window. Set `window_skin = 0` for an open hole instead |
| Antenna right at the window | The 30 mm bay past the breadboard (`ant_bay`) is under the window; the XIAO's u.FL socket is about 8 mm inside the window's edge. A whoop whip lies across the bay |
| Foil wall between the RP2350 board and the C5 | The `bulkhead` card, wrapped in foil, 12 mm on the Timer side of the XIAO. Jumpers pass through its 22 x 6 mm slot |
| Cables in at the end away from the window | Ethernet is at the opposite end from the window. The recovery USB cable enters through the hatch, in the Timer bay |
| Removable liner and adjustable window | The liner is not a printed part: use foil on card or foil tape on paper, cut to each wall, so it lifts out. Adjust the window with tape. No printed slide |

For an antenna outside the box (a directional one on a short lead), the antenna-end wall has a
3 mm notch at the rim for a u.FL pigtail and two slots below it for a zip tie as strain relief.
The HBOM does not call for an SMA bulkhead, so the hole for one is off by default
(`sma_hole = true` adds a 6.5 mm hole in the same wall). There is no bracket for a directional
antenna; tape it to the lid.

Things that break the shield, which the liner has to deal with or you have to accept:

- The **hatch opening** (18 x 56 mm) is on the lid, the face that looks at the gate, in the
  Timer bay. Foil the inside of the hatch cover and make it touch the lid liner.
- The **vents** are 2 mm wide, far too narrow to leak at 5.8 GHz, but foil over them blocks
  the air. Perforate it there.
- The RJ45 notch, the push-out hole, the pigtail notch and the lid joint.
- The lid's steel screws at the antenna end are about 30 mm from the antenna. Use nylon screws
  there, or leave those two out, if they turn out to matter.

## Print settings

PETG preferred (the clips flex and the gate lives outdoors); PLA is fine for a fit check.
0.2 mm layers, 0.4 mm nozzle, 3 perimeters, 20% infill, no supports. Clips: 4 perimeters or
more, and print them standing on their profile as exported so the layers run round the C, not
across it. The base is 200 mm long: it fits a 220 x 220 bed with 10 mm to spare each end, so
turn off the skirt or print it diagonally if your printer needs the margin.

Tolerances are parameters: `fit` (lid lip to wall, 0.25), `bb_clear` (around the breadboard,
0.5), `pipe_clear` (clip bore, -0.2), `m3_pilot` (2.8; use 4.0 for heat-set inserts),
`m3_clear` (3.4), `nut_af` (5.8).

## Build

```
./build.sh                                        # STLs, previews and checks into out/
OUT=out/half ./build.sh -D 'bb_preset="half"'     # half-size breadboard
./build.sh -D pipe_od=26.67                       # 3/4 in pipe
```

`build.sh` runs the official `openscad/openscad:dev` container (the same pattern as
`tools/kicad.sh`), so nothing is installed on the host. `out/` is gitignored by the repo's
existing `*/out/` rule, like the carrier boards' outputs. Or open `case.scad` in the OpenSCAD
GUI and set `part`.

The script ends with interference checks: it intersects each pair of printed parts, and the
case with the mock electronics and pipe, and fails if any pair shares more than 0.5 mm3.

## What was checked, and what was not

Checked, in the model only:

- Rendered and looked at: the assembly (closed, open, exploded, from below, pipe along and
  across), orthographic top, side and both end views, and each part on its own.
- The interference checks pass for the default (full-size) case with the pipe either way.
- The RJ45 mock sits in the notch with the lid tongue above it; the mock USB-C plug fits the
  trench under the hatch; the clip wraps 240 degrees of the pipe with an 18.3 mm mouth against
  a 21.34 mm pipe.
- The half-size preset builds, with one **known failure**: the mock USB-C plug hits the
  bulkhead, because there are only 16 mm between the Timer's USB-C and the XIAO on a half-size
  board. No straight USB-C plug fits there, case or no case. On a half-size board the hatch
  reaches only the buttons; to use the Timer's USB you would have to pull the XIAO.

Not checked, because nothing was printed or measured:

- Any fit against real parts. The electronics in the previews are blocks built from the same
  numbers as the case, so they agree with it by construction.
- Whether the clip snaps on and grips (wall 2.8 mm, PETG assumed), and whether the lid legs,
  lip and thin window skin print cleanly.
- Any RF behaviour: loss through 0.8 mm of plastic, how well a card-and-foil liner seals.
- Whether the lid stays flat. Six screws hold it; the longest span between them is 117 mm,
  from the Ethernet-end pair to the middle pair, and the hatch opening is in that span.

## Measure before printing

From vendor drawings (believed good): Timer PCB 63.00 x 21.00 mm, RJ45 16.00 mm wide and
overhanging the PCB by 2.88 mm, USB-C 8.95 mm wide and centred, pin grid 2.54 mm with rows
17.78 mm apart, first pin 1.35 mm from the USB-C end (Waveshare's dimension drawing). XIAO
21 x 17.8 mm, USB-C and u.FL on the centreline at opposite ends, u.FL 1.5 mm from its end,
both buttons at the u.FL end (Seeed's KiCad board file).

Not on any drawing I could find. Each is a named parameter at the top of `case.scad`:

| # | Parameter | Value used | What to measure | Matters for |
|---|---|---|---|---|
| 1 | `bb_preset`, `bb_l`, `bb_w` | 165 x 55 | Breadboard length and width, including the dovetail nubs on its edges | Everything. Cavity is the board plus 1.5 mm a side |
| 2 | `bb_h` | 9.5 | Breadboard thickness with its backing | RJ45 notch height, hold-down legs, box height |
| 3 | `bb_row1` | 3.8 (full), 4.2 (half) | End edge of the breadboard to the centre of its first row of holes | Where the RJ45 meets the end wall |
| 4 | `hdr_gap` | 2.5 | Gap between breadboard top and the underside of the Timer PCB when plugged in | RJ45 notch height |
| 5 | `tm_rj45_h` | 13.5 | RJ45 jack height above the PCB | Lid tongue, box height |
| 6 | `poe_top` | 15 | Top of the fitted PoE module above the Timer PCB's top face | Box height (`headroom` adds 3 mm) |
| 7 | `poe_l`, `poe_w` | 40 x 24 | PoE module outline, and how far it reaches toward the USB-C end | Whether it covers BOOT; hatch screw bosses on a half-size board |
| 8 | `tm_boot_from_usb_end`, `tm_boot_y` | 9.9, 4.55 | BOOT button centre: distance from the USB-C end and from the centreline | Pinholes. Scaled off the drawing's photo, not dimensioned |
| 9 | (none) | - | **Is BOOT reachable from above with the PoE module fitted?** | If not, the pinholes do nothing; use the hatch |
| 10 | `tm_pcb_t` | 1.6 | Timer PCB thickness | Minor |
| 11 | `hatch_fwd`, `hatch_w` | 42, 18 | Your USB-C cable's plug: body length and width | Whether the plug fits the trench |
| 12 | `xiao_y_off` | 1.27 | Which way the XIAO sits off-centre (its 15.24 mm rows cannot centre on a breadboard) | Mock only today |
| 13 | `pipe_od` | 21.34 | Your pipe. PVC varies by a few tenths | Clip grip; tune with `pipe_clear` |
| 14 | `ant_bay`, `window_w` | 30, 40 | Your antennas: does the whip fit across the bay, the directional one under the window? | Antenna room. `ant_bay` can grow to about 45 before the base outgrows a 220 mm bed |
| 15 | (none) | - | Jumper height above the breadboard. The box allows 22 mm | Lid closing |

Also still open from the HBOM and not something the case can settle: the PoE module's standard
and output rating, and the handedness of the directional antennas.

## Licence

GPL-3.0-or-later, the same as the rest of this repo. See [LICENSE](../LICENSE).
