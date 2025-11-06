include <common.scad>

default_bump_d = 2;
default_bump_depth = 0.3;
default_snap_offset = 0.1;
default_inner_wall_width = 1.2;

INNER = 0;
OUTER = 1;

circle_snap_inner(
    outer_diameter = 20,
    height = 5
);

circle_snap_outer(
    outer_diameter = 20,
    height = 5
);

function calc_inner_diameter(
    outer_diameter,
    inner_wall_width,
    outer_wall_width,
    bump_depth,
    snap_offset
) = let(
    bump_depth = is_undef(bump_depth) ? default_bump_depth : bump_depth,
    snap_offset = is_undef(snap_offset) ? default_snap_offset : snap_offset,
    inner_wall_width = is_undef(inner_wall_width) ? default_inner_wall_width : inner_wall_width,
    outer_wall_width = is_undef(outer_wall_width) ? inner_wall_width + snap_offset + bump_depth : outer_wall_width
) outer_diameter - 2 * (inner_wall_width + outer_wall_width);

module circle_snap_inner(
    outer_diameter,
    height,
    inner_wall_width,
    outer_wall_width,
    bump_d,
    bump_depth,
    snap_offset,
    tab_count,
    tab_width
) {
    circle_snap(
        INNER,
        outer_diameter,
        height,
        inner_wall_width,
        outer_wall_width,
        bump_d,
        bump_depth,
        snap_offset,
        tab_count,
        tab_width
    );
}

module circle_snap_outer(
    outer_diameter,
    height,
    inner_wall_width,
    outer_wall_width,
    bump_d,
    bump_depth,
    snap_offset,
    tab_count,
    tab_width,
    allow_spin
) {
    circle_snap(
        OUTER,
        outer_diameter,
        height,
        inner_wall_width,
        outer_wall_width,
        bump_d,
        bump_depth,
        snap_offset,
        tab_count,
        tab_width,
        allow_spin
    );
}

module circle_snap(
    type,
    outer_diameter,
    height,
    inner_wall_width,
    outer_wall_width,
    bump_d,
    bump_depth,
    snap_offset,
    tab_count,
    tab_width,
    allow_spin = false
) {
    bump_d = is_undef(bump_d) ? default_bump_d : bump_d;
    bump_depth = is_undef(bump_depth) ? default_bump_depth : bump_depth;
    snap_offset = is_undef(snap_offset) ? default_snap_offset : snap_offset;
    inner_wall_width = is_undef(inner_wall_width) ? default_inner_wall_width : inner_wall_width;
    outer_wall_width = is_undef(outer_wall_width) ? inner_wall_width + snap_offset + bump_depth : outer_wall_width;
    inner_diameter = calc_inner_diameter(outer_diameter, inner_wall_width, outer_wall_width, bump_depth, snap_offset);
    tab_count = is_undef(tab_count) ? max(round(2 * PI * inner_diameter / 30), 3) : tab_count;
    tab_width = is_undef(tab_width) ? inner_wall_width : tab_width;

    if (type == INNER) {
        difference() {
            rotate_extrude()
                translate([outer_diameter/2 - outer_wall_width - inner_wall_width, 0])
                    circle_snap_inner_2d(height, inner_wall_width, bump_d, bump_depth);
            fix_preview()
                circle_snap_tabs(
                    outer_diameter,
                    height,
                    inner_wall_width,
                    outer_wall_width,
                    tab_count,
                    tab_width,
                    snap_offset,
                    true
                );
        }
    } else if (type == OUTER) {
        rotate_extrude()
            translate([-inner_wall_width - outer_wall_width + outer_diameter/2, 0])
                circle_snap_outer_2d(
                    height,
                    inner_wall_width,
                    outer_wall_width,
                    bump_d,
                    bump_depth,
                    snap_offset
                );
        if (!allow_spin)
            circle_snap_tabs(
                outer_diameter,
                height,
                inner_wall_width,
                outer_wall_width,
                tab_count,
                tab_width,
                snap_offset
            );
    }
}

module circle_snap_inner_2d(
    height,
    inner_wall_width,
    bump_d,
    bump_depth
) {
    polygon(
        [
            [0, 0],
            [0, height],
            [inner_wall_width/2, height],
            [inner_wall_width, height - inner_wall_width],
            [inner_wall_width, 0],
        ]
    );

    if (bump_depth > 0) {
        bump_width = sphere_cut_radius(dist_from_center = bump_d/2 - bump_depth, d = bump_d);
        translate([inner_wall_width, height - inner_wall_width - bump_width]) {
            intersection() {
                translate([-bump_d/2 + bump_depth, 0])
                    circle(d = bump_d);
                translate([-1, -bump_d/2])
                    square([bump_d, bump_d]);
            }
        }
    }
}

module circle_snap_outer_2d(
    height,
    inner_wall_width,
    outer_wall_width,
    bump_d,
    bump_depth,
    snap_offset
) {
	difference() {
		square([inner_wall_width + outer_wall_width, height]);
		offset(snap_offset)
			circle_snap_inner_2d(
                height,
                inner_wall_width,
                bump_d,
                bump_depth
            );
	}
}

module circle_snap_tabs(
    outer_diameter,
    height,
    inner_wall_width,
    outer_wall_width,
    tab_count,
    tab_width,
    snap_offset,
    is_cut = false
) {
	tab_width = tab_width + (is_cut ? 2 * snap_offset : 0);
	tab_len = inner_wall_width + outer_wall_width/2 + snap_offset;
	for (i = [0 : tab_count]) {
		rotate(i * 360/tab_count)
            translate([0, 0, 0])
                tab();
	}

    module tab() {
        extrusion_angle = tab_width / (outer_diameter/2 - inner_wall_width - outer_wall_width) * (180 / PI);
        rotate(-extrusion_angle/2)
            rotate_extrude(angle = extrusion_angle) {
                translate([outer_diameter/2 - inner_wall_width - outer_wall_width - (is_cut ? 0.1 : 0), 0]) {
                    square([tab_len, height]);
                }
            }
    }
}
