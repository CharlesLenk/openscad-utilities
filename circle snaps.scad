include <openscad-utilities/common.scad>

default_bump_depth = 0.3;
default_snap_offset = 0.1;
default_inner_wall_width = 1.2;

circle_snap_inner(
    outer_diameter = 150,
    height = 6
);

circle_snap_outer(
    outer_diameter = 150,
    height = 6
);

function calc_outer_wall_width(
    inner_wall_width,
    bump_depth,
    snap_offset
) = let (
    bump_depth = is_undef(bump_depth) ? default_bump_depth : bump_depth,
    snap_offset = is_undef(snap_offset) ? default_snap_offset : snap_offset,
    inner_wall_width = is_undef(inner_wall_width) ? default_inner_wall_width : inner_wall_width,
) inner_wall_width - snap_offset + bump_depth;

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
) outer_diameter - 2 * inner_wall_width - 2 * outer_wall_width;

function calc_default_tab_count(
    outer_diameter,
    inner_wall_width,
    outer_wall_width,
    bump_depth,
    snap_offset
) = let(
    inner_diameter = calc_inner_diameter(
        outer_diameter,
        inner_wall_width,
        outer_wall_width,
        bump_depth,
        snap_offset
    )
) max(round(2 * PI * inner_diameter / 30), 3);

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
    bump_d = is_undef(bump_d) ? height/2 : bump_d;
    bump_depth = is_undef(bump_depth) ? default_bump_depth : bump_depth;
    snap_offset = is_undef(snap_offset) ? default_snap_offset : snap_offset;
    inner_wall_width = is_undef(inner_wall_width) ? default_inner_wall_width : inner_wall_width;
    outer_wall_width = is_undef(outer_wall_width) ? 
        calc_outer_wall_width(
            inner_wall_width,
            snap_offset,
            bump_depth
        ) : outer_wall_width;
    tab_count = is_undef(tab_count) ? 
        calc_default_tab_count(
            outer_diameter,
            inner_wall_width,
            outer_wall_width,
            bump_depth,
            snap_offset
        ) : tab_count;
    tab_width = is_undef(tab_width) ? inner_wall_width : tab_width;

	difference() {
		rotate_extrude()
			translate([-inner_wall_width - outer_wall_width + outer_diameter/2, 0])
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
    allow_spin = false
) {
    bump_d = is_undef(bump_d) ? height/2 : bump_d;
    bump_depth = is_undef(bump_depth) ? default_bump_depth : bump_depth;
    snap_offset = is_undef(snap_offset) ? default_snap_offset : snap_offset;
    inner_wall_width = is_undef(inner_wall_width) ? default_inner_wall_width : inner_wall_width;
    outer_wall_width = is_undef(outer_wall_width) ? inner_wall_width + snap_offset + bump_depth : outer_wall_width;
    tab_count = is_undef(tab_count) ? 
        calc_default_tab_count(
            outer_diameter,
            inner_wall_width,
            outer_wall_width,
            bump_depth,
            snap_offset
        ) : tab_count;
    tab_width = is_undef(tab_width) ? inner_wall_width : tab_width;

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

module circle_snap_inner_2d(
    height,
    inner_wall_width,
    bump_d,
    bump_depth
) {
	square([inner_wall_width, height]);
	translate([inner_wall_width, 2/3 * height]) {
		intersection() {
			translate([-bump_d/2 + bump_depth, 0])
				circle(d = bump_d);
			translate([0, -bump_d/2])
				square([bump_d, bump_d]);
		}
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
	tab_width = 2 + (is_cut ? 2 * snap_offset : 0);
	tab_len = inner_wall_width + outer_wall_width + snap_offset;
	for (i = [0 : tab_count]) {
		rotate(i * 360/tab_count)
			translate([outer_diameter/2 - tab_len - snap_offset, -tab_width/2, 0])
				cube([tab_len, tab_width, height]);
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
