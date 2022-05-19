//
// builtins.qc
//

void(float vwidth, float vheight, float notmenu) CSQC_UpdateView =
{
	clearscene();

	if (cvar("accessibility_resolution_scale") < 1)
		cvar_set("accessibility_resolution_scale", "1");

	if (cvar("accessibility_resolution_scale") > 5)
		cvar_set("accessibility_resolution_scale", "5");

	float scale = cvar("accessibility_resolution_scale");

	vector view_size;
	vector screensize;

	if (cvar("r_viewmode") == 1) // fullscreen (4:3 without narrator box)
	{
		view_size = [320 * scale, 240 * scale];
		screensize = [320 * scale, 240 * scale];
	}
	else if (cvar("r_viewmode") == 2) // widescreen (16:9 without narrator box)
	{
		view_size = [384 * scale, 216 * scale];
		screensize = [384 * scale, 216 * scale];
	}
	else if (cvar("r_viewmode") == 3) // widescreen (16:10 without narrator box)
	{
		view_size = [384 * scale, 240 * scale];
		screensize = [384 * scale, 240 * scale];
	}
	else if (cvar("r_viewmode") == 4) // ultrawide (21:9 without narrator box)
	{
		view_size = [560 * scale, 240 * scale];
		screensize = [560 * scale, 240 * scale];
	}
	else // normal (4:3 with narrator box)
	{
		view_size = [320 * scale, 200 * scale];
		screensize = [320 * scale, 240 * scale];
	}

	// set up 4:3 screen reisze
	drawfill([0, 0], [vwidth, vheight], [0, 0, 0], 1);
	setviewprop(VF_RT_DESTCOLOUR, "screenrt", -IMGFMT_R8G8B8A8, screensize);
	setproperty(VF_VIEWPORT, [0, 0], view_size);

	setproperty(VF_DRAWENGINESBAR, 0);
	setproperty(VF_DRAWCROSSHAIR, 0);

	setproperty(VF_DRAWWORLD, 1);
	addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE);

	UpdateShake();

	#if defined(CRAFTWORLD)
		setproperty(VF_ORIGIN, getentity(player_localentnum, GE_ORIGIN) + [0, -256, 64]);	
		setproperty(VF_ANGLES, [0, 90, 0]);
	#else
		// set the camera to where the player is

		// figure out crouch view_offs
		view_offs[2] += (getstatf(STAT_VIEWHEIGHT) == PLAYER_VIEW_OFFSET_CROUCHED[2]) ? -256 * frametime : 256 * frametime;
		view_offs[2] = bound(PLAYER_VIEW_OFFSET_CROUCHED[2], view_offs[2], PLAYER_VIEW_OFFSET[2]);

		if (cvar("chase_active") == 1)
		{
			vector headpos = getentity(player_localentnum, GE_ORIGIN) + view_offs;

			makevectors(view_angles);
			traceline(headpos, (headpos - (v_forward * 96)) + (v_up * 32), FALSE, self);

			view_finalorigin = trace_endpos;
			view_finalangles = view_angles + shake_angle;
		}
		else
		{
			view_finalorigin = getentity(player_localentnum, GE_ORIGIN) + view_offs;
			view_finalangles = view_angles + shake_angle;
		}

		setproperty(VF_ORIGIN, view_finalorigin);	
		setproperty(VF_ANGLES, view_finalangles);
	#endif

	#if defined(DUKE) || defined(BITCHHELL)
		UpdateWeapon();
	#endif

	view_org = getproperty(VF_ORIGIN);
	skyroom_active = getentity(getstatf(STAT_VIEW2), GE_ACTIVE);

	if (skyroom_active)
	{

		skyroom_org = getentity(getstatf(STAT_VIEW2), GE_ORIGIN);
		skyroom_scale = getentity(getstatf(STAT_VIEW2), GE_SKIN);

		skyroom_rotangle = getentity(getstatf(STAT_VIEW2), GE_ANGLES);
		skyroom_rotspeed = getentity(getstatf(STAT_VIEW2), GE_FRAME);

		skyroom_offs = [view_org_x / skyroom_scale, view_org_y / skyroom_scale, view_org_z / skyroom_scale];

		if (skyroom_rotspeed > 0)
			setproperty(VF_SKYROOM_CAMERA, skyroom_org + skyroom_offs, (void)skyroom_rotangle, (void)(time * skyroom_rotspeed));
		else
			setproperty(VF_SKYROOM_CAMERA, skyroom_org + skyroom_offs);
	}

	//print("active: ", ftos(skyroom_active), " entnum: ", ftos(getstatf(STAT_VIEW2)), strcat(" origin: ", ftos(skyroom_org_x), " ", ftos(skyroom_org_y), " ", ftos(skyroom_org_z)), " scale: ", ftos(skyroom_scale), "\n"); 

	renderscene();

	#if defined(DUKE)
		vector sbar_pos;
		vector sbar_size = [320 * scale, 40 * scale];
		float sbar_alpha;

		if (cvar("r_viewmode") == 1)
		{
			sbar_alpha = 0.5;
			sbar_pos = [0, screensize_y - sbar_size_y];
		}
		else if (cvar("r_viewmode") == 2 || cvar("r_viewmode") == 3 || cvar("r_viewmode") == 4)
		{
			sbar_alpha = 0.5;
			sbar_pos = [(screensize_x - sbar_size_x) / 2, screensize_y - sbar_size_y];
		}
		else
		{
			sbar_alpha = 1;
			sbar_pos = [0, screensize_y - sbar_size_y];
		}

		drawpic(sbar_pos, "gfx/hud/sbar_temp1", sbar_size, [1, 1, 1], sbar_alpha);
		drawpic(sbar_pos, "gfx/hud/sbar_temp2", sbar_size, [1, 1, 1], 1);
	#endif

	#if defined(STANLEY)
		if (cvar_string("mapname") == "stanley" && getsoundtime(self, CHAN_BODY) < 0 && music_status != 1)
		{
			localsound("stanley/ghosts.wav", CHAN_BODY, 0.2 * cvar("volume"));
			music_status = 1;
		}

		current_line_time = getsoundtime(self, CHAN_VOICE);

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
				sendevent("FireTarget", "ss", captiontargetname, "Trigger");

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
		drawfill([0, 0], [vwidth, vheight], stov(cvar_string("r_fade_color")), cvar("r_fade_alpha"));

		vector captionbox_size = [320 * scale, 40 * scale];
		vector captionbox_textsize = [8 * scale, 8 * scale];
		vector captionbox_pos;

		if (cvar("r_viewmode") == 1)
		{
			captionbox_pos = [0, screensize_y - captionbox_size_y];

			if (caption_line1 != "" || caption_line2 != "" || caption_line3 != "")
				drawfill(captionbox_pos, captionbox_size, [0.1, 0.1, 0.1], 0.5); // background color
		}
		else if (cvar("r_viewmode") == 2 || cvar("r_viewmode") == 3 || cvar("r_viewmode") == 4)
		{
			captionbox_pos = [(screensize_x - captionbox_size_x) / 2, screensize_y - captionbox_size_y];

			if (caption_line1 != "" || caption_line2 != "" || caption_line3 != "")
				drawfill(captionbox_pos, captionbox_size, [0.1, 0.1, 0.1], 0.5); // background color
		}
		else
		{
			captionbox_pos = [0, screensize_y - captionbox_size_y];

			// narrator captionbox base
			drawfill(captionbox_pos, captionbox_size, [0.1, 0.1, 0.1], 1); // background color
			drawpic(captionbox_pos, "gfx/dither_overlay", captionbox_size, [1, 1, 1], 0.4); // dithery overlay

			string captionbox_divider_text = "--------------------------------";
			float captionbox_divider_size = captionbox_size_x / strlen(captionbox_divider_text);
			drawstring(captionbox_pos - [0, captionbox_divider_size / 2], captionbox_divider_text, [captionbox_divider_size, captionbox_divider_size], [0.3, 0.3, 0.3], 1, 0);
		}

		drawstring(captionbox_pos + [4 * scale, 4 * scale], caption_line1, captionbox_textsize, [1, 1, 1], 1, 0); // text line 1
		drawstring(captionbox_pos + [4 * scale, 16 * scale], caption_line2, captionbox_textsize, [1, 1, 1], 1, 0); // text line 2
		drawstring(captionbox_pos + [4 * scale, 28 * scale], caption_line3, captionbox_textsize, [1, 1, 1], 1, 0); // text line 3
	#endif

	vector crosshair_size = [8 * scale, 8 * scale];
	vector crosshair_pos = [(view_size_x / 2) - (crosshair_size_x / 2), (view_size_y / 2) - (crosshair_size_x / 1.6)];

	if (cvar("crosshair") == 1 || cvar("accessibility_crosshair") == 1)
		drawstring(crosshair_pos, "+", crosshair_size, [1, 1, 1], 1, 0);	

	//=======================================
	// achievement display machine
	//

	vector achievementbox_textsize = [8 * scale, 8 * scale];

	achievementbox_ypos += (achievement_timer < time) ? -192 * frametime : 192 * frametime;
	achievementbox_ypos = bound(-16 * scale, achievementbox_ypos, 4 * scale);

	if (achievement_timer > time)
	{
		achievement_title = achievement_tree["title"].s;
		achievement_description = achievement_tree["description"].s;
		achievement_image = achievement_tree["image"].s;
	}

	drawfill([0, achievementbox_ypos - (4 * scale)], [(strlen(achievement_title) * (8 * scale)) + (24 * scale), 16 * scale], [0.1, 0.1, 0.1], 0.5); // background color

	if (achievement_image != "")
		drawpic([2 * scale, achievementbox_ypos - (2 * scale)], achievement_image, [12 * scale, 12 * scale], [1, 1, 1], 1); // achievement image

	drawstring([16 * scale, achievementbox_ypos], achievement_tree["title"].s, [8 * scale, 8 * scale], [1, 1, 1], 1, 0); // achievement title

	//
	// end achievement machine
	//=======================================

	setviewprop(VF_RT_DESTCOLOUR, (string)__NULL__);
		
	shaderforname("screenrtshader", "{\n{\nmap $rt:screenrt\nrgbgen vertex\n}\n}\n"); 

	vector display_pos;
	vector display_size;

	if (cvar("r_viewmode") == 2) // widescreen 16:9
	{
		if (vheight < vwidth && (vheight * ar_widescreen) < vwidth)
		{
			// window is widescreen-shaped
			display_pos = [(vwidth / 2) - ((vheight * ar_widescreen) / 2), 0];
			display_size = [vheight * ar_widescreen, vheight];
		}
		else if ((vwidth / vheight) == ar_widescreen)
		{
			// perfectly 16:9 window
			display_pos = [0, 0];
			display_size = [vwidth, vheight];
		}
		else
		{
			// window is phone-shaped (?)
			display_pos = [0, (vheight / 2) - ((vwidth * 0.5625) / 2)];
			display_size = [vwidth, vwidth * 0.5625];
		}
	}
	else if (cvar("r_viewmode") == 3) // widescreen 16:10
	{
		if (vheight < vwidth && (vheight * ar_widescreen2) < vwidth)
		{
			// window is widescreen-shaped
			display_pos = [(vwidth / 2) - ((vheight * ar_widescreen2) / 2), 0];
			display_size = [vheight * ar_widescreen2, vheight];
		}
		else if ((vwidth / vheight) == ar_widescreen2)
		{
			// perfectly 16:9 window
			display_pos = [0, 0];
			display_size = [vwidth, vheight];
		}
		else
		{
			// window is phone-shaped (?)
			display_pos = [0, (vheight / 2) - ((vwidth * 0.625) / 2)];
			display_size = [vwidth, vwidth * 0.625];
		}
	}
	else if (cvar("r_viewmode") == 4) // ultrawide 21:9
	{
		if (vheight < vwidth && (vheight * ar_ultrawide) < vwidth)
		{
			// window is widescreen-shaped
			display_pos = [(vwidth / 2) - ((vheight * ar_ultrawide) / 2), 0];
			display_size = [vheight * ar_ultrawide, vheight];
		}
		else if ((vwidth / vheight) == ar_ultrawide)
		{
			// perfectly 16:9 window
			display_pos = [0, 0];
			display_size = [vwidth, vheight];
		}
		else
		{
			// window is phone-shaped (?)
			display_pos = [0, (vheight / 2) - ((vwidth * 0.4285) / 2)];
			display_size = [vwidth, vwidth * 0.4285];
		}
	}
	else // fullscreen (4:3)
	{
		if (vheight < vwidth && (vheight * ar_normal) < vwidth)
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
	}

	// finally draw the screen
	drawpic(display_pos, "screenrtshader", display_size, [1, 1, 1], 1);

	ResetShake();
};

