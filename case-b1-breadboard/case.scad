// OFT build B1: breadboard test-fit case with a 1/2 in PVC pipe mount.
// First draft, drawn before any hardware was measured. Read README.md, and check the
// "measure before printing" list against the real parts before committing filament.
//
// Parts (select with `part`, or run ./build.sh to export all of them):
//   base      tub that holds the breadboard; RJ45 notch, vents, clip screw holes
//   lid       flat lid with hold-down legs, antenna window skin and the USB/BOOT hatch opening
//   hatch     cover for the lid opening over the Timer's USB-C and BOOT/RESET buttons
//   bulkhead  slide-in card between the Timer and the Node; wrap it in foil (HBOM box rules)
//   clip      snap-on C-clip for the pipe; screws under the base. Print two.
//   assembly  everything in place with mock electronics (preview only, not for printing)
//
// Coordinates: X runs along the case from the Ethernet end (x = 0 is the inside face of that
// end wall) to the antenna end. Y is across, 0 on the breadboard centreline. Z is up, 0 on
// the cavity floor. All dimensions in mm.

/* [What to build] */
part = "assembly"; // [assembly, base, lid, hatch, bulkhead, clip, check]
// Pipe direction for the assembly view only: "along" the case or "across" it
pipe_dir = "along"; // [along, across]
// Assembly view options
show_lid = true;
show_mock = true;
explode = 0;

/* [Breadboard: ASSUMED, measure yours] */
// "full" = 830-point, "half" = 400-point, "custom" = use the bb_custom_* values
bb_preset = "full"; // [full, half, custom]
bb_custom_l = 165;
bb_custom_w = 55;
bb_custom_row1 = 3.8;
bb_custom_timer_row = 9;
// Breadboard thickness including any adhesive foam backing
bb_h = 9.5;
// Gap around the breadboard, each side (also swallows the dovetail nubs on its edges)
bb_clear = 0.5;
// Extra gap on every wall for a removable foil liner
liner_gap = 1.0;

bb_l = bb_preset == "full" ? 165 : bb_preset == "half" ? 82 : bb_custom_l;
bb_w = bb_preset == "custom" ? bb_custom_w : 55;
// Distance from the breadboard's end edge to the centre of its first row of holes
bb_row1 = bb_preset == "full" ? 3.8 : bb_preset == "half" ? 4.2 : bb_custom_row1;
// Breadboard row (counted from the Ethernet end) that takes the Timer's last pins, 16 and 17,
// the ones nearest the RJ45. Row 9 on a full-size board puts the RJ45 end of the Timer about
// level with the end of the breadboard. Row 1 on a half-size board hangs the RJ45 off the end.
timer_last_pin_row = bb_preset == "full" ? 9 : bb_preset == "half" ? 1 : bb_custom_timer_row;

/* [Timer: Waveshare RP2350-POE-ETH (from Waveshare's dimension drawing unless noted)] */
tm_l = 63.0;
tm_w = 21.0;
tm_pcb_t = 1.6;              // not on the drawing; standard thickness assumed
tm_rj45_over = 2.88;         // RJ45 overhang past the PCB end (65.88 - 63.00)
tm_rj45_w = 16.0;
tm_rj45_h = 13.5;            // ESTIMATE: jack height above the PCB, not on the drawing
tm_rj45_d = 21.5;            // ESTIMATE, only used by the mock
tm_lastpin_from_rj45_end = 23.55;  // 63 - (1.35 + 15 * 2.54)
tm_usbc_w = 8.95;
tm_boot_from_usb_end = 9.9;  // SCALED off the drawing, not dimensioned
tm_boot_y = 4.55;            // SCALED off the drawing: BOOT at +y, RESET at -y
// Height of the header's plastic spacer: the gap between breadboard top and PCB underside
hdr_gap = 2.5;
// PoE module, ALL ESTIMATED from Waveshare's product photo. It rides above the Timer on the
// 6-pin header, between the RJ45 and the USB-C end.
poe_l = 40;
poe_w = 24;
poe_top = 15;                // top of the PoE module above the top face of the Timer PCB
// Air above the tallest part (PoE module or RJ45) and room for jumper loops
headroom = 3.0;

