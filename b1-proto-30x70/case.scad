// OFT build B1 on a 30 x 70 mm protoboard: screw-closed case with slide-on bases.
//
// Printed parts:
//   body        open box. The board sits on four corner posts and is held by an M2 x 5 screw
//               in each corner hole. The Node hangs below the board, the Timer stands above
//               it. One opening, for the Ethernet jack: the board comes out of the case to
//               reach either USB-C port. The body's bottom edge is a dovetail foot, set in
//               from the sides, that the bases slide onto.
//               Print as exported (floor down), no supports.
//   lid         closes the box with three M3 screws: two into columns inside the Ethernet-end
//               corners and one into a lug on the far end, so nothing sticks out of the long
//               sides. A tab fills the wall above the Ethernet jack.
//               Print as exported (outer face down), no supports.
//   base-flat   plate for sitting on the ground. Its sides are flush with the case's.
//               Print as exported (plate down), no supports.
//   base-pvc    snap-on clip for PVC pipe (pipe = "1/2" or "3/4") with an M3 set screw
//               against rotation. Print as exported (standing on its far end), no supports.
//   base-strap  saddle with one tunnel for a 20 mm strap.
//               Print as exported (standing on its far end), no supports.
//
// A base slides on from the Ethernet end until the body meets the stop at the base's
// Ethernet end, so a pull on the cable pushes the case into the stop. A spring tongue in the
// base clicks into the body's floor; pull the case towards the far end to take it off.
//
// The foot is narrower than the case, not wider: the base's rails sit under the case's
// sloped lower edges, inside its outline, so every base is as wide as the case and no wider.
//
// Coordinates: x along the board (0 at the protoboard's A end, where the Timer overhangs and
// the Ethernet jack is; board_l at the X end), y across (0 = the row 1 edge), z from the
// underside of the foot towards the lid.
//
// The slide rail, pipe clip and strap saddle come from the first protoboard case (57 x 51 mm,
// since removed), which was printed and fitted.

part = "assembly"; // [assembly, body, lid, base-flat, base-pvc, base-strap, check]
base = "pvc";      // [flat, pvc, strap, none]  base shown in the assembly
pipe = "1/2";      // [1/2, 3/4]
explode = 0;
show_lid = true;
check_n = 0;

/* [Board: measure these] */
board_l = 70;
board_w = 30;
board_t = 1.6;           // protoboard thickness
mh_inset = 2.0;          // corner mounting holes: centre to each edge. Looks right on the board; not calipered
mh_tap = 1.7;            // hole an M2 screw cuts its own thread into
under_h = 10;            // room under the board. The Node's USB-C reaches 7 below it (measured), which leaves 3
stack_h = 17;            // tallest part above the board's top face (the PoE module), as measured on the first build
timer_over = 15.2;       // Timer board past the A end of the protoboard (Waveshare's drawing)
jack_out = 2.9;          // Ethernet jack past the end of the Timer board
jack_w = 16;
jack_h = 13.5;
jack_z = 4;              // jack bottom above the protoboard's top face
jack_yc = 15;            // jack centre across the board: the Timer sits on the centre line
timer_gap = 2.5;         // protoboard top to the underside of the Timer board (its pin strips)

/* [Case] */
fit = 0.25;              // board to body, lid parts to body
head = 4;                // spare height above stack_h, for the wires on top
end_room = 1;            // the jack's face sits this far inside the end wall's outer face
wall = 2.0;              // also the floor
lid_t = 2.0;
post_d = 4.6;
m3_tap = 2.7;            // hole an M3 screw cuts its own thread into
m3_free = 3.4;
lug_d = 6.5;
boss_d = 5.4;            // lid screw columns inside the Ethernet-end corners

/* [Slide rail] */
flare = 2.0;             // dovetail: the foot widens this much towards its underside, each side
land = 0.6;              // flat edge of the foot
slide_fit = 0.25;        // clearance between foot and base
plate_t = 2.4;
rail_w = 2.0;            // thickness of a rail at the foot's edge
rail_top = 1.2;          // the rails stop this far below where the case's sides start
stop_t = 1.5;
bump_h = 1.0;            // click height
tongue = [22, 5];        // spring tongue length, width
tongue_y = 4.4;          // tongue centre from the y = 0 edge, clear of the pipe clip's neck

