// OFT build B1: screw-closed case for the protoboard build, with slide-on bases.
//
// Printed parts:
//   body        open box. The board drops in solder side first and sits on a ledge all round.
//               Its bottom edge is a dovetail foot that the bases slide onto.
//               Print as exported (floor down), no supports.
//   lid         closes the box with four M3 screws threaded into the body's corner lugs.
//               Four fins reach down and clamp the board's long edges onto the ledge; two tabs
//               fill the wall above the Ethernet jack and above the USB plugs.
//               Print as exported (outer face down), no supports.
//   base-flat   plain plate, for sitting on the ground. Print flat.
//   base-pvc    snap-on clip for PVC pipe (pipe = "1/2" or "3/4") with an M3 set screw
//               against rotation. Print as exported (standing on its USB end), no supports.
//   base-strap  saddle with two tunnels for 20 mm straps, same orientation as the pipe clip.
//               Print as exported (standing on its USB end), no supports.
//
// A base slides on from the Ethernet end until the body meets the stop at the base's
// Ethernet end, so a pull on the cable pushes the case into the stop. A spring tongue in the
// base clicks into the body's floor; pull the case towards the USB end to take it off.
//
// Coordinates: x along the pipe (board 0..board_l, Ethernet jack at x < 0, USB at x > board_l),
// y across (0 = the protoboard's long edge on the Timer's side), z from the body's floor
// towards the lid.

part = "assembly"; // [assembly, body, lid, base-flat, base-pvc, base-strap, check]
base = "pvc";      // [flat, pvc, strap, none]  base shown in the assembly
pipe = "1/2";      // [1/2, 3/4]
explode = 0;
show_lid = true;
check_n = 0;

/* [Measured] */
board_l = 57.6;          // the first print's 57.4 pocket was about 0.5 too short
board_w = 51;
board_t = 1.0;
pins = 1.2;              // solder joints below the board
stack_h = 17;            // tallest part above the board's top face
jack_over = 8;           // Ethernet jack overhang past the board end
end_room = 1;            // extra length at the Ethernet end: the Timer board is wider than the jack and reaches almost as far
jack_w = 16;
jack_h = 13;
jack_z = 4;              // jack bottom above the board's top face
jack_yc = 14;            // jack centre from the y = 0 edge (same line as the Timer's USB-C)
usb_yc = [14, 38];       // USB-C centres from the y = 0 edge: Timer, C5
usb_z = 4;               // bottom of each USB-C port above the board's top face
c5_h = 7;

/* [Case] */
fit = 0.2;               // board to body, lid parts to body
head = 6;                // spare height above stack_h
floor_t = 2.0;
wall = 2.0;
step_w = 1.0;            // the walls step back this much above the board, room for the fins
ledge_w = 1.0;           // ledge under the board edge
lid_t = 2.0;
grip = 0.8;              // how far the fins reach over the board edge
clamp = 0.1;             // fins are this much longer than the gap, so they bear on the board
fin_l = 10;
usb_win = [4.5, 47];     // one opening for both USB plugs, y from .. to
usb_open_h = 7.5;
m3_tap = 2.7;            // hole an M3 screw cuts its own thread into
m3_free = 3.4;
lug_d = 6.5;

/* [Slide rail] */
flare = 2.5;             // dovetail: the foot is this much wider than the body, each side
land = 0.6;              // flat edge of the foot
slide_fit = 0.25;        // clearance between foot and base
plate_t = 2.4;
rail_w = 2.5;
stop_t = 1.5;
bump_h = 1.0;            // click height
tongue = [26, 6];        // spring tongue length, width

/* [Pipe clip] */
pipe_od = pipe == "3/4" ? 26.67 : 21.34;
pipe_clear = 0.2;
clip_wall = pipe == "3/4" ? 2.6 : 2.2;
clip_open = 100;         // mouth angle; faces sideways so the case hangs from solid plastic
clip_gap = 5;            // plate to clip, room for the zip tie slot
grip_l = 40;             // length of the full clip, from the USB end
tie = [6, 2.8];          // zip tie slot
boss_t = 6.5;            // set screw boss: an M3 x 8 or x 10 reaches the pipe
nut = [5.7, 2.8];        // M3 nut slot: across flats, thickness

/* [Strap saddle] */
strap = [21, 4.2];       // tunnel for a 20 mm strap
saddle_h = 11;
vee = [32, 5];           // groove that sits on the pole: width, depth

