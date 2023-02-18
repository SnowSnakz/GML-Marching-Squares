grid_test = ds_grid_create(16, 16);

for(var i = 0; i < 16; i++)
{
	for(var j = 0; j < 16; j++)
	{
		// Procudes a circle by calculate the distance from (i, j) to (8, 8)
		grid_test[# i, j] = 1 - (sqrt(abs(i * i - 64) + abs(j * j - 64)) / 8);
	}
}

// Define the format for the vertex buffer.
vertex_format_begin();
vertex_format_add_position();
vbuf_format = vertex_format_end();

vbuf = noone;

regenerate_mesh = function()
{
	// Calculate the result.
	var triangles = marching_squares(0, true, grid_test, 15, 15, 16, 16);

	// Store the result in a vertex buffer.
	if(vbuf == noone) {
		vbuf = vertex_create_buffer();
	}
	
	vertex_begin(vbuf, vbuf_format);

	var l = array_length(triangles);
	for(var i = 0; i < l; i += 2)
	{
		vertex_position(vbuf, triangles[i], triangles[i + 1]);
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
			yd = abs(yy - i);
			
			var amount = 1 - clamp(sqrt(xd * xd + yd * yd) / size, 0, 1);
			if(negate) amount = -amount;
			
			grid[# i, j] += amount;
		}
	}
}

is_dirty = true;