/* [Node: Seeed XIAO ESP32-C5 (from Seeed's KiCad files)] */
xi_l = 21.0;
xi_w = 17.8;
xi_pin_inset = 2.88;         // (21 - 6 * 2.54) / 2: board end to the nearest pin row
// Rows between the XIAO's last pin and the antenna end of the breadboard (1 = last row)
xiao_row_from_end = 1;
// The XIAO's pin rows are 15.24 mm apart, so it cannot sit centred on a breadboard: its
// centre is 1.27 or 3.81 mm off the centreline. Only the mock uses this.
xiao_y_off = 1.27;

/* [Shell] */
wall = 2.0;
floor_t = 3.0;               // thick enough to countersink the clip screws flush
lid_t = 2.0;
corner_r = 3.0;
lip_h = 3.0;
lip_t = 1.6;
// Clearance between the lid lip and the tub wall, each side
fit = 0.25;
// Self-tapping pilot for M3 in printed plastic; use 4.0 for heat-set inserts
m3_pilot = 2.8;
m3_clear = 3.4;
ear_r = 4.2;
ear_off = 2.2;
screw_depth = 12;

/* [Antenna end] */
// Free length past the end of the breadboard for the antenna
ant_bay = 30;
// Thin RF window in the lid over the antenna bay and the XIAO's antenna end
window_w = 40;
window_skin = 0.8;           // 0 = open hole
// Notch in the antenna-end wall for a u.FL pigtail to an outside antenna
pigtail_slot_w = 3.0;
pigtail_slot_d = 5.0;
pigtail_y = 16;
// Optional SMA bulkhead hole in the antenna-end wall (the HBOM does not ask for one)
sma_hole = false;
sma_d = 6.5;

/* [Openings] */
rj45_side_clear = 1.5;
rj45_recess = 0.5;           // jack face sits this far inside the outer wall face
hatch_w = 18;
hatch_back = 14;             // hatch starts this far before the USB-C end (covers BOOT/RESET)
hatch_fwd = 42;              // and runs this far past it, for the plug and its cable
pinhole_d = 2.0;
// Jumper pass-through in the bulkhead card. Keep it well under 25 mm wide: it is a hole in
// the foil wall. Seven Dupont jumpers side by side need about 18 mm.
bulk_slot_w = 22;
bulk_slot_h = 6;
vent_w = 2.0;
vent_n = 6;
vent_pitch = 6.4;

/* [Pipe clip] */
// 1/2 in Schedule 40 PVC = 21.34 mm. 3/4 in = 26.67 mm.
pipe_od = 21.34;
// Added to the pipe diameter for the clip bore. Negative = grips tighter.
pipe_clear = -0.2;
clip_wall = 2.8;
// Width of the mouth as an angle; smaller = harder to snap on, holds better
clip_open_angle = 120;
clip_len = 40;
clip_flange_w = 40;
clip_flange_t = 5.0;
clip_neck = 3.0;
// Screw pattern is square so the clip can be turned 90 degrees
clip_hole_sq = 30;
// Distance between the two clip stations under the base
clip_spacing = bb_preset == "half" ? 60 : 70;
nut_af = 5.8;
nut_h = 2.6;
zip_w = 6;
zip_t = 2.3;

/* [Hidden] */
$fn = 64;
eps = 0.01;

