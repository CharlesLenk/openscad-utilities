include <common.scad>

function sphere_cut_radius(dist_from_center, r, d) =
	let(
		radius = is_undef(r) ? d/2 : r
	) sqrt(radius^2 - dist_from_center^2);

function get_opposite(angle, adjacent, hypotenuse) = 
	is_undef(adjacent) ? hypotenuse * sin(angle) : adjacent * tan(angle);

function get_adjacent(angle, hypotenuse) = hypotenuse * cos(angle);

function get_adjacent_using_opposite(angle, opposite) = opposite / tan(angle);

function is_undef_or_0(value) = is_undef(value) || value == 0;

function is_positive(value) = !is_undef(value) && value > 0;

function flatten(l) = [ for (a = l) for (b = a) b ];
