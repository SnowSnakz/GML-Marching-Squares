for(var i = 0; i < 15; i++)
{
	for(var j = 0; j < 15; j++)
	{
		var cube = [
			grid_test[# i, j],
			grid_test[# i + 1, j],
			grid_test[# i + 1, j + 1],
			grid_test[# i, j + 1]
		];
		
		var a, b, c, d;
		a = make_color_hsv(0, 0, cube[0] * 128 + 128);
		b = make_color_hsv(0, 0, cube[1] * 128 + 128);
		c = make_color_hsv(0, 0, cube[2] * 128 + 128);
		d = make_color_hsv(0, 0, cube[3] * 128 + 128);
		
		draw_rectangle_color(x + i * 16, y + j * 16, x + (i + 1) * 16 - 1, y + (j + 1) * 16 - 1, a, b, c, d, true);
	}
}

matrix_set(matrix_world, matrix_build(x, y, 0, 0, 0, image_angle, image_xscale, image_yscale, 1));
vertex_submit(vbuf, pr_trianglelist, -1);
