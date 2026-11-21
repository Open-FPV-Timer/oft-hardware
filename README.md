# oft-hardware: carrier boards for the Open FPV Timer

KiCad 9 drafts of the boards that replace the jumper wires in the reference builds
([oft-spec §9](../oft-spec/oft-spec.md)). One design in four sizes. All are first drafts made
before any hardware has been measured or powered, so treat every dimension as provisional.

| Board | Nodes | Shape | Size | Layers |
|---|---|---|---|---|
| [carrier-1](carrier-1/) | 1 | stick | 96 x 25 mm | 2 |
| [carrier-2](carrier-2/) | 2 | one row above the Timer | 66 x 53 mm | 2 |
| [carrier-4](carrier-4/) | 4 | a row of two above and below | 66 x 80 mm | 2 |
| [carrier-8](carrier-8/) | 8 | a row of four above and below | 94 x 80 mm | 2 |

Every board carries one Waveshare RP2350-POE-ETH Timer and Seeed XIAO ESP32-C5 Nodes. Slots can
be left empty.

- **1 Node** is a 25 mm stick for the gate's top bar: Ethernet in at one end, the Node at the
  other.
- **2, 4 and 8 Nodes** put the Timer across the middle of the board, RJ45 at the left edge,
  with the XIAOs in rows either side of it. USB-C ports face the outer edges so every one
  stays reachable; antenna connectors face the Timer.

## Why these parts

- **RP2350-POE-ETH** is MCU, Ethernet and PoE on one $25 module. Replacing it means designing a
  PoE front end, which is not worth it for a draft.
- **XIAO ESP32-C5** brings its own regulator, USB-C for flashing and a finished RF section.
  A bare ESP32-C5 module would save roughly $9 a Node but needs a 3.3 V supply, boot and USB
  circuitry and reflow assembly. That is the natural second revision of the 4 and 8-Node
  boards once this one is proven, where hand-soldering eight XIAOs also stops being fun.

## Pin map

Slots are numbered left to right, top row first. The pins follow the layout: each row's UART
pads are wired to the Timer pin row facing it, in the same left-to-right order, so nothing
crosses. UART1 (GP4/GP5) is the pair `oft-timer-rp2350/src/board.rs` uses today, so that is
the slot the current single-Node firmware drives.

| Board | Slot: Timer TX / RX (to Node D7 / from Node D6) |
|---|---|
| carrier-1 | 1: GP4/GP5 (UART1) |
| carrier-2 | 1: GP4/GP5 (UART1), 2: GP0/GP1 (UART0) |
| carrier-4 | 1: GP4/GP5 (UART1), 2: GP0/GP1 (UART0), 3: GP13/GP15, 4: GP22/GP28 |
| carrier-8 | 1: GP10/GP11, **2: GP4/GP5 (UART1)**, 3: GP2/GP3, **4: GP0/GP1 (UART0)**, 5: GP12/GP13, 6: GP14/GP15, 7: GP22/GP26, 8: GP27/GP28 |

Note the 8-Node board: the UART1 slot is slot 2, not slot 1. Slots without a hardware UART
need PIO UARTs; six of them is every PIO state machine the RP2350 has. Shared by every slot:
SYNC on GP6, EN on GP7, BOOT on GP8. The map is in `gen/carrier.py`.

## Circuit

- **Data lines:** 220R in series on every UART line and on SYNC, to limit the current when one
  board is powered and the other is not.
- **EN and BOOT:** one 1k each from the Timer, then bussed to every slot. The Timer resets or
  boot-straps all Nodes together, and a reset or boot button on any XIAO acts on all of them.
  Each Node has its own UART, so they can still be flashed one at a time.
- **Power:** each XIAO runs from the Timer's Vsys through its own Schottky diode (B5819W) with a
  10 uF capacitor. A laptop on one XIAO's USB-C then powers only that XIAO and cannot back-feed
  the Timer. The diode costs about 0.3 to 0.4 V, so the XIAO sees roughly 4.3 V.

## How the modules mount

- **RP2350-POE-ETH** plugs into two 1x16 female sockets, component side up. The link resistors
  sit on the carrier under it or just beside its pin rows.
- **XIAO ESP32-C5** is soldered flat by its castellated edge pads. Its EN, MTMS (GPIO2, the
  SYNC input) and BOOT pads are on the underside, so each lands on a plated hole in the carrier
  that you fill with solder from the back. No firmware change is needed: these are the pins
  `oft-node-c5` already uses.

Fab-assembled: resistors, capacitors, diodes, all top side. Hand-soldered: the two sockets and
the XIAOs.

## Files

