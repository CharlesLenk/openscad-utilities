include <common.scad>

module vessel_2d(
	d,
	h,
	wall_width,
	top_lip_width,
	top_r,
	bottom_r
) {
	difference() {
		rounded_square_2([d/2, h - top_r], c2 = bottom_r);
		translate([0, wall_width]) {
			rounded_square_2([d/2 - wall_width, h - top_r - wall_width], c2 = bottom_r - wall_width);
		}
	}
	translate([0, h]) {
		hull() {
			translate([d/2 - top_lip_width, -2 * top_r]) {
				rounded_square([top_lip_width, 2 * top_r], d = 2 * top_r);

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