/* [Pipe clip] */
pipe_od = pipe == "3/4" ? 26.67 : 21.34;
pipe_clear = 0.2;
clip_wall = pipe == "3/4" ? 2.6 : 2.2;
clip_open = 100;         // mouth angle; faces sideways so the case hangs from solid plastic
clip_gap = 5;            // plate to clip, room for the zip tie slot
grip_l = 40;             // length of the full clip, from the far end
tie = [6, 2.8];          // zip tie slot
boss_t = 6.5;            // set screw boss: an M3 x 8 or x 10 reaches the pipe
nut = [5.7, 2.8];        // M3 nut slot: across flats, thickness

/* [Strap saddle] */
strap = [21, 4.2];       // tunnel for a 20 mm strap
saddle_h = 11;
vee = [26, 5];           // groove that sits on the pole: width, depth

/* [Hidden] */
$fn = 72;
e = 0.01;
floor_t = wall;
zbt = floor_t + under_h;             // underside of the protoboard
T = zbt + board_t;                   // its top face
H = stack_h + head;                  // inside height above the board
ztop = T + H;                        // top of the walls
jack_over = timer_over + jack_out;   // jack face past the A end
xj = -jack_over;                     // the jack's face; the bases stop the body here
xa = xj - end_room;                  // Ethernet end of the body
xb = board_l + fit + wall;           // far end
yo = fit + wall;                     // body outer face beyond the board edge
ins = rail_w + slide_fit;            // the foot's edge sits this far inside the case's side
dt = land + flare;                   // height of the dovetail
ch = ins + flare;                    // height of the 45 degree edge that brings the case back out to full width
zr = dt + ch - rail_top;             // top of a rail
zb = -slide_fit - plate_t;           // underside of a base plate
wg = 0.2;
xs0 = xj - wg - stop_t;              // Ethernet end of a base
cy = board_w / 2;
boss_x = xa + wall + 2.6;            // lid screw columns inside the Ethernet-end corners
boss_y = 1.2;
lug_xc = xb + 0.6;                   // lid screw lug outside the far end
lug_z = dt + ch + 0.8;
clip_id = pipe_od + pipe_clear;
zc = zb - (clip_gap + clip_wall + clip_id / 2);
tie_x = [xs0 + 16, xb - 20];
xt1 = xb - 4;                        // free end of the tongue
xt0 = xt1 - tongue[0];
xd = xt1 - 3.4;                      // top of the click bump
yd = tongue_y;
strap_x = (xs0 + xb) / 2 - strap[0] / 2;
holes = [for (x = [mh_inset, board_l - mh_inset], y = [mh_inset, board_w - mh_inset]) [x, y]];
timer_x1 = timer_over < 0 ? 0 : 63 - timer_over;   // far end of the Timer board

echo(str("CASE: ", xb - xa, " (", lug_xc + lug_d / 2 - xa, " over the lid lug) x ", board_w + 2 * yo, " x ", ztop + lid_t));
echo(str("BASE: ", xb - xs0, " x ", board_w + 2 * yo, ", ", -zb, " below the case; pvc ", pipe, " adds ", zb - zc + clip_id / 2 + clip_wall + boss_t, " more; clip mouth ", clip_id * sin(clip_open / 2), " for pipe ", pipe_od));

module box(a, b) { translate(a) cube([b[0] - a[0], b[1] - a[1], b[2] - a[2]]); }
// extrude a (y, z) outline along x
module along_x(x0, x1) { translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) children(); }
// extrude an (x, z) outline along y
module along_y(y0, y1) { translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children(); }
module both_sides() { children(); translate([0, board_w, 0]) mirror([0, 1, 0]) children(); }

// ---------------------------------------------------------------- body

// The case's outline across the board, up to height `top`: the foot, then the 45 degree
// edges out to full width, then straight sides.
module shell2d(top = ztop) {
    w = board_w;
    polygon([[-yo + ins, 0], [-yo + ins, land], [-yo + ins + flare, dt], [-yo, dt + ch], [-yo, top],
             [w + yo, top], [w + yo, dt + ch], [w + yo - ins - flare, dt], [w + yo - ins, land], [w + yo - ins, 0]]);
}