// ---------------------------------------------------------------- derived
tm_rj45_face_x = -wall + rj45_recess;
tm_x0 = tm_rj45_face_x + tm_rj45_over;                 // RJ45 end of the Timer PCB
tm_usb_x = tm_x0 + tm_l;                               // USB-C end of the Timer PCB
bb_x0 = tm_x0 + tm_lastpin_from_rj45_end - bb_row1 - (timer_last_pin_row - 1) * 2.54;
bb_x1 = bb_x0 + bb_l;
assert(bb_x0 >= bb_clear, "Breadboard would pass through the Ethernet end wall: lower timer_last_pin_row");
cav_l = bb_x1 + bb_clear + ant_bay;
cav_w = bb_w + 2 * (bb_clear + liner_gap);
z_pcb = bb_h + hdr_gap;                                // underside of both module PCBs
z_tm_top = z_pcb + tm_pcb_t;
inner_h = z_tm_top + max(poe_top, tm_rj45_h) + headroom;
out_l = cav_l + 2 * wall;
out_w = cav_w + 2 * wall;
xi_ant_x = bb_x1 - bb_row1 - (xiao_row_from_end - 1) * 2.54 + xi_pin_inset;
xi_usb_x = xi_ant_x - xi_l;
bulk_x = max(tm_usb_x + 4, xi_usb_x - 12);
bulk_t = 1.6;
hatch_x0 = tm_usb_x - hatch_back;
hatch_x1 = min(tm_usb_x + hatch_fwd, bulk_x - 4);
hatch_xc = (hatch_x0 + hatch_x1) / 2;
hatch_boss_y = hatch_w / 2 + 5;
hatch_boss_h = 4;
win_x0 = max(xi_ant_x - 10, bulk_x + 6);
win_x1 = cav_l - fit - lip_t - 1;
rj_open_w = tm_rj45_w + 2 * rj45_side_clear;
rj_open_z0 = z_pcb - 2;
rj_tongue_z0 = z_tm_top + tm_rj45_h + 1;
ear_xs = [6, bulk_x - 9, cav_l - 6];
ear_y = out_w / 2 + ear_off;
clip_xc = cav_l / 2;
clip_xs = [clip_xc - clip_spacing / 2, clip_xc + clip_spacing / 2];
clip_id = pipe_od + pipe_clear;
clip_cv = clip_flange_t + clip_neck + clip_wall + clip_id / 2;   // bore centre above the flange base
clip_mouth = clip_id * sin(clip_open_angle / 2);       // gap between the lips, before the lead-in beads
assert(clip_mouth < pipe_od - 1.5, "Clip mouth is too wide to hold the pipe: lower clip_open_angle");
leg_xs = [bb_x0 + bb_l * 0.25, bb_x0 + bb_l * 0.75];
leg_len = 6;
leg_d = bb_clear + liner_gap - fit + 2.5;              // reaches 2.5 mm over the breadboard edge
vent_x0 = 14;
vent_z0 = z_tm_top + 2;
vent_z1 = inner_h - lip_h - 2;

echo(str("OUTER SIZE (without ears/clips): ", out_l, " x ", out_w, " x ", inner_h + floor_t + lid_t));
echo(str("WIDTH OVER SCREW EARS: ", 2 * (ear_y + ear_r)));
echo(str("bb_x0=", bb_x0, " tm_usb_x=", tm_usb_x, " bulk_x=", bulk_x, " xi_usb_x=", xi_usb_x,
         " xi_ant_x=", xi_ant_x, " cav_l=", cav_l, " inner_h=", inner_h));
echo(str("clip bore ", clip_id, ", mouth ", clip_mouth, " (pipe ", pipe_od, "), wrap ", 360 - clip_open_angle, " deg"));
echo(str("hatch x ", hatch_x0, "..", hatch_x1, "  window x ", win_x0, "..", win_x1));

// ---------------------------------------------------------------- helpers
module rbox(x0, x1, w, z0, z1, r) {
    translate([0, 0, z0]) linear_extrude(z1 - z0)
        translate([x0 + r, -w / 2 + r]) offset(r) square([x1 - x0 - 2 * r, w - 2 * r]);
}

module ears(z0, z1, hole_d, hole_z0) {
    for (x = ear_xs, s = [-1, 1]) difference() {
        hull() {
            translate([x, s * ear_y, z0]) cylinder(r = ear_r, h = z1 - z0);
            translate([x - ear_r, s * (out_w / 2 - 1) - 0.5, z0]) cube([2 * ear_r, 1, z1 - z0]);
        }
        translate([x, s * ear_y, hole_z0]) cylinder(d = hole_d, h = z1 - hole_z0 + eps);
    }
}

