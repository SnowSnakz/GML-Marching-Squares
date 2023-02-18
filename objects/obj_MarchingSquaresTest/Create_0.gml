grid_test = ds_grid_create(16, 16);

for(var i = 0; i < 16; i++)
{
	for(var j = 0; j < 16; j++)
	{
		
		var xx = abs(i - 8);
		var yy = abs(j - 8);
		
		// Procudes a circle by calculate the distance from (i, j) to (8, 8)
		grid_test[# i, j] = clamp(1 - (sqrt(xx*xx + yy*yy) / 8), -1, 1);
	}
}

// Define the format for the vertex buffer.
vertex_format_begin();
vertex_format_add_position();
vertex_format_add_texcoord();
vertex_format_add_color();
vbuf_format = vertex_format_end();

vbuf = noone;

regenerate_mesh = function()
{
	// Calculate the result.
	var triangles = marching_squares(0, true, grid_test, 16, 16);

	// Store the result in a vertex buffer.
	if(vbuf == noone) {
		vbuf = vertex_create_buffer();
	}
	
	vertex_begin(vbuf, vbuf_format);

	var l = array_length(triangles);
	show_debug_message(l);
	
	for(var i = 0; i < l; i++)
	{
		var xx = triangles[i][0];
		var yy = triangles[i][1];
		
		vertex_position(vbuf, xx, yy);
		vertex_texcoord(vbuf, xx, yy);
		vertex_color(vbuf, make_color_hsv((xx + yy) / 2, 255, 255), 1);
	}

	vertex_end(vbuf);
}

add_density = function(xx, yy, size, negate)
{
	is_dirty = true;
	
	for(var i = 0; i < 16; i++)
	{
		for(var j = 0; j < 16; j++)
		{
			var xd, yd;
			xd = abs(xx - i);
			yd = abs(yy - j);
			
			var amount = 1 - clamp(sqrt(xd * xd + yd * yd) / size, 0, 1);
			if(negate) amount = -amount;
			
			grid_test[# i, j] = clamp(grid_test[# i, j] + (amount * 0.2), -1, 1);
		}
	}
}

is_dirty = true;
