include <common.scad>

default_size = 5;
default_len = 10;
default_bump_depth = 0.4;
default_cut_offset = 0.15;
bump_d = 1.5;

square_snap_peg();
rotate(180)
    square_snap_peg();

translate([0, 2 * default_size]) {
    round_snap_peg();
    rotate(180)
        round_snap_peg();
}

//test();

module test() {
    square_snap_peg();
    rotate(180)
        square_snap_peg(is_cut = true);

    xy_cut(from_top = true) {
        translate([0, 2 * default_size]) {
            difference() {
                square_snap_peg(is_cut = true);
                square_snap_peg();
            }
        }
    }

    translate([0, 4 * default_size]) {
        round_snap_peg();
        rotate(180)
            round_snap_peg(is_cut = true);
    }

    xy_cut(from_top = true) {
        translate([0, 6 * default_size]) {
            difference() {
                round_snap_peg(is_cut = true);
                round_snap_peg();
            }
        }
    }
}

module round_snap_peg(d = default_size, l = default_len, bump_depth = default_bump_depth, is_cut = false) {
    cut_offset = is_cut ? default_cut_offset : 0;
    cut_height = d + 2 * bump_depth;
    bump_d_cut_adjusted = bump_d + cut_offset;

    difference() {
        intersection() {
            rotate([0, 90, 0]) {
                rounded_cylinder(d = d + 2 * cut_offset, h = l + cut_offset, top_d = default_size/3);
                translate([0, 0, 0.5 * l])
                    torus(d1 = d - 2 * bump_d + 2 * bump_depth, d2 = bump_d_cut_adjusted);
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

    if (is_cut) {
        cut_size = size + 2 * cut_offset;
        bump_size = size + 2 * bump_depth + 2 * cut_offset;
        bump_d_cut_adjusted = bump_d + 2 * cut_offset;
        rotate([0, 90, 0]) {
            translate([-cut_size/2, -cut_size/2])
                cube([cut_size, cut_size, l + cut_offset]);
            translate([0, 0, 0.5 * l]) {
                for(i = [0 : 3])
                    rotate(i * 90)
                        translate([bump_size/2, 0])
                            intersection() {
                                translate([-bump_d_cut_adjusted/2, bump_size/2])
                                    rotate([90, 0, 0])
                                        cylinder(h = bump_size, d = bump_d_cut_adjusted);
                                translate([0, 0, -bump_d_cut_adjusted/2])
                                    linear_extrude(bump_d_cut_adjusted)
                                        polygon(
                                            [
                                                [0, bump_size/2],
                                                [-bump_d_cut_adjusted, bump_size/2 - bump_d_cut_adjusted],
                                                [-bump_d_cut_adjusted, -bump_size/2 + bump_d_cut_adjusted],
                                                [0, -bump_size/2],
                                            ]
                                        );
                            }
            }
        }
    } else {
        difference() {
            translate([0, 0, -size/2]) {
                linear_extrude(size) {
                    translate([0, -size/2])
                        rounded_square_2([l, size], c2 = default_size/6, c3 = default_size/6);
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
