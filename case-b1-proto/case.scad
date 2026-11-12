// OFT build B1: case for the protoboard build, snap-on mount for 1/2 in PVC pipe.
//
// The protoboard hangs under the gate's top bar, components (and the C5) facing the ground,
// long axis along the pipe, Ethernet leaving along the pipe.
//
// Two printed parts:
//   tray    sits against the pipe. The board drops in solder side first. Carries the pipe
//           clip. Print standing on its USB end (x axis up), no supports.
//   cover   faces the ground. Drops over the components, its rim clamps the board edges and
//           clicks into the tray. Print top face down, no supports.
//
// Coordinates: x along the pipe (board 0..board_l, Ethernet jack at x < 0, USB at x > board_l),
// y across (0 = the Timer's long edge), z from the tray floor towards the ground.

part = "assembly"; // [assembly, tray, cover, check]
explode = 0;
show_cover = true;
check_n = 0;

/* [Measured] */
board_l = 57;
board_w = 51;
board_t = 1.0;
pins = 1.2;              // solder joints below the board
stack_h = 17;            // tallest part above the board's top face, as measured
jack_over = 16;          // Ethernet jack overhang past the board end
jack_w = 16;
jack_h = 13;
jack_z = 4;              // jack bottom above the board's top face
jack_yc = 13;            // jack centre from the Timer's long edge (same line as its USB-C)
usb_yc = [13, 35];       // Timer, C5
usb_z = 4;               // bottom of each USB-C port above the board's top face
c5_h = 7;

/* [Fit] */
fit = 0.2;               // board to tray, cover to tray
head = 6;                // spare height above stack_h (the PoE module looked taller in photos)
floor_t = 1.6;
wall_o = 1.6;            // tray outer wall
step_w = 1.2;            // tray step the cover rim sits on
ledge_w = 1.0;           // tray ledge under the board edge
cover_w = 2.0;           // cover wall; overlaps the board edge by cover_w - step_w
top_t = 1.6;
lap = 4;                 // tray wall height above the board (overlap with the cover)
usb_open = [13, 7.5];    // opening for a USB-C plug body
bump = 0.45;             // click ridge height

/* [Pipe clip] */
pipe_od = 21.34;
pipe_clear = 0.2;
clip_wall = 2.2;
clip_open = 100;         // mouth angle; faces sideways so the case hangs from solid plastic
clip_gap = 5;            // floor to clip, room for the zip tie slot
grip_l = 40;             // length of the full clip, from the USB end
tie = [6, 2.8];          // zip tie slot

/* [Hidden] */
$fn = 72;
e = 0.01;
pocket = pins + 1.0;                 // depth below the board
T = floor_t + pocket + board_t;      // z of the board's top face
H = stack_h + head;                  // inside height above the board
x0 = -jack_over;                     // Ethernet end of the case
x1 = board_l + fit + step_w + wall_o; // USB end
yo = fit + step_w + wall_o;          // tray outer face beyond the board edge
yc = fit + step_w - fit;             // cover outer face beyond the board edge
clip_id = pipe_od + pipe_clear;
zc = -(clip_gap + clip_wall + clip_id / 2);
tie_x = [x0 + 12, x1 - 20];
bump_z = T + 2.2;

echo(str("OUTER SIZE: ", x1 - x0, " x ", board_w + 2 * yo, " x ", T + H + top_t, " (plus clip ", -zc + clip_id / 2 + clip_wall, ")"));
echo(str("clip mouth ", clip_id * sin(clip_open / 2), " for pipe ", pipe_od));

module box(a, b) { translate(a) cube([b[0] - a[0], b[1] - a[1], b[2] - a[2]]); }

module clip2d(full) {
    // (u, v): u = across, v = towards the ground, origin on the pipe axis
    difference() {
        union() {
            circle(d = clip_id + 2 * clip_wall);
            translate([-7, 0]) square([14, -zc]);
        }
        circle(d = clip_id);
        if (full) polygon([[0, 0], 40 * [cos(clip_open / 2), sin(clip_open / 2)], 40 * [1, 0], 40 * [cos(clip_open / 2), -sin(clip_open / 2)]]);
        else translate([0, -40]) square([40, 40 - zc - clip_gap + clip_wall + clip_id / 2 - 2]);
    }
    if (full) for (s = [-1, 1])   // rounded lips
        rotate(s * clip_open / 2) translate([clip_id / 2 + clip_wall / 2, 0]) circle(d = clip_wall);
}

module clip() {
    difference() {
        translate([0, board_w / 2, zc]) rotate([90, 0, 90]) {
            translate([0, 0, x1 - grip_l]) linear_extrude(grip_l) clip2d(true);
            translate([0, 0, x0]) linear_extrude(x1 - grip_l - x0 + e) clip2d(false);
        }
        box([x0 - 1, -50, 0], [x1 + 1, 100, 50]);
        for (x = tie_x) box([x - tie[0] / 2, -50, -1 - tie[1]], [x + tie[0] / 2, 100, -1]);
    }
}

module usb_cut(xa, xb) {
    for (y = usb_yc) box([xa, y - usb_open[0] / 2, T + usb_z + 1.6 - usb_open[1] / 2], [xb, y + usb_open[0] / 2, T + 60]);
}

