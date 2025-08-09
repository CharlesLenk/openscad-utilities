// Dynamically scale the number of facets based on preview or render
$fa = $preview ? 1.6 : 0.8;
$fs = $preview ? 0.8 : 0.4;

// Removes shimmer caused by infinitely thin surfaces in preview mode by slightly scaling and shifting the current 
// object
module fix_preview() {
	if($preview) {
		scale([1.001, 1.001, 1.001]) {
			translate([-0.001, -0.001, -0.001]) children();
		}
	} else {
		children();
	}
}

// Echoes the camera coordinates of the current view to the console
module echo_cam() {
    echo(
        str(
            "\n",
            round($vpt[0]),",",round($vpt[1]),",",round($vpt[2]),",",
            round($vpr[0]),",",round($vpr[1]),",",round($vpr[2]),",",
            round($vpd),
            "\n"
        )
    );
}