// ---------------------------------------------------------------- base
module base() {
    difference() {
        union() {
            rbox(-wall, cav_l + wall, out_w, -floor_t, inner_h, corner_r);
            ears(-floor_t, inner_h, m3_pilot, inner_h - screw_depth);
        }
        // cavity
        rbox(0, cav_l, cav_w, 0, inner_h + eps, 1.0);
        // RJ45: U-notch open to the rim, wide and deep enough for a booted plug and its latch
        translate([-wall - eps, -rj_open_w / 2, rj_open_z0]) cube([wall + 2 * eps, rj_open_w, inner_h]);
        // vents beside the PoE module, both sides
        for (i = [0 : vent_n - 1], s = [-1, 1]) {
            x = vent_x0 + i * vent_pitch;
            if (x + vent_w < bulk_x - 12)
                translate([x, s * (cav_w / 2 + wall / 2) - wall, vent_z0]) cube([vent_w, 2 * wall, vent_z1 - vent_z0]);
        }
        // u.FL pigtail notch in the antenna-end wall, with two zip-tie slots for strain relief
        translate([cav_l - eps, pigtail_y - pigtail_slot_w / 2, inner_h - pigtail_slot_d]) cube([wall + 2 * eps, pigtail_slot_w, pigtail_slot_d + eps]);
        for (dy = [-5.5, 5.5])
            translate([cav_l - eps, pigtail_y + dy - 0.9, inner_h - pigtail_slot_d - 5]) cube([wall + 2 * eps, 1.8, 3.4]);
        if (sma_hole)
            translate([cav_l - eps, -pigtail_y, inner_h - 12]) rotate([0, 90, 0]) cylinder(d = sma_d, h = wall + 2 * eps);
        // clip screws: M3 countersunk from inside, heads flush with the floor
        for (cx = clip_xs, dx = [-1, 1], dy = [-1, 1])
            translate([cx + dx * clip_hole_sq / 2, dy * clip_hole_sq / 2, 0]) {
                translate([0, 0, -floor_t - eps]) cylinder(d = m3_clear, h = floor_t + 2 * eps);
                translate([0, 0, -1.7]) cylinder(d1 = m3_clear, d2 = 6.6, h = 1.7 + eps);
            }
        // push-out hole under the breadboard, between the clip stations
        translate([clip_xc, 0, -floor_t - eps]) cylinder(d = 9, h = floor_t + 2 * eps);
        // finger scoop under the antenna end of the breadboard
        hull() {
            translate([bb_x1 - 6, -11, -floor_t + 1.0]) cube([14, 22, floor_t]);
            translate([bb_x1 - 4, -9, -eps]) cube([10, 18, eps]);
        }
    }
    // guide ribs for the bulkhead card, undersides at 45 degrees. They stay inside the side
    // clearance so the populated breadboard still drops straight in past them; the fins under
    // the lid do the rest of the holding.
    rib_p = liner_gap + bb_clear - 0.2;
    for (s = [-1, 1], d = [-1, 1])
        translate([bulk_x + d * (bulk_t / 2 + 0.25 + 0.6), s * cav_w / 2, 0])
            hull() {
                translate([-0.6, s > 0 ? -rib_p : 0, bb_h + 1 + rib_p]) cube([1.2, rib_p, inner_h - lip_h - 0.3 - (bb_h + 1 + rib_p)]);
                translate([-0.6, s > 0 ? -eps : 0, bb_h + 1]) cube([1.2, eps, 1]);
            }
}