module tray() {
    difference() {
        union() {
            box([x0, -yo, 0], [x1, board_w + yo, floor_t]);
            for (s = [0, 1]) mirror([0, s, 0]) translate([0, s * -board_w, 0]) {
                box([x0, -yo, 0], [x1, -fit - step_w, T + lap]);          // outer wall
                box([x0, -yo, 0], [x1, -fit, T]);                         // step
                box([0, -yo, 0], [board_l, ledge_w, T - board_t]);        // ledge
            }
            box([board_l + fit + step_w, -yo, 0], [x1, board_w + yo, T + lap]);
            box([board_l + fit, -yo, 0], [x1, board_w + yo, T]);
            box([board_l - 0.8, -yo, 0], [x1, board_w + yo, T - board_t]);
            // stop and ledge at the Ethernet end, beside the Timer; sloped so it prints on end
            hull() {
                box([-fit - step_w, 28, 0], [-fit, board_w + fit, T]);
                box([-fit, 28, 0], [2, board_w + fit, T - board_t]);
                box([2, 28, floor_t - e], [2 + pocket + 1, board_w + fit, floor_t]);
            }
        }
        // the hull above fills the board's corner; clear it again
        box([-fit, -fit, T - board_t], [board_l + fit, board_w + fit, T + 60]);
        usb_cut(board_l, x1 + 1);
        // click grooves
        for (y = [-fit - step_w, board_w + fit + step_w])
            translate([8, y, bump_z]) rotate([0, 90, 0]) cylinder(r = bump + 0.1, h = 34);
    }
    clip();
}

module cover() {
    ztop = T + H + top_t;
    xe = board_l + yc;
    difference() {
        union() {
            box([x0, -yc, T], [xe, board_w + yc, ztop]);
            box([x0, 0, floor_t + fit], [x0 + cover_w, board_w, ztop]);            // Ethernet end wall, down to the floor
            for (y = [-yc, board_w + yc])
                translate([10, y, bump_z]) rotate([0, 90, 0]) cylinder(r = bump, h = 30);
        }
        box([x0 + cover_w, cover_w - yc, T - e], [xe - cover_w, board_w + yc - cover_w, T + H]);
        // Ethernet jack, open towards the tray so the cover drops over it
        box([x0 - 1, jack_yc - jack_w / 2 - 0.4, 0], [x0 + cover_w + 1, jack_yc + jack_w / 2 + 0.4, T + jack_z + jack_h + 0.4]);
        // board ends and USB plugs at the USB end
        box([xe - cover_w - 1, 2, T - 1], [xe + 1, 44.5, T + usb_z + 1.6 + usb_open[1] / 2]);
        // vents over the PoE module and the C5
        for (y = [-yc - 1, board_w + yc - cover_w - 1], i = [0 : 5])
            box([8 + i * 7, y, T + H - 11], [10 + i * 7, y + cover_w + 2, T + H - 1]);
        // zip tie guides
        for (x = tie_x) box([x - tie[0] / 2, -50, ztop - 0.6], [x + tie[0] / 2, 100, ztop + 1]);
    }
}

// what goes inside, for pictures and the interference check
module electronics() {
    color("goldenrod") box([0, 0, T - board_t], [board_l, board_w, T]);
    color("silver") for (i = [0 : 19], y = [4.1, 21.9, 27.4, 42.6]) if (y < 25 || i < 7)
        translate([board_l - 2 - i * 2.54, y, T - board_t - pins]) cylinder(d = 1.2, h = pins);
    color("royalblue") box([-7, 2.5, T + 2.5], [board_l, 23.5, T + 4]);
    color("lightgray") box([-jack_over, jack_yc - jack_w / 2, T + jack_z], [5, jack_yc + jack_w / 2, T + jack_z + jack_h]);
    color("dimgray") box([6, 2.5, T + 10], [48, 23.5, T + stack_h]);
    color("dimgray") box([board_l - 23, 26, T], [board_l - 2, 44, T + 1.2]);
    color("gainsboro") box([board_l - 20, 29, T + 1.2], [board_l - 8, 41, T + c5_h]);
    color("lightgray") for (y = usb_yc) box([board_l - 6, y - 4.5, T + usb_z], [board_l + 2, y + 4.5, T + usb_z + 3.2]);
}
module usb_plugs() {
    for (y = usb_yc) box([board_l + 2 - 6, y - 6.2, T + usb_z + 1.6 - 3.3], [board_l + 30, y + 6.2, T + usb_z + 1.6 + 3.3]);
}
module pipe() { color("white", 0.6) translate([x0 - 40, board_w / 2, zc]) rotate([0, 90, 0]) cylinder(d = pipe_od, h = x1 - x0 + 80); }

if (part == "tray") rotate([0, 90, 0]) tray();
else if (part == "cover") rotate([180, 0, 0]) cover();
else if (part == "check") {
    if (check_n == 0) intersection() { tray(); cover(); }
    if (check_n == 1) intersection() { union() { tray(); cover(); } electronics(); }
    if (check_n == 2) intersection() { union() { tray(); cover(); } usb_plugs(); }
    if (check_n == 3) intersection() { tray(); pipe(); }
} else {
    color("steelblue") tray();
    electronics();
    if (show_cover) translate([0, 0, explode]) color("orange", 0.85) cover();
    pipe();
}
