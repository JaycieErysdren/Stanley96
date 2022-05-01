//
// ENGINE BUILTINS
//

void(float vwidth, float vheight, float notmenu) CSQC_UpdateView =
{	
	clearscene();
	
	vector view_size = [320, 200];
	vector screensize = [320, 240];

	/* not sure if i wanna have a widescreen mode

	if (cvar("stanley_viewmode") == 0)
		view_size = [320, 200];
	else if (cvar("stanley_viewmode") == 1)
		view_size = [384, 216];
	else
		view_size = [320, 200];

	*/

	// set up 4:3 screen reisze
	drawfill([0, 0], [vwidth, vheight], [0, 0, 0], 1);
	setviewprop(VF_RT_DESTCOLOUR, "screenrt", -IMGFMT_R8G8B8A8, screensize);
	setproperty(VF_SIZE, view_size);

	setproperty(VF_DRAWENGINESBAR, 0);
	setproperty(VF_DRAWCROSSHAIR, 0);
	setproperty(VF_DRAWWORLD, 1);

	setproperty(VF_ORIGIN, getentity(player_localentnum, GE_ORIGIN) + [0, 0, 64]);
	addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE);
	
	setproperty(VF_ANGLES, view_angles);

	renderscene();
	
	vector textbox_size = [view_size_x, 40];
	
	string narrator_line1 = getstats(STAT_NARRATOR_LINE1);
	string narrator_line2 = getstats(STAT_NARRATOR_LINE2);
	string narrator_line3 = getstats(STAT_NARRATOR_LINE3);

	// narrator textbox
	drawfill([0, screensize_y - textbox_size_y], textbox_size, [0.1, 0.1, 0.1], 1);
	// line 1
	drawstring([4, screensize_y - textbox_size_y + 4], narrator_line1, [8, 8], [1, 1, 1], 1, 0);
	// line 2
	drawstring([4, screensize_y - textbox_size_y + 16], narrator_line2, [8, 8], [1, 1, 1], 1, 0);
	// line 3
	drawstring([4, screensize_y - textbox_size_y + 28], narrator_line3, [8, 8], [1, 1, 1], 1, 0);

	setviewprop(VF_RT_DESTCOLOUR, (string)__NULL__);
	
	shaderforname("screenrtshader", "{\n{\nmap $rt:screenrt\nrgbgen vertex\n}\n}\n"); 

	if (vheight < vwidth && (vheight * ar_normal) < vwidth )
		// window is widescreen-shaped
		drawpic([(vwidth / 2) - ((vheight * ar_normal) / 2), 0], "screenrtshader", [vheight * ar_normal, vheight], [1, 1, 1], 1);
	else if ((vwidth / vheight) == ar_normal)
		// perfectly 4:3 window
		drawpic([0, 0], "screenrtshader", [vwidth, vheight], [1, 1, 1], 1);
	else
		// window is phone-shaped (?)
		drawpic([0, (vheight / 2) - ((vwidth * 0.75) / 2)], "screenrtshader", [vwidth, vwidth * 0.75], [1, 1, 1], 1);


	/* not sure if i wanna have a widescreen mode

	// figure out how to position the screenshader based on the screen mode and window aspect ratio
	if (cvar("stanley_viewmode") == 0)
	{
		if (vheight < vwidth && (vheight * ar_normal) < vwidth )
			// window is widescreen-shaped
			drawpic([(vwidth / 2) - ((vheight * ar_normal) / 2), 0], "screenrtshader", [vheight * ar_normal, vheight], [1, 1, 1], 1);
		else if ((vwidth / vheight) == ar_normal)
			// perfectly 4:3 window
			drawpic([0, 0], "screenrtshader", [vwidth, vheight], [1, 1, 1], 1);
		else
			// window is phone-shaped (?)
			drawpic([0, (vheight / 2) - ((vwidth * 0.75) / 2)], "screenrtshader", [vwidth, vwidth * 0.75], [1, 1, 1], 1);
	}
	else if (cvar("stanley_viewmode") == 1)
	{
		if (vheight < vwidth && (vheight * ar_widescreen) < vwidth ) // window is widescreen-shaped
			drawpic([(vwidth / 2) - ((vheight * ar_widescreen) / 2), 0], "screenrtshader", [vheight * ar_widescreen, vheight], [1, 1, 1], 1);
		else if ((vwidth / vheight) == ar_widescreen) // perfectly 16:9 window
			drawpic([0, 0], "screenrtshader", [vwidth, vheight], [1, 1, 1], 1);
		else // window is phone-shaped (?)
			drawpic([0, (vheight / 2) - ((vwidth * 0.5625) / 2)], "screenrtshader", [vwidth, vwidth * 0.5625], [1, 1, 1], 1);
	}
	else
	{
		if (vheight < vwidth && (vheight * ar_normal) < vwidth ) // window is widescreen-shaped
			drawpic([(vwidth / 2) - ((vheight * ar_normal) / 2), 0], "screenrtshader", [vheight * ar_normal, vheight], [1, 1, 1], 1);
		else if ((vwidth / vheight) == ar_normal) // perfectly 4:3 window
			drawpic([0, 0], "screenrtshader", [vwidth, vheight], [1, 1, 1], 1);
		else // window is phone-shaped (?)
			drawpic([0, (vheight / 2) - ((vwidth * 0.75) / 2)], "screenrtshader", [vwidth, vwidth * 0.75], [1, 1, 1], 1);
	}

	*/
};