// Lid screws: nothing sticks out of the long sides, so that a base is flush with them.
// Two columns stand inside the Ethernet-end corners, beside the Timer's overhang, and one
// lug is on the outside of the far end wall.
module corner_boss() {
    // the y = 0 side; both_sides() makes the other
    hull() {
        translate([boss_x, boss_y, floor_t - e]) cylinder(d = boss_d, h = ztop - floor_t + e);
        box([xa + wall - e, -fit - e, floor_t - e], [boss_x, boss_y + boss_d / 2, ztop]);
        box([xa + wall - e, -fit - e, floor_t - e], [boss_x + boss_d / 2, boss_y, ztop]);
    }
}
module end_lug() {
    // sloped underneath so it prints without support
    hull() {
        translate([lug_xc, cy, lug_z + 4.6]) cylinder(d = lug_d, h = ztop - lug_z - 4.6);
        box([xb - e, cy - lug_d / 2, lug_z], [xb, cy + lug_d / 2, ztop]);
    }
}
module lid_screws(d, z0, h) {
    both_sides() translate([boss_x, boss_y, z0]) cylinder(d = d, h = h);
    translate([lug_xc, cy, z0]) cylinder(d = d, h = h);
}

// one corner post: a column under a mounting hole, joined to the side wall beside it
module post(p) {
    side = p[1] < cy ? -fit - e : board_w + fit + e;
    hull() {
        translate([p[0], p[1], floor_t - e]) cylinder(d = post_d, h = zbt - floor_t + e);
        box([p[0] - post_d / 2, min(side, p[1]), floor_t - e], [p[0] + post_d / 2, max(side, p[1]), zbt]);
    }
}

module body() {
    difference() {
        union() {
            difference() {
                union() {
                    along_x(xa, xb) shell2d();
                    end_lug();
                }
                // inside: the outline, one wall in. At the Ethernet end the floor starts
                // further in, behind the sloped edge that meets the base's stop.
                difference() {
                    along_x(xa + wall, board_l + fit) offset(delta = -wall) shell2d(ztop + 10);
                    box([xa, -50, -1], [xj + dt + wall, 100, dt + 1 + wall]);
                }
            }
            intersection() {
                union() {
                    for (p = holes) post(p);
                    both_sides() corner_boss();
                }
                along_x(xa, xb) shell2d();
            }
        }
        // the corner screws
        for (p = holes) translate([p[0], p[1], zbt - 7]) cylinder(d = mh_tap, h = 8);
        // Ethernet jack: a slot open to the top, so the board drops in
        box([xa - 1, jack_yc - jack_w / 2 - 0.4, T + jack_z - 0.5], [xa + wall + 1, jack_yc + jack_w / 2 + 0.4, ztop + 1]);
        // vents beside the PoE module
        for (y = [-yo - 1, board_w + fit - 1], i = [0 : 4])
            box([8 + i * 7, y, ztop - 13], [10 + i * 7, y + wall + 2, ztop - 2]);
        // lid screw holes
        lid_screws(m3_tap, ztop - 14, 15);
        // the Ethernet end's bottom edge, sloped to meet the base's stop
        along_y(-50, board_w + 50) polygon([[xa - 1, -1], [xj + dt + 1, -1], [xa - 1, xj + dt - xa + 1]]);
        // click recess
        box([xd - bump_h + 0.2, yd - tongue[1] / 2 - 0.6, -e], [xd + 3.2, yd + tongue[1] / 2 + 0.6, bump_h]);
    }
}

// ---------------------------------------------------------------- lid

module lid() {
    jz = T + jack_z + jack_h + 0.4;
    difference() {
        union() {
            box([xa, -yo, ztop], [xb, board_w + yo, ztop + lid_t]);
            hull() {
                translate([lug_xc, cy, ztop]) cylinder(d = lug_d, h = lid_t);
                box([xb - 1, cy - lug_d / 2, ztop], [xb, cy + lug_d / 2, ztop + lid_t]);
            }
            // ribs that locate the lid between the long walls
            both_sides() for (x = [22, 48]) box([x, -fit + fit, ztop - 2], [x + 10, 1.2, ztop + e]);
            // wall above the Ethernet jack
            box([xa, jack_yc - jack_w / 2 - 0.4 + fit, jz], [xa + wall, jack_yc + jack_w / 2 + 0.4 - fit, ztop + e]);
        }
        lid_screws(m3_free, ztop - 1, lid_t + 2);
    }
}

// ---------------------------------------------------------------- bases