// ---------------------------------------------------------------- lid
module lid() {
    difference() {
        union() {
            rbox(-wall, cav_l + wall, out_w, inner_h, inner_h + lid_t, corner_r);
            ears(inner_h, inner_h + lid_t, m3_clear, inner_h - eps);
            // locating lip
            difference() {
                rbox(fit, cav_l - fit, cav_w - 2 * fit, inner_h - lip_h, inner_h + eps, 1.0);
                rbox(fit + lip_t, cav_l - fit - lip_t, cav_w - 2 * fit - 2 * lip_t, inner_h - lip_h - eps, inner_h + 2 * eps, 0.5);
            }
            // hold-down legs: press on the long edges of the breadboard
            for (x = leg_xs, s = [-1, 1])
                translate([x - leg_len / 2, s > 0 ? cav_w / 2 - fit - leg_d : -cav_w / 2 + fit, bb_h + 0.4])
                    cube([leg_len, leg_d, inner_h - bb_h - 0.4 + eps]);
            // tongue that closes the RJ45 notch above the jack
            translate([-wall, -rj_open_w / 2 + 0.3, rj_tongue_z0]) cube([wall, rj_open_w - 0.6, inner_h - rj_tongue_z0 + eps]);
            // fins that trap the top edge of the bulkhead card
            for (s = [-1, 1], d = [-1, 1])
                translate([bulk_x + d * (bulk_t / 2 + 0.25 + 0.6) - 0.6, s * 12 - 4, inner_h - 4]) cube([1.2, 8, 4 + eps]);
            // bosses for the hatch screws
            for (s = [-1, 1]) translate([hatch_xc, s * hatch_boss_y, inner_h - hatch_boss_h]) cylinder(r = 3.5, h = hatch_boss_h + eps);
        }
        // hatch opening over the Timer's USB-C end and buttons
        translate([hatch_x0, -hatch_w / 2, inner_h - eps]) cube([hatch_x1 - hatch_x0, hatch_w, lid_t + 2 * eps]);
        for (s = [-1, 1]) translate([hatch_xc, s * hatch_boss_y, inner_h - hatch_boss_h - eps]) cylinder(d = m3_pilot, h = hatch_boss_h + lid_t + 2 * eps);
        // antenna window: thin skin (or open if window_skin = 0)
        translate([win_x0, -window_w / 2, inner_h - eps]) cube([win_x1 - win_x0, window_w, lid_t - window_skin + eps + (window_skin == 0 ? eps : 0)]);
        // let the pigtail pass the lip
        translate([cav_l - fit - lip_t - 1, pigtail_y - pigtail_slot_w / 2 - 0.5, inner_h - lip_h - eps]) cube([lip_t + 2, pigtail_slot_w + 1, lip_h + eps]);
    }
}

// ---------------------------------------------------------------- hatch cover
hatch_t = 2.0;
module hatch() {
    z0 = inner_h + lid_t;
    difference() {
        union() {
            hull() {
                rbox(hatch_x0 - 4, hatch_x1 + 4, hatch_w + 8, z0, z0 + hatch_t, 2);
                for (s = [-1, 1]) translate([hatch_xc, s * hatch_boss_y, z0]) cylinder(r = 5, h = hatch_t);
            }
            // plug that drops into the opening
            translate([hatch_x0 + 0.3, -hatch_w / 2 + 0.3, inner_h]) cube([hatch_x1 - hatch_x0 - 0.6, hatch_w - 0.6, lid_t + eps]);
        }
        for (s = [-1, 1]) translate([hatch_xc, s * hatch_boss_y, z0 - eps]) cylinder(d = m3_clear, h = hatch_t + 2 * eps);
        // pinholes over BOOT (+y) and RESET (-y)
        for (s = [-1, 1]) translate([tm_usb_x - tm_boot_from_usb_end, s * tm_boot_y, inner_h - eps]) cylinder(d = pinhole_d, h = lid_t + hatch_t + 2 * eps);
        // a dot marks BOOT
        translate([tm_usb_x - tm_boot_from_usb_end, tm_boot_y + 3.5, z0 + hatch_t - 0.4]) cylinder(d = 1.6, h = 0.5);
    }
}

// ---------------------------------------------------------------- bulkhead card
module bulkhead() {
    z0 = bb_h + 0.3;
    z_step = inner_h - lip_h - 0.4;
    w_full = cav_w - 0.8;
    w_top = cav_w - 2 * (fit + lip_t) - 0.8;
    translate([bulk_x - bulk_t / 2, 0, 0]) difference() {
        union() {
            translate([0, -w_full / 2, z0]) cube([bulk_t, w_full, z_step - z0]);
            translate([0, -w_top / 2, z_step - eps]) cube([bulk_t, w_top, inner_h - 0.3 - z_step]);
        }
        // jumper pass-through at the breadboard surface
        translate([-eps, -bulk_slot_w / 2, z0 - eps]) cube([bulk_t + 2 * eps, bulk_slot_w, bulk_slot_h]);
    }
}

