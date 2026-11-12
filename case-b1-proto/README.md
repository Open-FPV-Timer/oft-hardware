# Case for the B1 protoboard build

Snap-on case for the first single-Node timer (Waveshare RP2350-POE-ETH with PoE module and a
XIAO ESP32-C5 on a 57 x 51 mm protoboard). It hangs under the top bar of a gate made from
1/2 in PVC, components facing the ground, Ethernet leaving along the pipe.

| Part | What it does | How to print |
|---|---|---|
| `tray` | Sits against the pipe. The board drops in solder side first. Carries the pipe clip and two zip tie slots. | Standing on its USB end, as exported. No supports. |
| `cover` | Faces the ground. Drops over the components, clamps the board edges, clicks into the tray. | Top face down, as exported. No supports. |

Outer size 76 x 57 x 29 mm, plus 31 mm for the clip. PETG is the better choice for the clip.

`./build.sh` exports the STLs and pictures to `out/` and checks that the parts, the
electronics, USB plugs and the pipe do not overlap. It needs Docker only.

Sizes are parameters at the top of `case.scad`. The ones most likely to need a change after
a first print:

- `head`: spare height above the 17 mm measured stack (6 mm by default).
- `fit`: clearance between board, tray and cover (0.2 mm).
- `pipe_clear`, `clip_open`: how hard the clip grips.
- `bump`: how hard the cover clicks in.

Not yet printed. There is a gap below the Ethernet jack, and the Timer's BOOT button is not
reachable with the cover on.
