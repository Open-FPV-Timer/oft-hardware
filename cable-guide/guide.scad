// OFT: Ethernet cable guide for a gate made from 1/2 in PVC pipe.
//
// A clip that snaps onto the pipe with a smaller clip beside it for the cable. Use one every
// 30 cm or so down the gate, and one close to the Timer's case as strain relief.
// One flat extrusion: print lying down as exported, no supports. The layers run around
// both rings, which is the strong direction for a clip.

/* [Pipe] */
pipe_od = 21.34;         // 1/2 in schedule 40 PVC
pipe_clear = 0.2;
pipe_wall = 2.2;
pipe_open = 100;         // mouth angle (same as the case's clip)

/* [Cable] */
cable_d = 6.0;           // round Cat5e is about 5.5, Cat6 about 6
cable_clear = 0.5;       // the cable should slide, not be squeezed
cable_wall = 1.8;
cable_open = 80;         // mouth angle; the cable pushes in past the lips
cable_dir = 100;         // where the cable mouth faces (90 = at right angles to the pipe mouth)

/* [Body] */
width = 10;              // length along the pipe

/* [Hidden] */
$fn = 96;
pid = pipe_od + pipe_clear;
cid = cable_d + cable_clear;
cx = -(pid / 2 + pipe_wall + cid / 2);   // cable centre: its bore touches the pipe ring's outside

echo(str("pipe mouth ", pid * sin(pipe_open / 2), " for pipe ", pipe_od,
         "; cable mouth ", cid * sin(cable_open / 2), " for cable ", cable_d));

module wedge(a, r) { polygon([[0, 0], r * [cos(a / 2), sin(a / 2)], r * [1 / cos(a / 2), 0], r * [cos(a / 2), -sin(a / 2)]]); }
module lips(d, wall, a) { for (s = [-1, 1]) rotate(s * a / 2) translate([d / 2 + wall / 2, 0]) circle(d = wall); }

module guide2d() {
    difference() {
        union() {
            circle(d = pid + 2 * pipe_wall);
            translate([cx, 0]) circle(d = cid + 2 * cable_wall);
            // web between the rings on the side away from the cable mouth
            intersection() {
                hull() { circle(d = pid + 2 * pipe_wall); translate([cx, 0]) circle(d = cid + 2 * cable_wall); }
                translate([cx, -(cid / 2 + cable_wall)]) square([-cx, cid / 2 + cable_wall]);
            }
        }
        circle(d = pid);
        wedge(pipe_open, 40);
        translate([cx, 0]) { circle(d = cid); rotate(cable_dir) wedge(cable_open, cid / 2 + cable_wall + 0.3); }
    }
    lips(pid, pipe_wall, pipe_open);
    translate([cx, 0]) rotate(cable_dir) lips(cid, cable_wall, cable_open);
}

linear_extrude(width) guide2d();