// ---------------------------------------------------------------- pipe clip
// Local frame: profile in XY (X across, Y away from the case), extruded along Z (pipe axis).
// This is also the print orientation.
module clip() {
    ro = clip_id / 2 + clip_wall;
    ha = clip_open_angle / 2;
    difference() {
        linear_extrude(clip_len, center = true) {
            translate([-clip_flange_w / 2, 0]) square([clip_flange_w, clip_flange_t]);
            translate([-7, clip_flange_t - eps]) square([14, clip_cv - clip_flange_t]);
            translate([0, clip_cv]) {
                difference() {
                    circle(r = ro);
                    polygon([[0, 0], [2 * ro * sin(ha), 2 * ro * cos(ha)], [2 * ro, 3 * ro], [-2 * ro, 3 * ro], [-2 * ro * sin(ha), 2 * ro * cos(ha)]]);
                }
                // rounded lips, pushed out a little as a lead-in
                for (s = [-1, 1]) translate([s * (clip_id / 2 + clip_wall / 2 + 0.3) * sin(ha), (clip_id / 2 + clip_wall / 2 + 0.3) * cos(ha)]) circle(d = clip_wall + 0.6);
            }
        }
        // bore
        translate([0, clip_cv, 0]) cylinder(d = clip_id, h = clip_len + 1, center = true);
        // zip-tie tunnel through the neck
        translate([-10, clip_flange_t + 0.3, -zip_w / 2]) cube([20, zip_t, zip_w]);
        // screws and nut pockets
        for (sx = [-1, 1], sz = [-1, 1]) translate([sx * clip_hole_sq / 2, 0, sz * clip_hole_sq / 2]) rotate([-90, 0, 0]) {
            translate([0, 0, -eps]) cylinder(d = m3_clear, h = clip_flange_t + 2 * eps);
            translate([0, 0, clip_flange_t - nut_h]) cylinder(d = nut_af / cos(30), h = nut_h + eps, $fn = 6);
        }
    }
}

// clip placed under the base at station x, along or across the case
module clip_placed(x) {
    translate([x, 0, -floor_t]) rotate([0, 0, pipe_dir == "across" ? 90 : 0]) rotate([0, 90, 0]) rotate([0, 0, -90]) clip();
}

