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
	[1, -1],
	[5, 1],
	[2, -1],
	[4, 1]
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
	[1, 5, 6],
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

// Any variable names included in this list will be interpolated when smoothing two vertices.
// All other variables will be copied from the closest source vertex.
global.__ms_interpolators = [
	"x", "y", "z", "w", "r", "g", "b", "a",
	"red", "green", "blue", "alpha",
	"color", "texcoord", "position", "normal",
	"col", "tex", "pos", "norm"
];

function __ms_get_index(quad, isoLevel) {
	var index = 0;
	var average = 0;
		
	var d;
	for(var i = 0; i < 3; i++)
	{
		d = quad[i].density;
		average += d;
		if(d > isoLevel)
			index |= (1 << i);
	}
		
	average /= 4;
	if(average > isoLevel) // Used for disambiguation of cases #6 and #9.
		index |= 16; // (1 << 4);
		
	return index;
}

function __ms_gen_triangle(x1, y1, x2, y2, a, b, c)
{
	
}

function __ms_gen_triangles(index, winding_order, x1, y1, x2, y2) {
	var result = [];
	
	var triangle_lookup = global.__ms_triangle_table[index & 15];
	
	var l = array_length(triangle_lookup);
	for(var i = 0; i < l; i += 3)
	{
		var a, b, c;
		a = triangle_lookup[0];
		b = triangle_lookup[1];
		c = triangle_lookup[2];
		
		if(sign(a) == -1)
		{
			if((index & 16) == 0)
				continue;
		}
		
		var tri;
		if(winding_order)
		{
			tri = __ms_gen_triangle(x1, y1, x2, y2, a, b, c);
		}
		else
		{
			tri = __ms_gen_triangle(x1, y1, x2, y2, c, b, a);
		}
		
		array_push(result, tri);
	}
	
	return result;
}
