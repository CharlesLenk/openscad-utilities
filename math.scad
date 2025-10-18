include <common.scad>

function sphere_cut_radius(dist_from_center, r, d) =
	let(
		radius = is_undef(r) ? d/2 : r
	) sqrt(radius^2 - dist_from_center^2);

function get_opposite_toa(angle, adjacent) = adjacent * tan(angle);

function get_opposite_soh(angle, hypotenuse) = hypotenuse * sin(angle);

function get_adjacent(angle, hypotenuse) = hypotenuse * cos(angle);

function is_undef_or_0(value) = is_undef(value) || value == 0;

function is_positive(value) = !is_undef(value) && value > 0;

function flatten(l) = [ for (a = l) for (b = a) b ];
