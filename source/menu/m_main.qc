float menu_active;

float splash_time;

void() m_init =
{
	splash_time = time + 2.5;
	registercommand("togglemenu2");
	// drawfont = loadfont("", "Courier Prime Code", "12,16,24,32,48,64,72,128,256,512", -1, 0, 0);
	setcursormode(TRUE,"gfx/cursor", [16, 16], cvar("vid_conautoscale"));
	current_menu = MENU_MAIN;

	tweened_angle_modifier = 0.51;
};

vector() randomofs = { return [random() - 0.5, random() - 0.5] * 2; };

void(vector screensize) m_draw =
{
	// clearscene();
	
	if (clientstate() == 1 && cvar_string("game") == "bitchhell")
	{
		if (screensize_y < screensize_x && (screensize_y * ar_normal) < screensize_x ) // window is widescreen-shaped
			drawpic([(screensize_x / 2) - ((screensize_y * ar_normal) / 2), 0], "gfx/menuback_normal", [screensize_y * ar_normal, screensize_y], [1, 1, 1], 1);
		else if ((screensize_x / screensize_y) == ar_normal) // perfectly 4:3 window
			drawpic([0, 0], "gfx/menuback_normal", [screensize_x, screensize_y], [1, 1, 1], 1);
		else // window is phone-shaped (?)
			drawpic([0, (screensize_y / 2) - ((screensize_x * 0.75) / 2)], "gfx/menuback_normal", [screensize_x, screensize_x * 0.75], [1, 1, 1], 1); // FIXME: kinda buggy when you make it really small
	}
	else if (clientstate() == 1)
	{
		if ((screensize_x / screensize_y) <= ar_normal)
			sui_pic(0, [screensize_x, screensize_y], "gfx/menuback_normal.png", [1,1,1], 1, 0);
		else if ((screensize_x / screensize_y) <= ar_widescreen)
			sui_pic(0, [screensize_x, screensize_y], "gfx/menuback_widescreen.png", [1,1,1], 1, 0);
		else
			sui_pic(0, [screensize_x, screensize_y], "gfx/menuback_widescreen.png", [1,1,1], 1, 0);
	}

	vector realsize = getproperty(VF_SCREENPSIZE);
	float target_conauto = 2;
	if (realsize_y < 600) target_conauto = 1;
	else if (realsize_y < 1200) target_conauto = 2;
	else target_conauto = 4;
	
	if (target_conauto != cvar("vid_conautoscale")) localcmd(sprintf("vid_conautoscale %f\n", target_conauto));
	
	sui_begin(screensize_x, screensize_y);
	if (menu_active)
		root_menu(screensize);
	
	/*	jaycie - new splash
	*/
	/*
	if (time < splash_time)
	{
		sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
		float diff = splash_time - time;
		float a;
		if (diff > 2.5)
		{
			a = 1 - (diff - 2.5) * 2;
			float xstretch = (diff - 2.5) * 4;
			sui_fill([0, 0], screensize, '0 0 0', 1, 0);
			sui_pic(1, [screensize_y * (0.7 + xstretch), screensize_y * 0.7], "gfx/tts_splash.png", '1 1 1', a * 0.75, 1);
		}
		else 
		{
			a = diff * 0.6;
			sui_fill([0, 0], screensize, '0 0 0', a * 2, 0);
			sui_pic(a, [screensize_y * 0.7, screensize_y * 0.7], "gfx/tts_splash.png", '1 1 1', a, 1);
		}
	}
	*/
	
	/*	jaycie - original splash tga
	if (time < splash_time)
	{
		sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
		float diff = splash_time - time;
		float a;
		if (diff > 2.5)
		{
			a = 1 - (diff - 2.5) * 2;
			float xstretch = (diff - 2.5) * 4;
			sui_fill([0, 0], screensize, '0 0 0', 1, 0);
			sui_pic(randomofs() * 1, [screensize_y * (0.7 + xstretch), screensize_y * 0.7], "gfx/splash.tga", '1 1 1', a * 0.75, 1);
			sui_pic(randomofs() * 1, [screensize_y * (0.7 + xstretch), screensize_y * 0.7], "gfx/splash.tga", '1 1 1', a * 0.75, 1);
		}
		else 
		{
			a = diff * 0.6;
			sui_fill([0, 0], screensize, '0 0 0', a * 2, 0);
			sui_pic(randomofs() * a, [screensize_y * 0.7, screensize_y * 0.7], "gfx/splash.tga", '1 1 1', a, 1);
			sui_pic(randomofs() * a, [screensize_y * (0.7 + random() * 0.05), screensize_y * 0.7], "gfx/splash.tga", '1 1 1', a * 0.5, 1);
		}
	}
	*/
	

	sui_end();
};

void() m_close =
{
	setkeydest(0);
	menu_active = FALSE;
};

void() m_open =
{
	setkeydest(2);
	menu_active = TRUE;
};

float(float evtype, float scanx, float chary, float devid) Menu_InputEvent =
{
	float used = sui_input_event(evtype, scanx, chary, devid);
	
	if (cvar_string("game") == "bitchhell" && game_has_started == 0 && current_menu == MENU_MAIN)
	{
		if (evtype == IE_KEYDOWN)
		{
			switch (scanx)
			{
				case K_MOUSE1: break;
				case K_MOUSE2: break;
				case K_MOUSE3: break;
				case K_MOUSE4: break;
				case K_MOUSE5: break;
				case K_MOUSE6: break;
				case K_MOUSE8: break;
				case K_MOUSE9: break;
				case K_MOUSE10: break;
				case K_MWHEELUP: break;
				case K_MWHEELDOWN: break;
				// meh
				//default: localcmd("startgame\n"); game_has_started = 1;
			}
		}
		/*
		switch (evtype)
		{
			case IE_KEYDOWN: localcmd("startgame\n"); game_has_started = 1;
		}
		*/
	}
	
	if (evtype == IE_KEYDOWN && !used)
	{
		string cmd = getkeybind(scanx);
		switch (cmd)
		{
		case "togglemenu":
			m_close();
			return TRUE;
			break;
		default: break;
		}
	}
	return FALSE;
};

float(string cmd) m_consolecommand =
{
	tokenize(cmd);
	switch (argv(0))
	{
	default: break;
	}

	return FALSE;
};

void(float wantmode) m_toggle =
{
	if (menu_active) m_close();
	else m_open();
};

void() m_shutdown =
{
};