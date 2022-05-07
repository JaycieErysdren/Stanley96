//
// GLOBAL CSQC VARIABLES
//

// in game

float current_line_time;
//string current_line_sample;

string caption_line1;
string caption_line2;
string caption_line3;

//float game_was_paused;

jsonnode caption_tree;
float caption_timer;
float caption_iteration;

float music_status;

//
// SPECIAL INITIALIZATIONS
//

jsonnode(string line) initialize_narrator =
{
	filestream f = fopen("json/captions.json", FILE_READNL);
	jsonnode tree = json_parse(fgets(f));
	fclose(f);
	
	if (tree)
	{
		// play narrator line specified
		//soundupdate(self, CHAN_VOICE, line, 1.0, ATTN_NONE, 100, 0, 0);
		//current_line_sample = line;
		localsound(line, CHAN_VOICE, cvar("volume"));
		caption_iteration = 0;
		caption_timer = time + 0.1;

		return tree[line];
	}

	return 0;
};

//
// ENGINE BUILTINS
//

void(float vwidth, float vheight, float notmenu) CSQC_UpdateView =
{
	clearscene();

	vector view_size;

	if (cvar("stanley_fullscreen") == 1)
		view_size = [320, 240];
	else
		view_size = [320, 200];

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
	setproperty(VF_VIEWPORT, [0, 0], view_size);

	setproperty(VF_DRAWENGINESBAR, 0);
	setproperty(VF_DRAWCROSSHAIR, 0);
	setproperty(VF_DRAWWORLD, 1);

	float view_ofs;
	
	if (cvar_string("mapname") == "wolf")
		view_ofs = 32;
	else
		view_ofs = 64;

	setproperty(VF_ORIGIN, getentity(player_localentnum, GE_ORIGIN) + [0, 0, view_ofs]);
	addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE);
	
	setproperty(VF_ANGLES, view_angles);

	renderscene();
	
	//drawpic([0, 0], "gfx/dither_layer.png", screensize, [1, 1, 1], 1);

	if (cvar_string("mapname") == "stanley" && getsoundtime(self, CHAN_BODY) < 0 && music_status != 1)
	{
		localsound("stanley/ghosts.wav", CHAN_BODY, 0.2 * cvar("volume"));
		music_status = 1;
	}

	current_line_time = getsoundtime(self, CHAN_VOICE);

	/* this sucks
	if (serverkeyfloat(SERVERKEY_PAUSESTATE) != 1)
	{
		if (game_was_paused == 1)
		{
			print("game was paused...\n");
			soundupdate(self, CHAN_VOICE, current_line_sample, 1, ATTN_NONE, 100, 0, 0);
			caption_iteration = 0;
			caption_timer = time + 0.1;
		}

		game_was_paused = 0;
		//print("game_was_paused: ", ftos(game_was_paused), "\n");
	}
	else
	{
		if (game_was_paused == 0)
		{
			print("game is paused...\n");
			soundupdate(self, CHAN_VOICE, "", -1, ATTN_NONE, 100, 0, -current_line_time);
			caption_iteration = 0;
			caption_timer = time + 0.1;
		}
		game_was_paused = 1;
	}
	*/

	// caption display machine
	// 1. check if a narrator sound is playing
	// 2. check if the timer has expired
	// 3. make sure caption_iteration hasn't reached the end yet
	if (current_line_time > 0 && caption_timer < time && caption_iteration < caption_tree.length)
	{
		// parse through the json tree to get the lines
		caption_line1 = (caption_tree.a[caption_iteration])["line1"].s;
		caption_line2 = (caption_tree.a[caption_iteration])["line2"].s;
		caption_line3 = (caption_tree.a[caption_iteration])["line3"].s;
		
		string captiontargetname = (caption_tree.a[caption_iteration])["target"].s;
		
		if (captiontargetname && captiontargetname != "")
			sendevent("FireTarget", "s", captiontargetname);

		// save caption_iteration to a tempvar because we need to iterate it before the timer is set
		// but the timer requires the original value
		float tempvar = caption_iteration;
		caption_iteration++;

		caption_timer = time + (caption_tree.a[tempvar])["time"].f;
	}
	else if (current_line_time < 0)
	{
		// reset when a line stops playing
		caption_line1 = "";
		caption_line2 = "";
		caption_line3 = "";
	}

	// screen color overlay
	drawfill([0, 0], [vwidth, vheight], stov(cvar_string("stanley_fade_color")), cvar("stanley_fade_alpha"));

	vector captionbox_size = [view_size_x, 40];

	if (cvar("stanley_fullscreen") == 0)
	{
		// narrator captionbox
		drawfill([0, screensize_y - captionbox_size_y], captionbox_size, [0.1, 0.1, 0.1], 1); // background
		drawpic([0, screensize_y - captionbox_size_y], "gfx/dither_overlay", captionbox_size, [1, 1, 1], 0.4); // dithery overlay
		drawstring([4, screensize_y - captionbox_size_y + 4], caption_line1, [8, 8], [1, 1, 1], 1, 0); // text line 1
		drawstring([4, screensize_y - captionbox_size_y + 16], caption_line2, [8, 8], [1, 1, 1], 1, 0); // text line 2
		drawstring([4, screensize_y - captionbox_size_y + 28], caption_line3, [8, 8], [1, 1, 1], 1, 0); // text line 3

		if (cvar("crosshair") == 1)
			drawstring([(view_size_x / 2) - 4, (view_size_y / 2) - 5], "+", [8, 8], [1, 1, 1], 1, 0);

		string captionbox_divider_text = "--------------------------------";
		float captionbox_divider_size = captionbox_size_x / strlen(captionbox_divider_text);
		drawstring([0, (screensize_y - captionbox_size_y) - (captionbox_divider_size / 2)], captionbox_divider_text, [captionbox_divider_size, captionbox_divider_size], [0.3, 0.3, 0.3], 1, 0);
	}

	setviewprop(VF_RT_DESTCOLOUR, (string)__NULL__);
		
	shaderforname("screenrtshader", "{\n{\nmap $rt:screenrt\nrgbgen vertex\n}\n}\n"); 

	//drawpic([(vwidth / 2) - ((vheight * ar_normal) / 2), 0], "screenrtshader", [vheight * ar_normal, vheight], [1, 1, 1], 1);

	vector display_pos;
	vector display_size;

	if (vheight < vwidth && (vheight * ar_normal) < vwidth )
	{
		// window is widescreen-shaped
		display_pos = [(vwidth / 2) - ((vheight * ar_normal) / 2), 0];
		display_size = [vheight * ar_normal, vheight];
	}
	else if ((vwidth / vheight) == ar_normal)
	{
		// perfectly 4:3 window
		display_pos = [0, 0];
		display_size = [vwidth, vheight];
	}
	else
	{
		// window is phone-shaped (?)
		display_pos = [0, (vheight / 2) - ((vwidth * 0.75) / 2)];
		display_size = [vwidth, vwidth * 0.75];
	}
	
	drawpic(display_pos, "screenrtshader", display_size, [1, 1, 1], 1);

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

void() CSQC_Parse_Event =
{
	switch(readbyte())
	{
		case EVENT_NARRATOR: caption_tree = initialize_narrator(readstring()); break;
		default: print("CSQC: i'm stupid and i don't know what to do\n"); break;
	}
};