void(float apilevel, string enginename, float engineversion) CSQC_Init =
{
	registercommand("achievement_get");
	registercommand("achievement_clearall");
	registercommand("achievement_list");
	registercommand("ent_fire");
	
	// set skybox
	localcmd("sky ", serverkey("skyname"), "\n");

	// set default view height
	view_offs = [0, 0, 64];

	#if defined(DUKE) || defined(BITCHHELL)
	cl_viewmodel = spawn();
	cl_viewmodel.classname = "vm";
	cl_viewmodel.renderflags = RF_VIEWMODEL;
	cl_viewmodel.effects |= EF_NOSHADOW;
	cl_viewmodel.drawmask = MASK_VIEWMODEL;
	setsize(cl_viewmodel, [0, 0, 0], [0, 0, 0]);
	#endif

	#if defined(DUKE)
	precache_model("models/v_models/v_sniper.iqm");
	precache_model("models/v_models/v_shotgun.iqm");
	precache_model("models/v_models/v_shotgun_hn.iqm");
	precache_sound("weapons/shotgun_deploy.wav");
	precache_sound("weapons/shotgun_fire.wav");
	setmodel(cl_viewmodel, "models/v_models/v_shotgun_hn.iqm");
	SetEntityFrame(cl_viewmodel, F_SHOTGUN_DRAW);
	#endif
};

