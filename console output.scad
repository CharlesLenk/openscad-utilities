// Echoes the camera coordinates of the current view to the console.
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

module echo_values(values) {
    echo("--------------------");
    for(pair = values)
        echo(str(pair[0], "=", pair[1]));
    echo("--------------------");
}
