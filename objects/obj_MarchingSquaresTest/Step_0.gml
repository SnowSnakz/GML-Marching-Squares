var px, py;
px = (mouse_x - x) / 16;
py = (mouse_y - y) / 16;

if(px >= 0 && py >= 0)
{
	if(px <= 16 && py <= 16)
	{
		if(mouse_button != mb_none)
		{
			add_density(px, py, 7.5, mouse_button == mb_right);
		}
	}
}