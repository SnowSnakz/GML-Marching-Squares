matrix_set(matrix_world, matrix_build(x, y, 0, 0, 0, image_angle, image_xscale, image_yscale, 1));

shader_set(shd_viewpos);
vertex_submit(vbuf, pr_trianglelist, -1);
shader_reset();