/* [Hidden] */
$fn = 72;
e = 0.01;
pocket = pins + 1.0;                 // depth below the board
T = floor_t + pocket + board_t;      // z of the board's top face
H = stack_h + head;                  // inside height above the board
ztop = T + H;                        // top of the walls
xj = -jack_over;                     // the jack's face; the bases stop the body here
xa = xj - end_room;                  // Ethernet end of the body
xb = board_l + fit + wall;           // USB end
yo = fit + step_w + wall;            // body outer face beyond the board edge
dt = land + flare;                   // height of the dovetail
zb = -slide_fit - plate_t;           // underside of a base plate
wg = 0.2;
xs0 = xj - wg - stop_t;              // Ethernet end of a base
bw0 = yo + flare + slide_fit + rail_w;
cy = board_w / 2;
lug_x = [xa + 5, xb - 5];
lug_y = -yo - 0.6;
lug_z = dt + 0.8;
clip_id = pipe_od + pipe_clear;
zc = zb - (clip_gap + clip_wall + clip_id / 2);
tie_x = [xs0 + 16, xb - 20];
xt1 = xb - 4;                        // free end of the tongue
xt0 = xt1 - tongue[0];
xd = xt1 - 3.4;                      // top of the click bump
yd = 42;
strap_x = [xs0 + 9, xb - 9 - strap[0]];
clamp_now = part == "check" ? 0 : clamp;

echo(str("CASE: ", xb - xa, " x ", board_w + 2 * yo, " (", board_w + 2 * (yo + 0.6) + lug_d - 2 * 0.6 + 0.6 * 2, " over the lugs) x ", ztop + lid_t));
echo(str("BASE: ", xb - xs0, " x ", board_w + 2 * bw0, "; pvc ", pipe, " adds ", zb - zc + clip_id / 2 + clip_wall + boss_t, " below the case; clip mouth ", clip_id * sin(clip_open / 2), " for pipe ", pipe_od));

module box(a, b) { translate(a) cube([b[0] - a[0], b[1] - a[1], b[2] - a[2]]); }
// extrude a (y, z) outline along x
module along_x(x0, x1) { translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) children(); }
// extrude an (x, z) outline along y
module along_y(y0, y1) { translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children(); }
module both_sides() { children(); translate([0, board_w, 0]) mirror([0, 1, 0]) children(); }

// ---------------------------------------------------------------- body

module foot2d() {
    polygon([[-yo - flare, 0], [-yo - flare, land], [-yo, dt], [board_w + yo, dt], [board_w + yo + flare, land], [board_w + yo + flare, 0]]);
}

module lug() {
    // column for one screw, sloped underneath so it prints without support
    for (x = lug_x) hull() {
        translate([x, lug_y, lug_z + 4.6]) cylinder(d = lug_d, h = ztop - lug_z - 4.6);
        box([x - lug_d / 2, -yo - e, lug_z], [x + lug_d / 2, -yo, ztop]);
    }
}

module body() {
    difference() {
        union() {
            box([xa, -yo, 0], [xb, board_w + yo, ztop]);
            along_x(xa, xb) foot2d();
            both_sides() lug();
        }
        // inside, above the board
        box([xa + wall, -fit - step_w, T], [board_l + fit, board_w + fit + step_w, ztop + 1]);
        // the board, and the pocket for its solder joints
        box([-fit, -fit, T - board_t], [board_l + fit, board_w + fit, T + e]);
        box([2, ledge_w, floor_t], [board_l - ledge_w, board_w - ledge_w, T]);
        // Ethernet jack and the Timer board behind it
        box([xa - 1, jack_yc - jack_w / 2 - 0.4, T + 2], [xa + wall + 1, jack_yc + jack_w / 2 + 0.4, ztop + 1]);
        // USB plugs
        box([board_l, usb_win[0], T + usb_z + 1.6 - usb_open_h / 2], [xb + 1, usb_win[1], ztop + 1]);
        // vents beside the PoE module and the C5
        for (y = [-yo - 1, board_w + fit + step_w - 1], i = [0 : 4])
            box([15 + i * 7, y, ztop - 13], [17 + i * 7, y + wall + 2, ztop - 2]);
        // screw holes
        both_sides() for (x = lug_x) translate([x, lug_y, ztop - 14]) cylinder(d = m3_tap, h = 15);
        // the Ethernet end's bottom edge, sloped to meet the base's stop
        along_y(-50, board_w + 50) polygon([[xa - 1, -1], [xj + dt + 1, -1], [xa - 1, xj + dt - xa + 1]]);
        // click recess
        box([xd - bump_h + 0.2, yd - tongue[1] / 2 - 0.6, -e], [xd + 3.2, yd + tongue[1] / 2 + 0.6, bump_h]);
    }
}

