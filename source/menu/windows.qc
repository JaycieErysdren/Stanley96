//
// windows.qc
//

// main menu, first thing player is greeted with
void() menu_main =
{
	// size definitions
	vector pos = [0, -24];
	vector size = [128, 132];

	vector bpos = [0, 8];
	vector bsize = [size_x - 16, 20];

	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_END]);
	sui_push_frame(pos, size);
	
	// base box
	sui_fill([0, 0], size, MENU_BG, 1, 0);
	sui_border_box([0, 0], size, 2, MENU_BORDER, 1, 0);

	// content body
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
	
	if (clientstate() == 1)
		in_button("mm_start", bpos, bsize, _("m_start"), TRUE) ? localcmd("startgame\n") : 0;
	else if (clientstate() == 2)
		in_button("mm_resume", bpos, bsize, _("m_resume"), TRUE) ? m_close() : 0;

	bpos_y += 24; in_button("mm_settings", bpos, bsize, _("m_settings"), TRUE) ? current_menu = MENU_SETTINGS : 0;
	bpos_y += 24; in_button("mm_about", bpos, bsize, _("m_about"), TRUE) ? current_menu = MENU_ABOUT : 0;
	bpos_y += 24; in_button("mm_games", bpos, bsize, _("m_games"), TRUE) ? current_menu = MENU_GAMES : 0;
	bpos_y += 24; in_button("mm_quit", bpos, bsize, _("m_quit"), TRUE) ? localcmd("quit\n") : 0;

	sui_pop_frame();

	if (changed_settings)
	{
		localcmd("saveconfig\n");
		changed_settings = FALSE;
	}
};

// about menu, put credits or info here
void() menu_about =
{
	vector pos = [0, 0];
	vector size = [360, 280];
	
	vector bpos = [8, 32];

	sui_push_frame(pos, size);

	// base box
	sui_fill([0, 0], size, MENU_BG, 1, 0);
	sui_border_box([0, 0], size, 2, MENU_BORDER, 1, 0);

	// content body
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);

	sui_text([0, 4], MENU_TEXT_MEDIUM, _("m_about"), MENU_TEXT_1, 1, 0);

	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);

	sui_text(bpos, MENU_TEXT_SMALL, _("m_credits01"), MENU_TEXT_1, 1, 0);
	bpos_y += 16; sui_text(bpos, MENU_TEXT_SMALL, _("m_credits02"), MENU_TEXT_1, 1, 0);
	bpos_y += 16; sui_text(bpos, MENU_TEXT_SMALL, _("m_credits03"), MENU_TEXT_1, 1, 0);
	bpos_y += 32; sui_text(bpos, MENU_TEXT_SMALL, _("m_credits04"), MENU_TEXT_1, 1, 0);
	bpos_y += 16; sui_text(bpos, MENU_TEXT_SMALL, _("m_credits05"), MENU_TEXT_1, 1, 0);
	bpos_y += 16; sui_text(bpos, MENU_TEXT_SMALL, _("m_credits06"), MENU_TEXT_1, 1, 0);
	bpos_y += 16; sui_text(bpos, MENU_TEXT_SMALL, _("m_credits07"), MENU_TEXT_1, 1, 0);
	
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);

	in_button("ab_back", [-8, -8], [80, 20], _("m_back"), TRUE) ? current_menu = MENU_MAIN : 0;

	sui_pop_frame();
};