- `carrier-N/`: the KiCad project for each size.
- `lib/`: shared symbols (`oft.kicad_sym`) and footprints (`oft.pretty`) for the two modules.
  The Timer footprint is drawn from Waveshare's dimension drawing; the XIAO pad positions come
  from Seeed's own `XIAO-ESP32-C5-SMD` footprint (MIT, github.com/Seeed-Studio/OSHW-XIAO-Series;
  its notice is in `NOTICE.md`).
- `gen/`: the scripts that produced the drafts. `carrier_sch.py` draws the schematic for any
  size. `stick_pcb.py` lays out the 1-Node board and `grid_pcb.py` the 2, 4 and 8-Node boards;
  placement and routing are written out by hand, and each file's header explains its routing
  plan. `parts.py` writes the footprints; `sch.py` and `pcb.py` are helpers. Regenerating overwrites a board, so stop regenerating a size once you start editing
  it in KiCad.
- `tools/kicad.sh`: runs anything inside the official `kicad/kicad:9.0` container. Nothing is
  installed on the host.

## Regenerate and check

```
tools/kicad.sh gen/build.sh 4          # 4-Node board: regenerate, ERC, DRC, previews
tools/kicad.sh gen/build.sh 4 check    # ERC, DRC, previews only
```

Outputs land in `carrier-N/out/` (gitignored): `schematic.pdf`, `render-top.png`,
`render-bottom.png`, `layout-top.svg`, `layout-bottom.svg`, `erc.rpt`, `drc.rpt`.

After opening a board in the KiCad GUI, press B once to refill zones.

## Check before ordering

1. **Timer pin grid.** Two rows of 16 on a 2.54 mm pitch, 17.78 mm apart, first pin 1.35 mm
   from the USB-C end. Taken from Waveshare's drawing, not measured. Put calipers on a real
   board. The numbers are at the top of `gen/parts.py`.
2. **Timer pin order.** Pin 1 (GP0) is at the USB-C end of one row and pin 32 (VBUS) at the
   USB-C end of the other. Waveshare's pinout drawing shows the label side; the footprint
   mirrors it for the component side. Check the pins in the table above against the silkscreen.
3. **XIAO underside pads.** Positions are Seeed's, but which pad is which (EN, MTMS, BOOT in
   the column on the D0 side) was read off Seeed's back-view pinout picture. Check with a
   meter: EN to the reset button, BOOT to the boot button.
4. **XIAO underside clearance.** The carrier has no top copper under the XIAO body, so its
   other underside pads (3V3, GND, JTAG, BAT, thermal) touch only solder mask. Confirm nothing
   on the XIAO's underside stands proud.
5. **Solder-through holes.** 0.9 mm plated holes in 1.7 mm pads. Untested as a way to reach
   the underside pads; try one XIAO before committing a batch.
6. **Power for 4 and 8 Nodes.** Everything draws through the Timer module's Vsys pin. The Node
   current while sampling and the PoE module's 5 V rating are both still unmeasured (HBOM).
   Eight Nodes will very likely need a separate 5 V input on the carrier, which this draft does
   not have.
7. **Firmware.** The Timer drives one Node today. The other slots are a pin proposal that
   needs UART0 and PIO UART support before the larger boards do anything extra.
8. **VSYS on the 2 and 4-Node boards** squeezes between two Timer pins as a 0.4 mm track for a
   few millimetres. Fine for two Nodes; check it against the measured current for four.
9. **Antenna end clearance.** On the 2, 4 and 8-Node boards the XIAOs' antenna ends sit 8 mm
   from the Timer's pin rows, and the module overhangs its pins by 1.6 mm, 11 mm up. Check a
   u.FL plug and its cable fit beside the Timer and its PoE module.
10. **Antennas.** The spec leans towards one gate antenna and a splitter for multi-Node
    builds; that is off these boards.
11. **Socket height.** On the stick, a USB-C plug in the Timer module passes over the XIAO.
    That needs standard 8.5 mm sockets; low-profile sockets will not clear.
12. **LCSC part numbers** in the schematic `LCSC` fields were filled in from memory. Confirm
    each one before generating a JLCPCB BOM.
13. **Mounting.** M2.5 holes, positions arbitrary: four at the corners of the stick, three or
    four beside and under the Timer on the others (those under the module are only reachable
    with it unplugged). Decide alongside the case, along with where the foil wall goes.

## Acknowledgements

OFT is inspired by [FPVGate](https://github.com/LouisHitchcock/FPVGateC5MK), which showed
that an ESP32-C5 can time laps, and builds on [widscan58](https://github.com/CapnBry/widscan58),
esp-sdr, C5VRX and RotorHazard. The full list is in the
[oft README](https://github.com/Open-FPV-Timer/oft#acknowledgements).

## Licence

GPL-3.0-or-later, the same as the other OFT repos. See [LICENSE](LICENSE).