// ---------------------------------------------------------------- lid

module lid() {
    jz = T + jack_z + jack_h + 0.4;
    uz = T + usb_z + 1.6 + usb_open_h / 2;
    difference() {
        union() {
            box([xa, -yo, ztop], [xb, board_w + yo, ztop + lid_t]);
            both_sides() for (x = lug_x) hull() {
                translate([x, lug_y, ztop]) cylinder(d = lug_d, h = lid_t);
                box([x - lug_d / 2, -yo, ztop], [x + lug_d / 2, -yo + 1, ztop + lid_t]);
            }
            // fins that clamp the board's long edges
            both_sides() for (x = [1, board_l - 1 - fin_l]) hull() {
                box([x, -fit - step_w + fit, T + 1.5], [x + fin_l, grip, ztop + e]);
                box([x, 0, T - clamp_now], [x + fin_l, grip, T + 1.5]);
            }
            // wall above the Ethernet jack, wall above the USB plugs
            box([xa, jack_yc - jack_w / 2 - 0.4 + fit, jz], [xa + wall, jack_yc + jack_w / 2 + 0.4 - fit, ztop + e]);
            box([board_l + fit + fit, usb_win[0] + fit, uz], [xb, usb_win[1] - fit, ztop + e]);
        }
        both_sides() for (x = lug_x) translate([x, lug_y, ztop - 1]) cylinder(d = m3_free, h = lid_t + 2);
    }
}

// ---------------------------------------------------------------- bases

module base2d() {
    difference() {
        translate([-bw0, zb]) square([board_w + 2 * bw0, dt - zb]);
        offset(delta = slide_fit) { foot2d(); translate([-yo, 0]) square([board_w + 2 * yo, 20]); }
    }
}

// plate, rails, stop and click tongue: the part every base shares
module base_rail() {
    difference() {
        union() {
            along_x(xs0, xb) base2d();
            // stop: a slope the body's end runs onto, so it prints standing on the USB end
            along_y(-bw0, board_w + bw0)
                polygon([[xs0, zb], [xj + dt - wg - zb, zb], [xj - wg, dt], [xs0, dt]]);
        }
        // slot round the tongue
        difference() {
            box([xt0, yd - tongue[1] / 2 - 1, zb - 1], [xt1 + 1, yd + tongue[1] / 2 + 1, 1]);
            box([xt0 - 1, yd - tongue[1] / 2, zb - 2], [xt1, yd + tongue[1] / 2, 2]);
        }
    }
    // click bump: steep on the Ethernet side, which holds; gentle on the USB side, which
    // the body rides over as it slides on
    translate([0, 0, -slide_fit]) along_y(yd - tongue[1] / 2, yd + tongue[1] / 2)
        polygon([[xd - bump_h, -e], [xd, bump_h], [xd + 0.6, bump_h], [xd + 2.8, -e]]);
}

module clip2d(full) {
    // (u, v): u = across, v = towards the case, origin on the pipe axis
    difference() {
        union() {
            circle(d = clip_id + 2 * clip_wall);
            translate([-7, 0]) square([14, zb - zc]);
        }
        circle(d = clip_id);
        if (full) polygon([[0, 0], 40 * [cos(clip_open / 2), sin(clip_open / 2)], 40 * [1, 0], 40 * [cos(clip_open / 2), -sin(clip_open / 2)]]);
        else translate([0, -40]) square([40, 80]);
    }
    if (full) for (s = [-1, 1])   // rounded lips
        rotate(s * clip_open / 2) translate([clip_id / 2 + clip_wall / 2, 0]) circle(d = clip_wall);
}

module base_pvc() {
    r = clip_id / 2;
    bx = xs0 + 10;       // the set screw boss runs from the Ethernet end to here
    base_rail();
    difference() {
        union() {
            translate([0, cy, zc]) {
                along_x(xb - grip_l, xb) clip2d(true);
                along_x(xs0, xb - grip_l + e) clip2d(false);
            }
            // set screw boss on the far side of the pipe, on the rigid half of the clip
            box([xs0, cy - 5, zc - r - boss_t], [bx, cy + 5, zc - r + 2]);
            hull() {
                box([bx - e, cy - 5, zc - r - boss_t], [bx, cy + 5, zc - r + 2]);
                box([bx + boss_t + 3, cy - 5, zc - r - clip_wall], [bx + boss_t + 3 + e, cy, zc - r + 2]);
            }
        }
        translate([xs0 - 1, cy, zc]) rotate([0, 90, 0]) cylinder(d = clip_id, h = xb - xs0 + 2);
        box([xs0 - 1, cy, zc - r + e], [xb - grip_l, cy + 40, zb - e]);     // keep the mouth side open
        for (x = tie_x) box([x - tie[0] / 2, -50, zb - 1 - tie[1]], [x + tie[0] / 2, 100, zb - 1]);
        // set screw and its nut, which slides in from the Ethernet end
        translate([xs0 + 5, cy, zc - r - boss_t - 1]) cylinder(d = m3_free, h = boss_t + 4);
        box([xs0 - 1, cy - nut[0] / 2, zc - r - 1.8 - nut[1]], [xs0 + 5 + 3.4, cy + nut[0] / 2, zc - r - 1.8]);
    }
}

