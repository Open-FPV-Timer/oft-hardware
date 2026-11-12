# Ethernet cable guide for a PVC gate

A clip that snaps onto 1/2 in PVC pipe and holds the Ethernet cable beside it. Put one
every 30 cm or so down the gate, and one close to the Timer's case as strain relief.

Print lying flat, as exported, no supports. 10 mm tall, about 37 x 26 mm. PETG grips
better than PLA and survives being taken off more often.

`./build.sh` exports `out/cable-guide.stl` and pictures (needs Docker only). Sizes are
parameters at the top of `guide.scad`:

- `cable_d`: cable diameter, 6.0 by default. `./build.sh -D cable_d=5.5` for a thin cable.
- `pipe_clear`, `pipe_open`: how hard it grips the pipe (same values as the case's clip).
- `cable_open`: how hard the cable clicks in.
- `width`: length along the pipe.

Not yet printed.
