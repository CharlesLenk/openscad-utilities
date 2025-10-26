include <common.scad>

module capped_cylinder(d, h, point_d = 0) {
	fix_preview() cylinder(d = d, h = h - d/2 + point_d/2);
	translate([0, 0, h - d/2 + point_d/2]) cylinder(d1 = d, d2 = point_d, h = d/2 - point_d/2);
}

module cube_one_round_corner(vector, corner_r) {
	x = vector[0];
	y = vector[1];
	z = vector[2];
	linear_extrude(z) {
		rounded_square_2([x, y], c3 = corner_r);
	}
}

module rounded_cylinder(h, d, top_d = 0, bottom_d = 0, center = false) {
	translate([0, 0, center ? -h/2: 0]) {
		rotate_extrude() rounded_corner(d, h, top_d, bottom_d);
	}
}

module torus(d1, d2) {
    rotate_extrude() {
        translate ([d1/2 + d2/2, 0, 0]) {
            circle(d = d2);
        }
    }
}

module threaded_insert_hole() {
    insert_height = 3.5;

    translate([0, 0, -insert_height + 0.01]) {
        cylinder(d1 = 3.9, d2 = 4.1, h = insert_height, $fn = 15);
    }
    translate([0, 0, -5.5]) {
        cylinder(d = 3.2, h = 12, $fn = 15);
    }
}

module countersink(shaft_diameter, head_size, head_depth, shaft_length = 50, head_length = 50) {
    head_depth = is_undef_or_0(head_depth) ? (head_size - shaft_diameter)/2 : head_depth;
    rotate_extrude()
        polygon(
            [
                [0, head_length],
                [head_size/2, head_length],
                [head_size/2, 0],
                [shaft_diameter/2, -head_depth],
                [shaft_diameter/2, -shaft_length],
                [0, -shaft_length],
            ]
        );
}

module rounded_corner(d, h, top_d, bottom_d) {
	rounded_square_2([d/2, h], c2 = bottom_d/2, c3 = top_d/2);
}

module rounded_square(vector, d, front_d, back_d) {
	front_r = is_undef(front_d) ? d/2 : front_d/2;
	back_r = is_undef(back_d) ? d/2 : back_d/2;

	rounded_square_2(vector, back_r, back_r, front_r, front_r);
}

module rounded_square_2(vector, c1 = 0, c2 = 0, c3 = 0, c4 = 0, center = false) {
	x = vector[0];
	y = vector[1];

	points = [
		if (c1 == 0) [[0, 0]] else translate_points([c1, c1], arc_points(c1, 180, 270)),
		if (c2 == 0) [[x, 0]] else translate_points([x - c2, c2], arc_points(c2, 270, 360)),
		if (c3 == 0) [[x, y]] else translate_points([x - c3, y - c3], arc_points(c3, 0, 90)),
		if (c4 == 0) [[0, y]] else translate_points([c4, y - c4], arc_points(c4, 90, 180))
	];

    translate(center ? [-x/2, -y/2] : [0, 0]) {
	    polygon(flatten(points));
    }
}

function arc_points(r, start_angle, stop_angle) =
	let(
		n = $fn > 0 ? ($fn >= 3 ? $fn : 3) : ceil(max(min(360/$fa, r*2*PI/$fs), 5)),
		deg = abs(start_angle - stop_angle),
		segments = ceil(n/(360/deg))
	) (
		[for(a = [start_angle : deg/segments : stop_angle]) [r * cos(a), r * sin(a)]]
	);

module pie_wedge(r, angle) {
    polygon(flatten([[[0, 0]], arc_points(r, 0, angle)]));
}

module wedge_2d(angle, y) {
	x = get_opposite_toa(angle/2, y);
	polygon([[0, 0], [x, y], [-x, y]]);
}

module wedge(angle, y, z) {
	linear_extrude(z) wedge_2d(angle, y);
}

