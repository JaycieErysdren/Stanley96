//
// builtins.qc
//

//
// ENGINE BUILTINS
//

void() m_init =
{
	setcursormode(TRUE, "gfx/cursor", [16, 16], 4);

	current_menu = MENU_MAIN;

	#if defined(STANLEY)
	menu_bg = strcat("gfx/menu_bg_0", ftos(ceil(random(0, 2))));
	loading_bg = strcat("gfx/menu_bg_0", ftos(ceil(random(0, 2))));
	#endif
};

void(vector screensize) m_calculatedisplay =
{
	if (cvar("r_viewmode") == 2 || cvar("r_viewmode") == 3 || cvar("r_viewmode") == 4) // any widescreen res
	{
		menu_bg = "gfx/menu_bg_widescreen";
		loading_bg = "gfx/menu_loading_widescreen";
		display_pos = CalculateDisplayPos(screensize, aspect_widescreen);
		display_size = CalculateDisplaySize(screensize, aspect_widescreen);
	}
	else // fullscreen (4:3)
	{
		menu_bg = "gfx/menu_bg_fullscreen";
		loading_bg = "gfx/menu_loading_fullscreen";
		display_pos = CalculateDisplayPos(screensize, aspect_fullscreen);
		display_size = CalculateDisplaySize(screensize, aspect_fullscreen);
	}
};

void(vector screensize) m_draw =
{
	m_calculatedisplay(screensize);

	sui_begin(screensize_x, screensize_y);

	if (menu_active == TRUE)
		menu_root(screensize);

	sui_end();
};

void(vector screensize, float opaque) m_drawloading =
{
	m_calculatedisplay(screensize);

	// bg
	drawfill([0, 0], [screensize_x, screensize_y], [0, 0, 0], 1);
	drawpic(display_pos, loading_bg, display_size, [1, 1, 1], 1);

	drawstring([display_pos_x, display_pos_y + ((screensize_y / 32) / 2)], "LOADING...", [screensize_y / 32, screensize_y / 32], [1, 1, 1], 1, 0);

	// fake loading bar
	menu_loadingbar_width += 32;
	menu_loadingbar_width = bound(0, menu_loadingbar_width, display_size_x);

	string menu_loadingbar_text = "THE END IS NEVER THE END IS NEVER";
	float menu_loadingbar_size = display_size_x / strlen(menu_loadingbar_text);
	drawfill([display_pos_x, (display_pos_y + display_size_y) - menu_loadingbar_size], [menu_loadingbar_width, display_size_y / menu_loadingbar_size], [1, 1, 1], 1);

#if defined(STANLEY)
	drawstring([display_pos_x, (display_pos_y + display_size_y) - menu_loadingbar_size], menu_loadingbar_text, [menu_loadingbar_size, menu_loadingbar_size], [0, 0, 0], 1, 0);
#endif
};

void(float wantmode) m_toggle =
{
	if (menu_active)
		m_close();
	else
		m_open();
};

float(float evtype, float scanx, float chary, float devid) Menu_InputEvent =
{
	float used = sui_input_event(evtype, scanx, chary, devid);

	if (evtype == IE_KEYDOWN && !used)
	{
		string cmd = getkeybind(scanx);

		switch (cmd)
		{
			case "togglemenu": m_close(); return TRUE; break;
			default: break;
		}
	}

#ifdef 0
	if (menu_active == TRUE)
	{
		if (menu_gamestate == 0)
		{
			switch (evtype)
			{
				case IE_KEYDOWN: menu_gamestate = 1; localcmd("startgame\n"); cvar_set("r_fade_alpha", "0"); return TRUE; break;
				default: break;
			}
		}
		else if (menu_gamestate == 1)
		{
			string cmd = getkeybind(scanx);

			switch (evtype)
			{
				case IE_KEYDOWN:
					switch (cmd)
					{
						case "togglemenu": m_close(); return TRUE; break;
						default: return FALSE; break;
					}
					break;
				default: break;
			}
		}
	}
#endif

	return FALSE;
};

void(string cmdtext) GameCommand =
{
	switch (cmdtext)
	{
		case "reset_loadingbar" : menu_loadingbar_width = 0; break;
		default: break;
	}
};