// settings menu, player adjusts everything here
void() menu_settings =
{
	// variables
	changed_settings = TRUE;

	// size definitions
	vector pos = [0, 0];
	vector size = [360, 280];

	vector tbsize = [(size_x / 2) - 2, 30];

	vector bpos = [8, 40];
	vector bsize = [(size_x * 0.5) - (8 * 2), 20];

	vector bsize_half = [(bsize_x / 2) - 2, bsize_y];

	// base box
	sui_push_frame(pos, size);
	sui_fill([0, 0], size, MENU_BG, 1, 0);
	sui_border_box([0, 0], size, 2, MENU_BORDER, 1, 0);

	// tabs
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);
	in_tab("st_tableft", [2, 2], tbsize, _("m_settings"), TAB_ACTIVE) ? current_menu = MENU_SETTINGS : 0;
	in_tab("st_tabright", [(size_x / 2), 2], tbsize, _("m_accessibility"), TAB_INACTIVE) ? current_menu = MENU_ACCESSIBILITY : 0;
	sui_fill([(size_x / 2) - 1, 2], [2, tbsize_y], MENU_BORDER, 1, 0);
	
	// content body
	sui_text(bpos, MENU_TEXT_SMALL, _("m_controls"), MENU_TEXT_1, 1, 0);
	//bpos_y += 16; bind_list("bindlist", bpos, [bsize_x, 160], binds_scroll);
	bpos_y += 168; in_cvarslider(bpos, [bsize_x, 32], [0.1, 10], "sensitivity", _("m_sensitivity"), "%.2f");

	bpos = [bsize_x + 24, 40];
	
	in_cvarslider(bpos, [bsize_x, 32], [0, 1], "volume", _("m_volume_game"), "%.2f");
	bpos_y += 36;
	in_cvarslider(bpos, [bsize_x, 32], [0, 1], "musicvolume", _("m_volume_music"), "%.2f");
	bpos_y += 44;

	sui_text(bpos, MENU_TEXT_SMALL, _("m_video"), MENU_TEXT_1, 1, 0);

	bpos_y += 16; in_button("st_fullscreen", bpos, bsize, _("m_fullscreen"), TRUE) ? localcmd("vid_fullscreen 2; vid_restart\n") : 0;
	bpos_y += 24; in_button("st_windowed", bpos, bsize, _("m_windowed"), TRUE) ? localcmd("vid_fullscreen 0; vid_restart\n") : 0;

	// 4:3 resolutions
	bpos_y += 24; in_button("st_800x600", bpos, bsize_half, "800x600", TRUE) ? localcmd("vid_fullscreen 0; vid_width 800; vid_height 600; vid_restart\n") : 0;
	in_button("st_1280x960", bpos + [84, 0], bsize_half, "1280x960", TRUE) ? localcmd("vid_fullscreen 0; vid_width 1280; vid_height 960; vid_restart\n") : 0;

	// 16:9 resolutions
	bpos_y += 24; in_button("st_1280x720", bpos, bsize_half, "1280x720", TRUE) ? localcmd("vid_fullscreen 0; vid_width 1280; vid_height 720; vid_restart\n") : 0;
	in_button("st_1920x1080", bpos + [84, 0], bsize_half, "1920x1080", TRUE) ? localcmd("vid_fullscreen 0; vid_width 1920; vid_height 1080; vid_restart\n") : 0;

	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);

	in_button("st_back", [-8, -8], [80, 20], _("m_back"), TRUE) ? current_menu = MENU_MAIN : 0;
	
	sui_pop_frame();
};