module rounded_cube(vector, d, front_d, back_d, top_d, bottom_d, center = false) {
	if (is_undef_or_0(d) && is_undef_or_0(front_d) && is_undef_or_0(back_d)
		&& is_undef_or_0(top_d) && is_undef_or_0(bottom_d)
	) {
		cube(vector, center);
	} else {
		x = vector[0];
		y = vector[1];
		z = vector[2];
		d = is_undef_or_0(d) ? 0.001 : d;

		front_d = is_undef(front_d) ? d : front_d;
		back_d = is_undef(back_d) ? d : back_d;
		top_d = is_undef(top_d) ? min(front_d, back_d) : top_d;
		bottom_d = is_undef(bottom_d) ? min(front_d, back_d) : bottom_d;

		assert(top_d <= front_d, str("top_d ", top_d, " must be <= front_d ", front_d));
		assert(top_d <= back_d, str("top_d ", top_d, " must be <= back_d ", back_d));
		assert(bottom_d <= front_d, str("bottom_d ", bottom_d, " must be <= front_d ", front_d));
		assert(bottom_d <= back_d, str("bottom_d ", bottom_d, " must be <= back_d ", back_d));

		translate(center ? [-x/2, -y/2, -z/2] : [0, 0, 0]) {
			if (top_d == 0 && bottom_d == 0) {
				linear_extrude(z) {
					rounded_square_2([x, y], back_d/2, back_d/2, front_d/2, front_d/2);
				}
			} else {
				hull() {
					translate([x, y]) corner(front_d, z, top_d, bottom_d);
					translate([0, y]) rotate(90) corner(front_d, z, top_d, bottom_d);
					rotate(180) corner(back_d, z, top_d, bottom_d);
					translate([x, 0]) rotate(270) corner(back_d, z, top_d, bottom_d);
				}
			}
		}
	}

	module corner(d, h, top_d, bottom_d) {
		translate([-d/2, -d/2]) {
			rotate_extrude(angle = 90) rounded_corner(d, h, top_d, bottom_d);
		}
	}
}

module dodecahedron(height, d) {
    // Golden ratio
    t = (1 + sqrt(5))/2;

    size_factor = t * 0.5 * (height - 2 * d) / sqrt(2.5 + (11/10 * sqrt(5)));

    rotate([0, atan(t), 0]) {
        hull() {
            translate([size_factor, size_factor, size_factor]) sphere(d);
            translate([size_factor, -size_factor, size_factor]) sphere(d);
            translate([size_factor, size_factor, -size_factor]) sphere(d);
            translate([size_factor, -size_factor, -size_factor]) sphere(d);

            translate([-size_factor, size_factor, size_factor]) sphere(d);
            translate([-size_factor, -size_factor, size_factor]) sphere(d);
            translate([-size_factor, size_factor, -size_factor]) sphere(d);
            translate([-size_factor, -size_factor, -size_factor]) sphere(d);

            translate([t * size_factor, size_factor/t, 0]) sphere(d);
            translate([t * size_factor, -size_factor/t, 0]) sphere(d);
            translate([t * -size_factor, size_factor/t, 0]) sphere(d);
            translate([t * -size_factor, -size_factor/t, 0]) sphere(d);

            translate([0, t * size_factor, size_factor/t]) sphere(d);
            translate([0, t * size_factor, -size_factor/t]) sphere(d);
            translate([0, t * -size_factor, size_factor/t]) sphere(d);
            translate([0, t * -size_factor, -size_factor/t]) sphere(d);

            translate([size_factor/t, 0, t * size_factor]) sphere(d);
            translate([size_factor/t, 0, t * -size_factor]) sphere(d);
            translate([-size_factor/t, 0, t * size_factor]) sphere(d);
            translate([-size_factor/t, 0, t * -size_factor]) sphere(d);
        }
    }
}

module bolt(diameter, length, root, crest, pitch, depth, thread_offset = 0) {
	diameter = diameter - 2 * depth + thread_offset;

	segment_angle = $preview ? 10 : 5;
	segments_per_loop = 360 / segment_angle;
	height_per_segment = pitch / segments_per_loop;
	number_of_loops = floor(length/pitch) + 2;

	intersection () {
		translate ([0, 0, -pitch]) {
			for (i = [0 : number_of_loops * segments_per_loop - 1]) {
				hull () {
					translate ([0, 0, i * height_per_segment]) {
						rotate(i * segment_angle) {
							thread_segment();
						}
					}
					translate ([0, 0, (i + 1) * height_per_segment]) {
						rotate((i + 1) * segment_angle) {
							thread_segment();
						}
					}
				}
			}
		}
		translate([0, 0, length/2]) {
			cube([diameter + 2 * depth, diameter + 2 * depth, length], center = true);
		}
	}
	cylinder (d = diameter + 0.1, h = length);

	module thread_segment() {
		thread_width = pitch - root;
		translate([0, diameter/2, 0]) {
			hull() {
				translate([0, 0, -thread_offset/2]) {
					cube([0.001, 0.001, thread_width + thread_offset]);
				}
				translate([0, 0, -crest/2 + thread_width/2 - thread_offset/2]) {
					cube([0.001, depth, crest + thread_offset]);
				}
			}
		}
	}
}

module rounded_vector(p1 = [0, 0, 0], p2 = [0, 0, 0], d) {
    hull() {
        translate(p1) sphere(d=d);
        translate(p2) sphere(d=d);
    }
}
