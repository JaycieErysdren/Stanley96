//
// builtins.qc
//

//
// SPECIAL FUNCTIONS
//

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

//
// ENGINE BUILTINS
//

void() m_init =
{
	setcursormode(TRUE, "gfx/cursor", [16, 16], 4);
	#if defined(STANLEY)
	menu_bg = strcat("gfx/menu_bg_0", ftos(ceil(random(0, 2))));
};

void(vector screensize) m_draw =
{
	if (menu_active == FALSE)
	{
		return;
	}
	else if (menu_active == TRUE)
	{
		vector display_pos;
		vector display_size;

		if (screensize_y < screensize_x && (screensize_y * ar_normal) < screensize_x )
		{
			// window is widescreen-shaped
			display_pos = [(screensize_x / 2) - ((screensize_y * ar_normal) / 2), 0];
			display_size = [screensize_y * ar_normal, screensize_y];
		}
		else if ((screensize_x / screensize_y) == ar_normal)
		{
			// perfectly 4:3 window
			display_pos = [0, 0];
			display_size = [screensize_x, screensize_y];
		}
		else
		{
			// window is phone-shaped (?)
			display_pos = [0, (screensize_y / 2) - ((screensize_x * 0.75) / 2)];
			display_size = [screensize_x, screensize_x * 0.75];
		}

		if (menu_gamestate == 0) // game has not started
		{
			// bg
			drawfill([0, 0], [screensize_x, screensize_y], [0, 0, 0], 1);
			drawpic(display_pos, menu_bg, display_size, [1, 1, 1], 1);

			drawstring([display_pos_x + ((screensize_y / 32) / 2), display_pos_y + ((screensize_y / 32) / 2)], "PRESS AND KEY TO START", [screensize_y / 32, screensize_y / 32], [1, 1, 1], 1, 0);
		}
		else if (menu_gamestate == 1)  // game has started
		{
			drawfill([0, 0], [screensize_x, screensize_y], [0, 0, 0], 1);
			drawpic(display_pos, menu_bg, display_size, [1, 1, 1], 1);
			drawstring([display_pos_x + ((screensize_y / 32) / 2), (display_pos_y + display_size_y) - (screensize_y / 32) - ((screensize_y / 32) / 2)], "BEGIN THE GAME AGAIN", [screensize_y / 32, screensize_y / 32], [1, 1, 1], 1, 0);
		}
	}
};

void(vector screensize, float opaque) m_drawloading =
{
	vector display_pos;
	vector display_size;

	if (screensize_y < screensize_x && (screensize_y * ar_normal) < screensize_x )
	{
		// window is widescreen-shaped
		display_pos = [(screensize_x / 2) - ((screensize_y * ar_normal) / 2), 0];
		display_size = [screensize_y * ar_normal, screensize_y];
	}
	else if ((screensize_x / screensize_y) == ar_normal)
	{
		// perfectly 4:3 window
		display_pos = [0, 0];
		display_size = [screensize_x, screensize_y];
	}
	else
	{
		// window is phone-shaped (?)
		display_pos = [0, (screensize_y / 2) - ((screensize_x * 0.75) / 2)];
		display_size = [screensize_x, screensize_x * 0.75];
	}

	// bg
	drawfill([0, 0], [screensize_x, screensize_y], [0, 0, 0], 1);
	drawpic(display_pos, menu_bg, display_size, [1, 1, 1], 1);

	drawstring([display_pos_x, display_pos_y + ((screensize_y / 32) / 2)], "LOADING...", [screensize_y / 32, screensize_y / 32], [1, 1, 1], 1, 0);

	//drawstring([display_pos_x, display_size_y - (screensize_y / 32)], "THE END IS NEVER THE END IS NEVER THE END IS NEVER THE", [screensize_y / 32, screensize_y / 32], [1, 1, 1], 1, 0);

	menu_loadingbar_width += 32;
	menu_loadingbar_width = bound(0, menu_loadingbar_width, display_size_x);

	// fake loading bar
	string menu_loadingbar_text = "THE END IS NEVER THE END IS NEVER";
	float menu_loadingbar_size = display_size_x / strlen(menu_loadingbar_text);
	drawfill([display_pos_x, (display_pos_y + display_size_y) - menu_loadingbar_size], [menu_loadingbar_width, display_size_y / menu_loadingbar_size], [1, 1, 1], 1);

	drawstring([display_pos_x, (display_pos_y + display_size_y) - menu_loadingbar_size], menu_loadingbar_text, [menu_loadingbar_size, menu_loadingbar_size], [0, 0, 0], 1, 0);
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