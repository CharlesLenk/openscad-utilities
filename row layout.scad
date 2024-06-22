include <common.scad>

PART_ON_EDGE = 0;
FULL_SPACE = 1;
HALF_SPACE = 2;

module row_layout_y(total_width, part_width, part_count, min_space_width, mode = PART_ON_EDGE) {
    row_layout(total_width, part_width, part_count, min_space_width, mode, "y") {
        children();
    }
}

module row_layout(total_width, part_width, part_count, min_space_width, mode = PART_ON_EDGE, axis = "x") {
    assert(is_positive(part_count) || is_positive(min_space_width), "Either part_count or min_space_width must be set");
    assert(is_undef_or_0(part_count) || is_undef_or_0(min_space_width), "Either part_count or min_space_width must be set, but not both");
    assert(part_width < total_width, "Part width must be less than total width");
    assert(is_undef(part_count) || part_count * part_width <= total_width, "total_width, part_width, and part_count would leave no space between parts");

    let (
        part_count = is_positive(part_count) ? part_count : floor(total_width / (part_width + min_space_width)),
        start_space_mult = mode == FULL_SPACE ? 1 : mode == HALF_SPACE ? 0.5 : 0,
        space_width = get_space_width(total_width, part_width, part_count, min_space_width, mode),
        part_offset = part_width + space_width
    ) {
        for (i = [0 : part_count - 1]) {
            offset = start_space_mult * space_width + i * (part_offset);
            translate([axis == "x" ? offset : 0, axis == "y" ? offset : 0]) {
                children();
            }
        }
    }
}

function get_space_width(total_width, part_width, part_count, min_space_width, mode = PART_ON_EDGE) =
    let (
        part_count = is_positive(part_count) ? part_count : floor(total_width / (part_width + min_space_width)),
        start_space_mult = mode == FULL_SPACE ? 1 : mode == HALF_SPACE ? 0.5 : 0,
        total_spacing = total_width - part_count * part_width,
        space_count = 2 * start_space_mult + part_count - 1
    ) total_spacing / space_count;
