# Case for the B1 protoboard build

Screw-closed case for the first single-Node timer (Waveshare RP2350-POE-ETH with PoE module and
a XIAO ESP32-C5 on a 57 x 51 mm protoboard), with bases that slide on.

| Part | What it does | How to print |
|---|---|---|
| `body` | Open box. The board drops in solder side first onto a ledge. Its bottom edge is a dovetail foot for the bases. | Floor down, as exported. No supports. |
| `lid` | Closes the box with four M3 screws. Four fins clamp the board's long edges onto the ledge. | Outer face down, as exported. No supports. |
| `base-flat` | Plain plate, for sitting on the ground. | Flat, as exported. No supports. |
| `base-pvc-half-inch`, `base-pvc-three-quarter-inch` | Snap-on pipe clip with an M3 set screw against rotation. The case hangs under the gate's top bar, lid facing the ground. | Standing on the USB end, as exported. No supports. |
| `base-strap` | Saddle with two tunnels for 20 mm straps, same orientation as the pipe clip. | Standing on the USB end, as exported. No supports. |

Case 68 x 57 x 30 mm (65 mm across the screw lugs); a base is 70 x 68 mm. All parts are meant
for PLA and a 0.4 mm nozzle.

## Hardware

- 4 x M3 screw, 8 to 12 mm long, for the lid. They cut their own thread in the body's lugs.
- Pipe base only: 1 x M3 screw, 8 or 10 mm long, and 1 x M3 nut. The nut slides into the slot
  at the clip's Ethernet end.

## Assembly

1. Drop the board into the body, Ethernet jack into its notch.
2. Put the lid on and fit the four screws. Stop when the lid sits on the walls.
3. Slide the body onto a base, Ethernet end first, entering at the base's USB end, until it
   clicks. To take it off, pull the case back towards the USB end.

A pull on the Ethernet cable pushes the case against the stop at the base's Ethernet end.

## Building

`./build.sh` exports the STLs and pictures to `out/` and checks that the parts, the
electronics, USB plugs and the pipe do not overlap. It needs Docker only.

Sizes are parameters at the top of `case.scad`. The ones most likely to need a change after
a first print:

- `jack_yc`, `usb_yc`: where the Ethernet jack and the two USB-C ports are across the board.
- `board_l`, `fit`: the board pocket.
- `clamp`: how hard the lid's fins press on the board.
- `m3_tap`: the hole the lid screws thread into.
- `slide_fit`, `bump_h`: how freely a base slides, and how hard it clicks.
- `pipe_clear`, `clip_open`: how hard the pipe clip grips.

Not yet printed in this form. The Timer's BOOT button is not reachable with the lid on.
