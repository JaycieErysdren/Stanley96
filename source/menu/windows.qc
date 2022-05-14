//
// windows.qc
//

// main menu, first thing player is greeted with
void() menu_main =
{
	float ypos = 32;
	vector pos = [0, -24];
	vector size = [128, 132];

	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_END]);
	sui_push_frame(pos, size);
	
	sui_fill([0, 0], size, MENU_BG, 1, 0);
	sui_border_box([0, 0], size, 2, MENU_BORDER, 1, 0);
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
	
	ypos = 8;
	
	if (clientstate() == 1)
		button("mm_start", [0, ypos], [size_x - 16, 20], _("m_start"), TRUE) ? localcmd("startgame\n") : 0;
	else
		button("mm_resume", [0, ypos], [size_x - 16, 20], _("m_resume"), TRUE) ? m_close() : 0;

	ypos += 24;
	button("mm_help", [0, ypos], [size_x - 16, 20], _("m_about"), TRUE) ? current_menu = MENU_HELP : 0;
	ypos += 24;
	button("mm_settings", [0, ypos], [size_x - 16, 20], _("m_settings"), TRUE) ? current_menu = MENU_SETTINGS : 0;
	ypos += 24;

	if (cvar("developer") == 1)
		button("mm_games", [0, ypos], [size_x - 16, 20], _("m_games"), TRUE) ? current_menu = MENU_GAMES : 0;

	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_END]);

	button("mm_quit", [0, -8], [size_x - 16, 20], _("m_quit"), TRUE) ? localcmd("quit\n") : 0;

	sui_pop_frame();
};


// root menu controller
void(vector size) menu_root =
{
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
	
	if (clientstate() == 1)
		sui_pic(display_pos, display_size, menu_bg, [1,1,1], 1, 0);
	else if (clientstate() == 2)
		sui_fill([0, 0], size, '0 0 0', 0.5, 0);

	switch (current_menu)
	{
		case MENU_MAIN: menu_main(); break;
		default: break;
	}
};