include <common.scad>

module reflect(vector) {
    children();
    mirror(vector) {
        children();
    }
}

module x_reflect(dist) {
	translate([dist/2, 0]) children();
	translate([-dist/2, 0]) children();
}

module y_reflect(dist) {
	translate([0, dist/2]) children();
	translate([0, -dist/2]) children();
}

module rotate_with_offset_origin(origin_offset, angle) {
	translate(origin_offset) rotate(angle) translate(-origin_offset) children();
}

module rotate_z_relative_to_point(point, angle) {
	translate([point[0], point[1]]) rotate(angle) translate([-point[0], -point[1]]) children();
}

module rotate_relative_to_point(point, angle) {
	z = is_undef(point[2]) ? 0 : point[2];
	translate(point) rotate(angle) translate([-point[0], -point[1], -z]) children();
}

module xy_cut(height = 0, from_top = false, size = 250) {
    difference() {
        children();
        translate([-size/2, -size/2, (from_top ? 0 : -1) * size + height]) {
            cube([size, size, size]);
        }
    }
}

function translate_points(vector, points) =
	[for (i = [0 : len(points) - 1])
		[points[i][0] + vector[0], points[i][1] + vector[1]]
	];

module place_at_corners(x, y, center = false) {
	translate([center ? -x/2 : 0, center ? -y/2 : 0, 0]) {
		children();
		translate([x, 0, 0]) children();
		translate([0, y, 0]) children();
		translate([x, y, 0]) children();
	}
}

module fillet_2d(radius) {
    offset(radius)
        offset(-radius)
            children();
}
