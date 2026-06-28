include <common.scad>

module vessel_2d(
	d,
	h,
	wall_width,
	top_lip_width,
	top_r,
	bottom_r
) {
    inner_square_r = bottom_r - wall_width < 0 ? 0 : bottom_r - wall_width;
	difference() {
		rounded_square_2([d/2, h - top_r], c2 = bottom_r);
		translate([0, wall_width]) {
			rounded_square_2([d/2 - wall_width, h - top_r - wall_width], c2 = inner_square_r);
		}
	}
	translate([0, h]) {
		hull() {
			translate([d/2 - top_lip_width, -2 * top_r]) {
				rounded_square_2([top_lip_width, 2 * top_r], r = top_r);
			}
			translate([d/2 - wall_width, -top_lip_width]) {
				square([wall_width, 0.1]);
			}
		}
	}
}

module vessel(
	d,
	h,
	wall_width,
	top_lip_width,
	top_r,
	bottom_r,
	flip = false
) {
	rotate([flip ? 180 : 0, 0, 0]){
		translate([0, 0, flip ? -h : 0]) {
			rotate_extrude() {
				vessel_2d(
					d,
					h,
					wall_width,
					top_lip_width,
					top_r,
					bottom_r
				);
			};
		}
	}
}