// accessibility menu, all the cool stuff is here
void() menu_accessibility =
{
	// variables
	changed_settings = TRUE;

	// size definitions
	vector pos = [0, 0];
	vector size = [360, 280];

	vector tbsize = [(size_x / 2) - 2, 30];

	vector bpos = [8, 40];
	vector bsize = [(size_x * 0.5) - (8 * 2), 20];

	vector bsize_half = [(bsize_x / 2) - 2, bsize_y];

	// base box
	sui_push_frame(pos, size);
	sui_fill([0, 0], size, MENU_BG, 1, 0);
	sui_border_box([0, 0], size, 2, MENU_BORDER, 1, 0);

	// tabs
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);
	in_tab("ac_tableft", [2, 2], tbsize, _("m_settings"), TAB_INACTIVE) ? current_menu = MENU_SETTINGS : 0;
	in_tab("ac_tabright", [(size_x / 2), 2], tbsize, _("m_accessibility"), TAB_ACTIVE) ? current_menu = MENU_ACCESSIBILITY : 0;
	sui_fill([(size_x / 2) - 1, 2], [2, tbsize_y], MENU_BORDER, 1, 0);

	// content body
	sui_text(bpos, MENU_TEXT_SMALL, _("m_miscellaneous"), MENU_TEXT_1, 1, 0);

	bpos_y += 24; in_cvarslider(bpos, [bsize_x, 32], [1, 5, 5], "accessibility_resolution_scale", _("m_resoluation_scale"), "%.0f");
	bpos_y += 40; in_cvarcheckbox("ac_colorblind", bpos, bsize, "accessibility_colorblind", _("m_colorblind")) ? cvar_toggle("accessibility_colorblind", [1, 0]) : 0;
	bpos_y += 32; in_cvarcheckbox("ac_crosshair", bpos, bsize, "accessibility_crosshair", _("m_crosshair")) ? cvar_toggle("accessibility_crosshair", [1, 0]) : 0;

	bpos = [bsize_x + 24, 40];

	sui_text(bpos, MENU_TEXT_SMALL, _("m_viewmode"), MENU_TEXT_1, 1, 0);

	bpos_y += 24; in_button("ac_viewmode0", bpos, bsize, _("m_viewmode0"), TRUE) ? localcmd("r_viewmode 0\n") : 0;
	bpos_y += 24; in_button("ac_viewmode1", bpos, bsize, _("m_viewmode1"), TRUE) ? localcmd("r_viewmode 1\n") : 0;
	bpos_y += 24; in_button("ac_viewmode2", bpos, bsize, _("m_viewmode2"), TRUE) ? localcmd("r_viewmode 2\n") : 0;

	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);

	in_button("ac_back", [-8, -8], [80, 20], _("m_back"), TRUE) ? current_menu = MENU_MAIN : 0;

	sui_pop_frame();
};

// menu for switching to different games

void() menu_games =
{	
	// size definitions
	vector pos = [0, 0];
	vector size = [360, 280];

	vector tbsize = [(size_x / 2) - 2, 30];

	vector bpos = [8, 32];
	vector bsize = [(size_x * 0.5) - (8 * 2), 20];

	// base box
	sui_push_frame(pos, size);
	sui_fill([0, 0], size, MENU_BG, 1, 0);
	sui_border_box([0, 0], size, 2, MENU_BORDER, 1, 0);

	// content body
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
	sui_text([0, 8], MENU_TEXT_MEDIUM, _("m_games"), MENU_TEXT_1, 1, 0);

	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);

	for (int g = 0; ; g++)
	{
		string gamedir = getgamedirinfo(g, GGDI_GAMEDIR);

		if (!gamedir)
			break;

		string description = getgamedirinfo(g, GGDI_DESCRIPTION);
		
		string gamebtn = strcat("gm_button", ftos(g));
		
		string command = getgamedirinfo(g, GGDI_LOADCOMMAND);

		if (bpos_y > (size_y - bsize_y))
			bpos = [bsize_x + 24, 32];

		in_button(gamebtn, bpos, bsize, description, TRUE) ? localcmd(command, "menu_restart") : 0;

		bpos_y += 24;
	}
		
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
	in_button("gm_back", [-8, -8], [80, 20], _("m_back"), TRUE) ? current_menu = MENU_MAIN : 0;

	sui_pop_frame();
};

// root menu controller
void(vector screensize) menu_root =
{
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);

	if (clientstate() == 1)
		sui_pic(display_pos, display_size, menu_bg, [1,1,1], 1, 0);
	else if (clientstate() == 2)
		sui_fill([0, 0], screensize, '0 0 0', 0.5, 0);

	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);

	switch (current_menu)
	{
		case MENU_MAIN: menu_main(); break;
		case MENU_ABOUT: menu_about(); break;
		case MENU_SETTINGS: menu_settings(); break;
		case MENU_ACCESSIBILITY: menu_accessibility(); break;
		case MENU_GAMES: menu_games(); break;
		default: break;
	}
};