// ---------------------------------------------------------------- mock electronics (preview)
module mock_timer() {
    // breadboard
    color("ivory") translate([bb_x0, -bb_w / 2, 0]) cube([bb_l, bb_w, bb_h]);
    // Timer
    color("royalblue") translate([tm_x0, -tm_w / 2, z_pcb]) cube([tm_l, tm_w, tm_pcb_t]);
    color("silver") translate([tm_rj45_face_x, -tm_rj45_w / 2, z_tm_top]) cube([tm_rj45_d, tm_rj45_w, tm_rj45_h]);
    color("silver") translate([tm_usb_x - 6, -tm_usbc_w / 2, z_tm_top]) cube([7.3, tm_usbc_w, 3.2]);
    color("white") for (s = [-1, 1]) translate([tm_usb_x - tm_boot_from_usb_end, s * tm_boot_y, z_tm_top]) cylinder(d = 3, h = 2);
    color("dimgray") for (s = [-1, 1]) translate([tm_x0 + tm_lastpin_from_rj45_end, s * 8.89 - 1.27, bb_h]) cube([15 * 2.54 + 2.54, 2.54, hdr_gap]);
    // PoE module (estimated)
    color("black") translate([tm_x0 + 19, -poe_w / 2, z_tm_top + poe_top - 3.6]) cube([poe_l, poe_w, 1.6]);
    color("goldenrod") translate([tm_x0 + 30, -7, z_tm_top + 2]) cube([16, 14, poe_top - 5.6]);
    color("black") translate([tm_x0 + 19, -poe_w / 2 + 2, z_tm_top + poe_top - 2]) cube([poe_l - 6, poe_w - 4, 2]);
}
// a USB-C plug in the Timer, to show the trench under the hatch
module mock_plug() {
    color("orange", 0.6) translate([tm_usb_x - 5, -6, z_tm_top - 1.7]) cube([6.7 + 22, 12, 6.5]);
}
module mock_node() {
    color("dimgray") translate([xi_usb_x, xiao_y_off - xi_w / 2, z_pcb]) cube([xi_l, xi_w, 1.2]);
    color("silver") translate([xi_usb_x - 1.5, xiao_y_off - 4.5, z_pcb + 1.2]) cube([7.3, 9, 3.2]);
    color("gold") translate([xi_ant_x - 1.5, xiao_y_off, z_pcb + 1.2]) cylinder(d = 2.6, h = 1.2);
    // whip antenna lying in the antenna bay
    color("red") translate([xi_ant_x + 12, -22, z_pcb + 2]) rotate([-90, 0, 0]) cylinder(d = 3, h = 44);
}
module mock_pipe(d = pipe_od) {
    pipe_l = 260;
    color("white", 0.5)
        if (pipe_dir == "along") translate([cav_l / 2 - pipe_l / 2, 0, -floor_t - clip_cv]) rotate([0, 90, 0]) cylinder(d = d, h = pipe_l);
        else translate([clip_xs[0], -pipe_l / 2, -floor_t - clip_cv]) rotate([-90, 0, 0]) cylinder(d = d, h = pipe_l);
}
module mock() { mock_timer(); mock_plug(); mock_node(); mock_pipe(); }
module clips() {
    if (pipe_dir == "along") for (x = clip_xs) clip_placed(x);
    else clip_placed(clip_xs[0]);
}

module assembly() {
    color("slategray") base();
    if (show_lid) translate([0, 0, explode]) {
        color("steelblue", 0.85) lid();
        translate([0, 0, explode * 0.5]) color("orange") hatch();
    }
    translate([0, 0, explode * 0.5]) color("khaki") bulkhead();
    color("seagreen") translate([0, 0, -explode]) clips();
    if (show_mock) mock();
}

// ---------------------------------------------------------------- interference checks
// build.sh exports each of these; an empty result (OpenSCAD refuses to export it) is a pass.
module check(n) {
    if (n == 0) intersection() { base(); lid(); }
    if (n == 1) intersection() { base(); hatch(); }
    if (n == 2) intersection() { lid(); hatch(); }
    if (n == 3) intersection() { base(); bulkhead(); }
    if (n == 4) intersection() { lid(); bulkhead(); }
    if (n == 5) intersection() { base(); clips(); }
    if (n == 6) intersection() { union() { base(); lid(); hatch(); bulkhead(); } union() { mock_timer(); mock_node(); } }
    if (n == 7) intersection() { union() { base(); lid(); bulkhead(); } mock_plug(); }
    if (n == 8) intersection() { clips(); mock_pipe(pipe_od - 0.6); }   // clip bore may squeeze the pipe by at most 0.3 mm a side
    if (n == 9) intersection() { base(); mock_pipe(); }
}
check_n = 0;

// ---------------------------------------------------------------- output, in print orientation
if (part == "check") check(check_n);
else if (part == "assembly") assembly();
else if (part == "base") translate([0, 0, floor_t]) base();
else if (part == "lid") translate([0, 0, inner_h + lid_t]) rotate([180, 0, 0]) lid();                // outer face down
else if (part == "hatch") translate([0, 0, inner_h + lid_t + hatch_t]) rotate([180, 0, 0]) hatch();  // outer face down
else if (part == "bulkhead") rotate([0, -90, 0]) translate([-bulk_x + bulk_t / 2, 0, -bb_h]) bulkhead(); // flat
else if (part == "clip") translate([0, 0, clip_len / 2]) clip();                                     // pipe axis up