float(string cmd) CSQC_ConsoleCommand =
{
	tokenize(cmd);

	switch(argv(0))
	{
		case "ent_fire" : TriggerMapEntity(argv(1), argv(2)); return TRUE;
		case "achievement_clearall" : clear_achievements(); return TRUE;
		case "achievement_get" : if (argv(1) != "") achievement_tree = initialize_achievement(argv(1)); return TRUE;
		default: return FALSE;
	}

	return TRUE;
};

void() CSQC_Parse_Event =
{
	switch(readbyte())
	{
		case EVENT_ACHIEVEMENT: achievement_tree = initialize_achievement(readstring()); break;
		case EVENT_SKYROOM: skyroom_org = [readcoord(), readcoord(), readcoord()]; skyroom_scale = readfloat(); skyroom_active = 1; break;
		case EVENT_SHAKE: shake_duration = readfloat(); shake_amplitude = readfloat(); shake_frequency = readfloat(); shake_time = shake_duration; break;
		#if defined(DUKE) || defined(BITCHHELL)
		case EVENT_WEAPON: WeaponEvent(readfloat()); break;
		#endif
		#if defined(STANLEY)
		case EVENT_NARRATOR: caption_tree = initialize_narrator(readstring()); break;
		#endif
		default: print("^1CSQC_Parse_Event: ^dUnknown Event!\n"); break;
	}
};

void(string rendererdescription) CSQC_RendererRestarted =
{
	// set skybox
	localcmd("sky ", serverkey("skyname"), "\n");
};