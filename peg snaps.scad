include <common.scad>

default_size = 5;
default_len = 10;
default_bump_depth = 0.3;
default_cut_offset = 0.2;


square_snap_peg();
rotate(180)
    square_snap_peg(is_cut = true);

translate([0, 2 * default_size]) {
    round_snap_peg();
    rotate(180)
        round_snap_peg(is_cut = true);
}

module round_snap_peg(d = default_size, l = default_len, bump_depth = default_bump_depth, is_cut = false) {
    cut_offset = is_cut ? default_cut_offset : 0;
    cut_height = d + 2 * bump_depth;
    bump_d = 1.5 + cut_offset;
    difference() {
        intersection() {
            rotate([0, 90, 0]) {
                rounded_cylinder(d = d + cut_offset, h = l + cut_offset, top_d = 2);
                translate([0, 0, 0.5 * l])
                    torus(d1 = d - 2 * bump_d + 2 * bump_depth + cut_offset, d2 = bump_d);
            }
            if (!is_cut) {
                bottom_cut_size = d + 2 * bump_depth;
                cube_h = 0.7 * d;
                translate([0, -bottom_cut_size/2, -cube_h/2]) {
                    cube([l, bottom_cut_size, cube_h]);
                }
            }
        }
        if (!is_cut)
            snap_cut(default_size, default_len);
    }
}

module square_snap_peg(size = default_size, l = default_len, bump_depth = default_bump_depth, is_cut = false) {
    cut_offset = is_cut ? default_cut_offset : 0;
    snap_angle = 100;
    bump_d = 1.5 + cut_offset;

    if (is_cut) {
        bump_depth = bump_depth + cut_offset;
        cut_size = size + cut_offset;
        snap_height = 2 * get_opposite(angle = snap_angle/2, adjacent = bump_depth);
        rotate([0, 90, 0]) {
            translate([-cut_size/2, -cut_size/2])
                cube([cut_size, cut_size, l]);
            translate([0, 0, 0.5 * l])
                rounded_cube([size + 2 * bump_depth, size + 2 * bump_depth, bump_d], d = bump_d, center = true);
        }
    } else {
        difference() {
            translate([0, 0, -size/2]) {
                linear_extrude(size) {
                    translate([0, -size/2])
                        rounded_square_2([l, size], c2 = 1, c3 = 1);
                    reflect([0, 1, 0])
                        translate([0.5 * l, -size/2 - bump_depth + bump_d/2])
                            circle(d = bump_d);
                }
            }
            if (!is_cut)
                snap_cut(default_size, default_len);
        }
    }
}

module snap_cut(snap_size, snap_length) {
    cut_width = snap_size - 2.4;
    height = 1.5 * snap_size;
    translate([0.15 * snap_length, -cut_width/2, -height/2])
        rounded_cube([0.7 * snap_length, cut_width, height], d = cut_width, top_d = 0, bottom_d = 0);
}
