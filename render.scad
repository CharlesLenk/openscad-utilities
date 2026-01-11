// Dynamically scale the number of facets based on preview or render.
$fa = $preview ? 1.6 : 0.8;
$fs = $preview ? 0.8 : 0.4;

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
