// This script contains stuff to be used by both the GML_DataStructures and GML_Structs scripts.

// Sides:
// * Top = 0 (-)
// * Left = 1 (|)
// * Bottom = 2 (-)
// * Right = 3 (|)
// * Forward Diagonal = 4 (/)
// * Backwards Diagonal = 5 (\)

 // [side, blend]
global.__ms_edge_table = [
	[0, 0],
	[0, 1],
	[1, 1],
	[0, -1],
	[3, 1],
	[2, 1],
	[2, 0],
	[5, 1],
	[2, -1],
	[4, 1]
];

// Which 2 vertices on the quad to sample density for a given side.
global.__ms_side_table = [
	[0, 1],
	[0, 2],
	[2, 3],
	[1, 3],
	[2, 1],
	[0, 3]
];

// A group of 3 represent a triangle, these are indices into the edgeTable.
// Vertices are defined clock-wise here.
//
// If the first index of a triangle is negative, that index is only used if the 4th bit is set.
// This is currently only used for the ambigious cases (6 and 9.)
global.__ms_triangle_table = [ 
	[],
	[0, 1, 2],
	[1, 3, 4],
	[0, 3, 2, 3, 4, 2],
	[2, 5, 6],
	[0, 1, 6, 6, 1, 5],
	[6, 2, 5, 1, 3, 4, -2, 1, 5, -1, 4, 5],
	[0, 3, 7, 0, 7, 6, 3, 4, 7, 6, 7, 5],
	[5, 4, 8],
	[5, 4, 8, 0, 1, 2, -2, 1, 5, -1, 4, 5],
	[1, 3, 8, 1, 8, 5],
	[0, 3, 9, 9, 3, 8, 0, 9, 2, 9, 8, 5],
	[6, 2, 8, 2, 4, 8],
	[0, 9, 6, 6, 9, 8, 0, 1, 6, 6, 4, 8],
	[6, 7, 8, 7, 3, 8, 2, 7, 6, 1, 3, 6],
	[0, 3, 6, 6, 3, 8]
];

function __ms_get_index(quad, iso_level) {
	var index = 0;
	var average = 0;
		
	var d;
	for(var i = 0; i < 4; i++)
	{
		d = quad[i];
		average += d;
		if(d > iso_level)
			index |= (1 << i);
	}
		
	average /= 4;
	if(average > iso_level) // Used for disambiguation of cases #6 and #9.
		index |= 16; // (1 << 4);
		
	return index;
}

function __ms_get_blend(iso_level, v1, v2, blend)
{
	if(blend <= 0)
		return abs(blend);
	
	return clamp((abs(v1 - iso_level) + (1 - abs(v2 - iso_level))) / 2, 0, 1);
}

function __ms_gen_vertex(iso_level, side, blend, x1, y1, x2, y2, density_quad)
{
	var blend_sides = global.__ms_side_table[side];
	blend = __ms_get_blend(iso_level, density_quad[blend_sides[0]], density_quad[blend_sides[1]], blend);
	
	switch(side)
	{
		default:
			return [0.5, 0.5];
		
		case 0: // Top
			return [lerp(x1, x2, blend), y1];
				
		case 1: // Left
			return [x1, lerp(y1, y2, blend)];
				
		case 2: // Bottom
			return [lerp(x1, x2, blend), y2];
				
		case 3: // Right
			return [x2, lerp(y1, y2, blend)];
				
		case 4: // Forward Diagonal
			return [lerp(x1, x2, blend), lerp(y2, y1, blend)];
				
		case 5: // Backward Diagonal
			return [lerp(x1, x2, blend), lerp(y1, y2, blend)];
	}
}

function __ms_gen_triangle(iso_level, x1, y1, x2, y2, a, b, c, density_quad)
{
	var al = global.__ms_edge_table[a];
	var bl = global.__ms_edge_table[b];
	var cl = global.__ms_edge_table[c];
	
	return [
		__ms_gen_vertex(iso_level, al[0], al[1], x1, y1, x2, y2, density_quad),
		__ms_gen_vertex(iso_level, bl[0], bl[1], x1, y1, x2, y2, density_quad),
		__ms_gen_vertex(iso_level, cl[0], cl[1], x1, y1, x2, y2, density_quad)
	];
}

function __ms_gen_triangles(iso_level, index, winding_order, x1, y1, x2, y2, density_quad) {
	var result = [];
	
	var triangle_lookup = global.__ms_triangle_table[index & 15];
	
	var l = array_length(triangle_lookup);
	for(var i = 0; i < l; i += 3)
	{
		var a, b, c;
		a = triangle_lookup[i + 0];
		b = triangle_lookup[i + 1];
		c = triangle_lookup[i + 2];
		
		if(sign(a) == -1)
		{
			a = abs(a);
			
			if((index & 16) == 0)
				continue;
		}
		
		var tri;
		if(winding_order)
		{
			tri = __ms_gen_triangle(iso_level, x1, y1, x2, y2, a, b, c, density_quad);
		}
		else
		{
			tri = __ms_gen_triangle(iso_level, x1, y1, x2, y2, c, b, a, density_quad);
		}
		
		for(var j = 0; j < 3; j++)
		{
			array_push(result, tri[j]);
		}
	}
	
	return result;
}

global.__ms_grid_sampler_method = "get"; // name of a the method on the grid which takes two arguments (x, y)

// Returns an array containing all of the vertices for each triangle (each set of 3 vertices is a triangle)
function marching_squares(iso_level, is_clockwise, grid, width, height, scale_x, scale_y) {
	var is_dsgrid = is_real(grid) && ds_exists(grid, ds_type_grid);
	var is_class = is_struct(grid);
	
	if(!is_dsgrid && !is_class)
	{
		show_debug_message("Unable to sample grid of unknown type.");
		return [];
	}
	
	var sampler_method;
	if(is_class)
	{
		sampler_method = grid[$ global.__ms_grid_sampler_method];
		
		if(!is_method(sampler_method))
		{
			show_debug_message("Unable to find sampler method on grid.");
			return [];
		}
	}
	
	var result = [];
	
	for(var yy = 0; yy < height; yy++) {
		for(var xx = 0; xx < width; xx++) {
			var quad;
			
			if(is_dsgrid)
			{
				quad = [
					grid[# xx, yy],
					grid[# xx + 1, yy],
					grid[# xx, yy + 1],
					grid[# xx + 1, yy + 1]
				];
			}
			else
			{
				quad = [
					sampler_method(xx, yy),
					sampler_method(xx + 1, yy),
					sampler_method(xx, yy + 1),
					sampler_method(xx + 1, yy + 1)
				];
			}
			
			var index = __ms_get_index(quad, iso_level);
			
			var triangles = __ms_gen_triangles(iso_level, index, is_clockwise, xx * scale_x, yy * scale_y, (xx + 1) * scale_x, (yy + 1) * scale_y, quad);
			for(var i = 0; i < array_length(triangles); i++)
			{
				array_push(result, triangles[i]);
			}
		}
	}
	
	return result;
}
