module arrow(head_width, length, center = false, arrow_color = "#EE4B2B") {
    end_width = 0.4 * head_width;
	color(arrow_color) {
		linear_extrude(0.1) {
            translate([0, center ? -length/2 : 0]) {
                polygon(
                    [
                        [0, 0],
                        [head_width/2, head_width/2],
                        [-end_width/2, head_width/2],
                        [-end_width/2, length],
                        [end_width/2, length],
                        [end_width/2, head_width/2],
                        [-head_width/2, head_width/2]
                    ]
                );
            }
		};
	};
}