module base2d() {
    difference() {
        translate([-yo, zb]) square([board_w + 2 * yo, zr - zb]);
        offset(delta = slide_fit) shell2d(ztop + 10);
    }
}

// plate, rails, stop and click tongue: the part every base shares
module base_rail() {
    difference() {
        union() {
            along_x(xs0, xb) base2d();
            // stop: a slope the body's end runs onto, so it prints standing on the far end
            along_y(-yo, board_w + yo)
                polygon([[xs0, zb], [xj + dt - wg - zb, zb], [xj - wg, dt], [xs0, dt]]);
        }
        // slot round the tongue
        difference() {
            box([xt0, yd - tongue[1] / 2 - 1, zb - 1], [xt1 + 1, yd + tongue[1] / 2 + 1, 1]);
            box([xt0 - 1, yd - tongue[1] / 2, zb - 2], [xt1, yd + tongue[1] / 2, 2]);
        }
    }
    // click bump: steep on the Ethernet side, which holds; gentle on the far side, which
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
        box([xs0, -yo, zb - saddle_h], [xb, board_w + yo, zb + e]);
        along_x(xs0 - 1, xb + 1) polygon([[cy - vee[0] / 2, zb - saddle_h - e], [cy, zb - saddle_h + vee[1]], [cy + vee[0] / 2, zb - saddle_h - e]]);
        box([strap_x, -yo - 1, zb - strap[1]], [strap_x + strap[0], board_w + yo + 1, zb + 1]);
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

pitch = 2.54;
col0 = (board_l - 23 * pitch) / 2;   // x of column A
row1 = (board_w - 9 * pitch) / 2;    // y of row 1
function colx(i) = col0 + i * pitch; // i: 0 = A
function rowy(r) = row1 + (r - 1) * pitch;

module electronics() {
    // protoboard
    color("goldenrod") difference() {
        box([0, 0, zbt], [board_l, board_w, T]);
        for (p = holes) translate([p[0], p[1], zbt - 1]) cylinder(d = 2.2, h = board_t + 2);
    }
    // the four M2 screw heads
    color("silver") for (p = holes) translate([p[0], p[1], T]) cylinder(d = 3.8, h = 1.6);
    // Timer: its board on pin strips in rows 2 and 9, columns B to Q
    color("black") for (r = [2, 9]) box([colx(1) - 1.27, rowy(r) - 1.27, T], [colx(16) + 1.27, rowy(r) + 1.27, T + timer_gap]);
    color("royalblue") box([-timer_over, cy - 10.5, T + timer_gap], [timer_x1, cy + 10.5, T + timer_gap + 1.6]);
    color("lightgray") box([xj, jack_yc - jack_w / 2, T + jack_z], [xj + 21, jack_yc + jack_w / 2, T + jack_z + jack_h]);
    color("dimgray") box([xj + 22, cy - 10.5, T + 10], [timer_x1 - 8, cy + 10.5, T + stack_h]);
    // Node, under the board: pins in rows 2 and 8, columns R to X, component side down
    ncx = (colx(17) + colx(23)) / 2;
    ncy = (rowy(2) + rowy(8)) / 2;
    color("black") for (r = [2, 8]) box([colx(17) - 1.27, rowy(r) - 1.27, zbt - 2.5], [colx(23) + 1.27, rowy(r) + 1.27, zbt]);
    color("dimgray") box([ncx - 10.5, ncy - 8.9, zbt - 2.5 - 1.2], [ncx + 10.5, ncy + 8.9, zbt - 2.5]);
    color("gainsboro") box([ncx - 6, ncy - 6, zbt - 2.5 - 1.2 - 2.4], [ncx + 6, ncy + 6, zbt - 2.5 - 1.2]);
    color("lightgray") box([ncx + 10.5 - 7.3, ncy - 4.5, zbt - 2.5 - 1.2 - 3.2], [ncx + 10.5, ncy + 4.5, zbt - 2.5 - 1.2]);
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
    if (check_n == 3) intersection() { union() { body(); lid(); } the_base(base); }
    if (check_n == 4) intersection() { base_pvc(); pipe_solid(); }
} else {
    color("steelblue") body();
    electronics();
    if (show_lid) translate([0, 0, explode]) color("orange", 0.85) lid();
    translate([0, 0, -explode]) color("seagreen") the_base(base);
    if (base == "pvc") color("white", 0.6) translate([0, 0, -explode]) pipe_solid();
}
