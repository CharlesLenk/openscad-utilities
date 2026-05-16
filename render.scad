// Set the angle and length of facets to produce smooth surfaces when 3D printing.
$fa = 1.6;
$fs = 0.6;

// Removes shimmer caused by infinitely thin surfaces in preview mode by slightly scaling and shifting the current
// object only when in preview mode.
module fix_preview() {
	if($preview) {
		scale([1.001, 1.001, 1.001]) {
			translate([-0.001, -0.001, -0.001]) children();
		}
	} else {
		children();
	}
}