module base_strap() {
    base_rail();
    difference() {
        box([xs0, -bw0, zb - saddle_h], [xb, board_w + bw0, zb + e]);
        along_x(xs0 - 1, xb + 1) polygon([[cy - vee[0] / 2, zb - saddle_h - e], [cy, zb - saddle_h + vee[1]], [cy + vee[0] / 2, zb - saddle_h - e]]);
        for (x = strap_x) box([x, -bw0 - 1, zb - strap[1]], [x + strap[0], board_w + bw0 + 1, zb + 1]);
        // room for the tongue to move
        box([xt0 - 1, yd - tongue[1] / 2 - 1.5, zb - 1.2], [xt1 + 1.5, yd + tongue[1] / 2 + 1.5, zb + 1]);
    }
}

module the_base(b) {
    if (b == "flat") base_rail();
    if (b == "pvc") base_pvc();
    if (b == "strap") base_strap();
}

// ---------------------------------------------------------------- what goes inside, for pictures and the interference check

module electronics() {
    ty = usb_yc[0];
    cyy = usb_yc[1];
    color("goldenrod") box([0, 0, T - board_t], [board_l, board_w, T]);
    color("silver") for (i = [0 : 19], y = [ty - 8.9, ty + 8.9, cyy - 7.6, cyy + 7.6]) if (y < ty + 10 || i < 7)
        translate([board_l - 2.5 - i * 2.54, y, T - board_t - pins]) cylinder(d = 1.2, h = pins);
    color("royalblue") box([xj + 1.5, ty - 10.5, T + 2.5], [board_l - 0.5, ty + 10.5, T + 4]);
    color("lightgray") box([xj, jack_yc - jack_w / 2, T + jack_z], [xj + 21, jack_yc + jack_w / 2, T + jack_z + jack_h]);
    color("dimgray") box([xj + 22, ty - 10.5, T + 10], [board_l - 8, ty + 10.5, T + stack_h]);
    color("dimgray") box([board_l - 23, cyy - 9, T], [board_l - 2, cyy + 9, T + 1.2]);
    color("gainsboro") box([board_l - 20, cyy - 6, T + 1.2], [board_l - 8, cyy + 6, T + c5_h]);
    color("lightgray") for (y = usb_yc) box([board_l - 6, y - 4.5, T + usb_z], [board_l + 2, y + 4.5, T + usb_z + 3.2]);
}
module usb_plugs() {
    for (y = usb_yc) box([board_l + 2 - 6, y - 6.2, T + usb_z + 1.6 - 3.3], [board_l + 30, y + 6.2, T + usb_z + 1.6 + 3.3]);
}
module pipe_solid() { translate([xs0 - 40, cy, zc]) rotate([0, 90, 0]) cylinder(d = pipe_od, h = xb - xs0 + 80); }

if (part == "body") body();
else if (part == "lid") translate([0, 0, ztop + lid_t]) rotate([180, 0, 0]) lid();
else if (part == "base-flat") base_rail();
else if (part == "base-pvc") rotate([0, 90, 0]) base_pvc();
else if (part == "base-strap") rotate([0, 90, 0]) base_strap();
else if (part == "check") {
    if (check_n == 0) intersection() { body(); lid(); }
    if (check_n == 1) intersection() { union() { body(); lid(); } electronics(); }
    if (check_n == 2) intersection() { union() { body(); lid(); } usb_plugs(); }
    if (check_n == 3) intersection() { union() { body(); lid(); } the_base(base); }
    if (check_n == 4) intersection() { base_pvc(); pipe_solid(); }
} else {
    color("steelblue") body();
    electronics();
    if (show_lid) translate([0, 0, explode]) color("orange", 0.85) lid();
    translate([0, 0, -explode]) color("seagreen") the_base(base);
    if (base == "pvc") color("white", 0.6) translate([0, 0, -explode]) pipe_solid();
}
