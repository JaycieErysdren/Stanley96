vector MENU_BG = '0.15 0.15 0.15';
vector MENU_BG_DARK = '0 0 0';
vector MENU_BORDER = '1 1 1';
vector MENU_BUTTON = '0.2 0.2 0.2';
vector MENU_BUTTON_BORDER = '1 1 1';
vector MENU_TEXT_1 = '1 1 1';
vector MENU_TEXT_2 = '0.7 0.75 0.75';
vector MENU_HIGHLIGHT = '1 1 1';
vector MENU_DARKEN = '1 1 1';

vector MENU_TEXT_SMALL = '8 8 0';
vector MENU_TEXT_MEDIUM = '16 16 0';
vector MENU_TEXT_LARGE = '24 24 0';

void() input_tester =
{
	float char = 0;
	float scan = 0;
	string printme = "";
	while (sui_get_input(char, scan))
	{
		printme = strcat(printme, chr2str(char));
	}
	if (printme != "") printf("INPUT: %s\n", printme); 
};

void(string id, vector pos, vector size, float maxlen, __inout string text, __inout float cursor) text_input_control =
{
	vector textsize = [size_y - 4, size_y - 4];
	sui_push_frame(pos, size);
	vector basecolor = sui_is_hovered(id) ? MENU_BG_DARK + MENU_HIGHLIGHT * 0.08 : MENU_BG_DARK; 
	sui_fill([0, 0], size, basecolor, 0.6, 0);
	
	sui_text_input(id, [0, 0], size, text, cursor);
	
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
	float focused = sui_is_last_clicked(id);
	// Under focus
	focused ? sui_border_box([0, 0], size, 1, MENU_BORDER, 0.6, 0) : 0;	
	
	sui_push_frame([2, 0], [size_x - 4, size_y - 4]);
	
	float cursorx;
	if (stringwidth(text, 1, textsize) > size_x - 4)
	{
		sui_clip_to_frame();
		cursorx = 0;
		sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);
		sui_text([0, 0], textsize, text, MENU_TEXT_1, 1, 0);
	}
	else
	{
		cursorx = stringwidth(substring(text, 0, cursor), 1, textsize);
		sui_text([0, 0], textsize, text, MENU_TEXT_1, 1, 0);
	}
	if (focused) 
	{
		sui_fill([cursorx, 0], [2, textsize_y], MENU_TEXT_1, fabs(sin(time * 4)), 0);
	}
	sui_reset_clip();
	sui_pop_frame();
	
	sui_pop_frame();
};

float(string id, vector pos, vector size, string text) my_button =
{
	sui_push_frame(pos, size);
	vector basecolor = sui_is_hovered(id) ? MENU_BUTTON + MENU_HIGHLIGHT * 0.1 : MENU_BUTTON; 
	basecolor = sui_is_held(id) ? MENU_BUTTON - MENU_DARKEN * 0.1 : basecolor;
	sui_fill([0, 0], size, basecolor, 0.6, 0);
	sui_border_box([0, 0], size, 1, MENU_BUTTON_BORDER, 0.4, 0);
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
	sui_text([0, 0], MENU_TEXT_SMALL, text, MENU_TEXT_1, 1, 0);	
	sui_action_element([0, 0], size, id, sui_noop);
	sui_pop_frame();
	
	return sui_is_clicked(id);
};

float(string id, vector pos, vector size, string text) textbtn =
{
	sui_push_frame(pos, size);
	//vector basecolor = sui_is_hovered(id) ? MENU_BUTTON + MENU_HIGHLIGHT * 0.1 : MENU_BUTTON; 
	//basecolor = sui_is_held(id) ? MENU_BUTTON - MENU_DARKEN * 0.1 : basecolor;
	//sui_fill([0, 0], size, basecolor, 0.6, 0);
	//sui_border_box([0, 0], size, 1, MENU_BUTTON_BORDER, 0.4, 0);
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
	sui_text([0, 0], MENU_TEXT_MEDIUM, text, MENU_TEXT_1, 1, 0);	
	sui_action_element([0, 0], size, id, sui_noop);
	sui_pop_frame();
	
	return sui_is_clicked(id);
};

void(string id, vector pos, vector size, vector minmaxsteps, __inout float value) my_slider =
{
	sui_push_frame(pos, size);
	
	value = sui_slidercontrol(id, [0, 0], size, minmaxsteps, value, sui_slider_noop);
	float maxval = minmaxsteps[1];
	float sliderx = (value / maxval) * size_x;
	sui_fill([0, size_y * 0.25], [size_x, size_y * 0.5], MENU_BG_DARK, 1.0, 0);
	
	float is_active = sui_is_held(id) || (sui_is_hovered(id) && !sui_click_held());
	vector slider_ctrl_color = is_active ? MENU_BUTTON + MENU_HIGHLIGHT * 0.1 : MENU_BUTTON;
	sui_fill([sliderx - 2, 0], [4, size_y], slider_ctrl_color, 1.0, 0);
	
	sui_pop_frame();
};

void(vector pos, vector size, vector minmaxsteps, string cvar_s, string name, string format) cvar_slider =
{
	float current = cvar(cvar_s);
	float old = current;
	sui_push_frame(pos, [size_x, size_y * 0.5 - 4]);
	sui_text([0, 0], MENU_TEXT_SMALL, name, MENU_TEXT_1, 1, 0);
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_START]);
	sui_text([0, 0], MENU_TEXT_SMALL, sprintf(format, current), MENU_TEXT_1, 1, 0);
	sui_pop_frame();
	my_slider(strcat(cvar_s, "sldr"), [pos_x, pos_y + size_y * 0.5], [size_x, size_y * 0.5], minmaxsteps, current);
	if (current != old) cvar_set(cvar_s, ftos(current));
};

struct name_command {
	string name;
	string command;
};

name_command bindlist[] = 
{
	//{ _("m_key_use"), "+button3" },
	//{ _("m_key_moveforward"), "+forward" },
	//{ _("m_key_moveback"), "+back" },
	//{ _("m_key_moveleft"), "+moveleft" },
	//{ _("m_key_moveright"), "+moveright" },
	{ "FORWARD", "+forward" },
	{ "BACK", "+back" },
	{ "LEFT", "+moveleft" },
	{ "RIGHT", "+moveright" },
	{ "CROUCH", "+button4" },
	{ "KICK", "+button5" },
	{ "ATTACK", "+attack" },
	{ "RELOAD", "+button6" },
	{ "EQUIP BAT", "impulse 1" },
	{ "EQUIP PISTOL", "impulse 2" },
	{ "EQUIP SHOTGUN", "impulse 3" },
};

void(string id, vector pos, vector size, string name, string command) bind_button =
{
	sui_push_frame(pos, size);
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
	string key = sui_binder(id, [0, 0], size, name, command);
	if (sui_is_hovered(id)) sui_fill([0, 0], size, MENU_HIGHLIGHT, 0.1, 0);
	sui_text([6, 0], MENU_TEXT_SMALL, name, MENU_TEXT_1, 1, 0);
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);
	sui_text([-6, 0], MENU_TEXT_SMALL, key, MENU_TEXT_1, 1, 0);
	
	sui_pop_frame();
};


void(string id, vector pos, vector size, __inout vector scrollofs) bind_list =
{
	sui_fill(pos, size, MENU_BG_DARK, 0.75, 0);
	sui_list_view_begin(strcat(id, "scrl"), pos, size, [size_x - 6, 24], bindlist.length, scrollofs, [0, 6]);
	vector listitem_pos = '0 0 0';
	for (float index = sui_list_item(listitem_pos); index > -1; index = sui_list_item(listitem_pos))
	{
		sui_push_frame(listitem_pos, [size_x - 6, 24]);
		bind_button(strcat(id, ftos(index)), [0, 0], [size_x - 6, 24], bindlist[index].name, bindlist[index].command);
		sui_pop_frame();
	}
	sui_list_view_end();	
};

float current_menu;
const float MENU_MAIN = 1;
const float MENU_SETTINGS = 2;
const float MENU_HELP = 3;
const float MENU_MAPS = 4;
const float MENU_GAMES = 5;

vector binds_scroll;
float was_in_options;

void() settings_menu =
{
	was_in_options = TRUE;
	vector pos = [0, 0];
	vector size = [360, 280];
	
	sui_push_frame(pos, size);

	if (cvar_string("game") == "bitchhell")
		sui_pic([0, 0], size, "gfx/submenu_bg", [1, 1, 1], 1, 0);
	else
		sui_fill([0, 0], size, MENU_BG, 1, 0); // alpha 0.75

	sui_border_box([0, 0], size, 2, MENU_BORDER, 1, 0);
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);

	if (cvar_string("game") == "bitchhell")
		sui_pic([0, 0], [192, 64], "gfx/menu_settingsheader", [1, 1, 1], 1, 0);
	else
		sui_text([0, 4], MENU_TEXT_MEDIUM, _("m_settings"), MENU_TEXT_1, 1, 0);
	
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);
	
	float xpos = 8;
	float ypos = 64;
	float width = size_x * 0.5 - 8 * 2;
	sui_text([xpos, ypos], MENU_TEXT_SMALL, _("m_controls"), MENU_TEXT_1, 1, 0);
	ypos += 16;
	bind_list("bindlist", [xpos, ypos], [width, 160], binds_scroll);
	ypos += 160 + 8;

	if (cvar_string("game") == "bitchhell")
	{
		ypos = 64;
		xpos = 8 + width + 8 + 8;

		cvar_slider([xpos, ypos], [width, 32], [0, 1], "volume", _("m_volume_game"), "%.2f");
		ypos += 32 + 4;
		//cvar_slider([xpos, ypos], [width, 32], [0, 1], "musicvolume", _("m_volume_music"), "%.2f");
		//ypos += 32 + 4;

		cvar_slider([xpos, ypos], [width, 32], [0.1, 10], "sensitivity", _("m_sensitivity"), "%.2f");
	}
	else
	{
		cvar_slider([xpos, ypos], [width, 32], [0.1, 10], "sensitivity", _("m_sensitivity"), "%.2f");
		ypos += 32;

		ypos = 64;
		xpos = 8 + width + 8 + 8;
		
		cvar_slider([xpos, ypos], [width, 32], [0, 1], "volume", _("m_volume_game"), "%.2f");
		ypos += 32 + 4;
		cvar_slider([xpos, ypos], [width, 32], [0, 1], "musicvolume", _("m_volume_music"), "%.2f");
		ypos += 32 + 4 + 8;
	}

	//if (cvar_string("game") != "bitchhell")
	//{
		sui_text([xpos, ypos], MENU_TEXT_SMALL, _("m_video"), MENU_TEXT_1, 1, 0);
		ypos += 16;
		my_button("fs_btn", [xpos, ypos], [width, 20], _("m_fullscreen")) ? localcmd("vid_fullscreen 2; vid_restart\n") : 0;
		ypos += 24;
		my_button("wn_btn", [xpos, ypos], [width, 20], _("m_windowed")) ? localcmd("vid_fullscreen 0; vid_restart\n") : 0;
		ypos += 24;
		my_button("res_btn1", [xpos, ypos], [(width/2) - 2, 20], "800x600") ? localcmd("vid_fullscreen 0; vid_width 800; vid_height 600; vid_restart\n") : 0;
		my_button("res_btn2", [xpos+84, ypos], [(width/2) - 2, 20], "1280x960") ? localcmd("vid_fullscreen 0; vid_width 1280; vid_height 960; vid_restart\n") : 0;
		ypos += 24;
		my_button("res_btn3", [xpos, ypos], [(width/2) - 2, 20], "1280x720") ? localcmd("vid_fullscreen 0; vid_width 1280; vid_height 720; vid_restart\n") : 0;
		my_button("res_btn4", [xpos+84, ypos], [(width/2) - 2, 20], "1920x1080") ? localcmd("vid_fullscreen 0; vid_width 1920; vid_height 1080; vid_restart\n") : 0;
		ypos += 24;
		//sui_text([xpos, ypos], MENU_TEXT_SMALL, "Window can be resized.", MENU_TEXT_1, 0.8, 0);
		ypos += 16;
		//sui_set_align([SUI_ALIGN_START, SUI_ALIGN_END]);
		//my_button("stg_save", [8, -8], [80, 20], "Save") ? localcmd("saveconfig\n") : 0;
	//}

	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
	my_button("stg_back", [-8, -8], [80, 20], _("m_back")) ? current_menu = MENU_MAIN : 0;
	
	sui_pop_frame();
};

void() help_menu =
{
	vector pos = [0, 0];
	vector size = [360, 280];
	
	sui_push_frame(pos, size);
	
	if (cvar_string("game") == "bitchhell")
	{
		sui_pic([0, 0], size, "gfx/submenu_bg", [1, 1, 1], 1, 0);
	}
	else
	{
		sui_fill([0, 0], size, MENU_BG, 1, 0); // alpha 0.75
	}

	sui_border_box([0, 0], size, 2, MENU_BORDER, 1, 0); // alpha 0.3

	float xpos = 8;
	float ypos = 32;	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
	sui_text([0, 4], MENU_TEXT_MEDIUM, _("m_about"), MENU_TEXT_1, 1, 0);
	//ypos += 24;
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);

	if (cvar_string("game") == "bitchhell")
	{
		sui_text([xpos, ypos], MENU_TEXT_SMALL, "GAME: Jaycie Erysdren and evie_src", MENU_TEXT_1, 1, 0);
		ypos += 16;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, "MODELS: Kebby_ and fw", MENU_TEXT_1, 1, 0);
		ypos += 16;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, "SOUNDS: Jane Thrace, @theirATLAS and clover", MENU_TEXT_1, 1, 0);
		ypos += 32;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, "TRENCHBROOM: SleepwalkR, ericw, and others", MENU_TEXT_1, 1, 0);
		ypos += 16;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, "SUI TEMPLATE: Shpuld", MENU_TEXT_1, 1, 0);
		ypos += 16;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, "FTEQW: Forethought Entertainment", MENU_TEXT_1, 1, 0);
		ypos += 16;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, "QUAKE: id Software", MENU_TEXT_1, 1, 0);
		ypos += 32;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, "Created for the TRANS FXCKING RAGE JAM", MENU_TEXT_1, 1, 0);
		ypos += 16;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, "on itch.io", MENU_TEXT_1, 1, 0);
	}
	else
	{
		sui_text([xpos, ypos], MENU_TEXT_SMALL, _("m_credits01"), MENU_TEXT_1, 1, 0);
		ypos += 16;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, _("m_credits02a"), MENU_TEXT_1, 1, 0);
		ypos += 16;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, _("m_credits02b"), MENU_TEXT_1, 1, 0);
		ypos += 32;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, _("m_credits03"), MENU_TEXT_1, 1, 0);
		ypos += 16;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, _("m_credits04"), MENU_TEXT_1, 1, 0);
		ypos += 16;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, _("m_credits05"), MENU_TEXT_1, 1, 0);
		ypos += 16;
		sui_text([xpos, ypos], MENU_TEXT_SMALL, _("m_credits06"), MENU_TEXT_1, 1, 0);
	}
	
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
	my_button("hlp_back", [-8, -8], [80, 20], _("m_back")) ? current_menu = MENU_MAIN : 0;

	sui_pop_frame();
};

vector maps_scroll;
string mapname;

static float() scanmaplist =
{
	float length;
	
	search_begin("maps/*.bsp", 1, 0);

	length = search_getsize(1);
	
	search_end(1);
	
	return length;
}

static string(float i) scanmap =
{
	float length;
	
	search_begin("maps/*.bsp", 1, 0);

	mapname = search_getfilename(1, i);

	length = strlen(mapname);
	
	mapname = substring(mapname, 5, (length-9));
		
	search_end(1);
	
	return mapname;
}

string(string id, vector pos, vector size, string name) sui_loadmap =
{
	sui_action_element(pos, size, id, sui_noop);
	
	if (sui_is_released(id))
	{
		string command = strcat("map ", mapname);
		localcmd(command);
	}
	
	return "LOAD";
};

void(string id, vector pos, vector size, string name) maps_button =
{
	sui_push_frame(pos, size);
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
	string play = sui_loadmap(id, [0, 0], size, name);
	if (sui_is_hovered(id)) sui_fill([0, 0], size, MENU_HIGHLIGHT, 0.1, 0);
	sui_text([6, 0], MENU_TEXT_SMALL, name, MENU_TEXT_1, 1, 0);
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);
	sui_text([-6, 0], MENU_TEXT_SMALL, play, MENU_TEXT_1, 1, 0);
	
	sui_pop_frame();
};

void(string id, vector pos, vector size, __inout vector scrollofs) maps_list =
{
	float maps_number = scanmaplist();
	sui_fill(pos, size, MENU_BG_DARK, 0.75, 0);
	sui_list_view_begin(strcat(id, "scrl"), pos, size, [size_x - 6, 24], maps_number, scrollofs, [0, 6]);
	vector listitem_pos = '0 0 0';
	for (float index = sui_list_item(listitem_pos); index > -1; index = sui_list_item(listitem_pos))
	{
		sui_push_frame(listitem_pos, [size_x - 6, 24]);
		maps_button(strcat(id, ftos(index)), [0, 0], [size_x - 6, 24], scanmap(index));
		sui_pop_frame();
	}
	sui_list_view_end();
};

void() maps_menu =
{	
	vector pos = [0, 0];
	vector size = [360, 280];
	
	sui_push_frame(pos, size);

	sui_fill([0, 0], size, MENU_BG, 1, 0); // alpha 0.75
	sui_border_box([0, 0], size, 2, MENU_BORDER, 1, 0); // alpha 0.3

	float xpos = 8;
	float ypos = 32;
	
	maps_list("maplist", [xpos, ypos], [size_x-16, 200], maps_scroll);

	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
	sui_text([0, 8], MENU_TEXT_MEDIUM, _("m_maps"), MENU_TEXT_1, 1, 0);
	
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);
		
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
	my_button("maps_back", [-8, -8], [80, 20], _("m_back")) ? current_menu = MENU_MAIN : 0;

	sui_pop_frame();
};

void() games_menu =
{	
	vector pos = [0, 0];
	vector size = [360, 280];
	
	sui_push_frame(pos, size);

	sui_fill([0, 0], size, MENU_BG, 1, 0); // alpha 0.75
	sui_border_box([0, 0], size, 2, MENU_BORDER, 1, 0); // alpha 0.3

	float xpos = 8;
	float ypos = 32;

	float width = size_x * 0.5 - 8 * 2;

	for (int n = 0; ; n++)
	{
		string gamedir = getgamedirinfo(n, GGDI_GAMEDIR);
		if not(gamedir) break; // no more gamedirs
		string description = getgamedirinfo(n, GGDI_DESCRIPTION);
		
		string gamebtn = strcat("game_btn", ftos(n));
		
		string command = getgamedirinfo(n, GGDI_LOADCOMMAND);
		
		ypos += 24;
		my_button(gamebtn, [xpos, ypos], [width, 20], description) ? localcmd(command, "menu_restart") : 0;
	}

	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
	sui_text([0, 8], MENU_TEXT_MEDIUM, _("m_games"), MENU_TEXT_1, 1, 0);
	
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);
		
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
	my_button("games_back", [-8, -8], [80, 20], _("m_back")) ? current_menu = MENU_MAIN : 0;

	sui_pop_frame();
};

void() m_close;

float tweened_angle_modifier;
float tweened_angle;
float tweened_angle_mode;

float game_has_started;

void() main_menu =
{
	// completely throw away the menu sys if we're in bitch hell
	if (cvar_string("game") == "bitchhell")
	{
		vector screensize = getproperty(VF_SCREENVSIZE);
		vector ps = [0, 0];
		vector sz = [128, 128];

		sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);
		sui_push_frame(ps, sz);

		//==========
		// this code makes stuff rotate back and forth like hotline miami or whatever
		// i'm sure it could be streamlined, i just don't feel like it :)
		if (tweened_angle_modifier < -0.5)
			tweened_angle_mode = 0;
		else if (tweened_angle_modifier > 0.5)
			tweened_angle_mode = 1;

		if (tweened_angle_mode == 0)
			tweened_angle_modifier += 0.01;
		else if (tweened_angle_mode == 1)
			tweened_angle_modifier -= 0.01;

		tweened_angle += tweened_angle_modifier;
		//==========

		if (game_has_started == 0)
		{
			void() im_gonna_die =
			{
				localcmd("startgame\n");
				game_has_started = 1;
			}

			textbtn("mm_startgame", [(screensize_x / 2) - 64, ((screensize_y / 8) * 7) - 16], [128, 32], " ") ? im_gonna_die() : 0;
			drawrotpic([screensize_x / 2, (screensize_y / 8) * 7], [-64, -16], [64, 16], "gfx/menu_starttext", [1, 1, 1], 1, tweened_angle);
		}
		else if (game_has_started == 1)
		{
			drawrotpic([screensize_x / 2, screensize_y / 2], [-128, -32], [128, 32], "gfx/menu_pausedtext", [1, 1, 1], 1, tweened_angle);
			my_button("mm_resume", [(screensize_x / 2) - 100, (screensize_y / 8) * 7], [96, 24], "RESUME") ? m_close() : 0;
			my_button("mm_restart", [(screensize_x / 2) + 4, (screensize_y / 8) * 7], [96, 24], "RESTART") ? localcmd("startgame\n") : 0;
		}
		
		vector iconpos;
		
		if (screensize_y < screensize_x && (screensize_y * ar_normal) < screensize_x ) // window is widescreen-shaped
			iconpos = [(screensize_x / 2) - ((screensize_y * ar_normal) / 2) + ((screensize_y * ar_normal) - 24), 0];
		else if ((screensize_x / screensize_y) == ar_normal) // perfectly 4:3 window
			iconpos = [screensize_x - 24, 0];
		else // window is phone-shaped (?)
			iconpos = [screensize_x - 24, (screensize_y / 2) - ((screensize_x * 0.75) / 2)];

		drawpic(iconpos, "gfx/icon_question", [24, 24], [1, 1, 1], 1);
		drawpic(iconpos + [0, 24], "gfx/icon_gear", [24, 24], [1, 1, 1], 1);
		drawpic(iconpos + [0, 48], "gfx/icon_quit", [24, 24], [1, 1, 1], 1);
		textbtn("mm_info", iconpos, [24, 24], " ") ? current_menu = MENU_HELP : 0;
		textbtn("mm_settings", iconpos + [0, 24], [24, 24], " ") ? current_menu = MENU_SETTINGS : 0;
		textbtn("mm_quitgame", iconpos + [0, 48], [24, 24], " ") ? localcmd("quit\n") : 0;

		string ragejamtext = "This game was created for the TRANS FXCKING RAGE JAM";

		float ragejamtextsize;

		if (screensize_y < screensize_x && (screensize_y * ar_normal) < screensize_x ) // window is widescreen-shaped
		{
			ragejamtextsize = (screensize_y * ar_normal) / strlen(ragejamtext);
			sui_text([(screensize_x / 2) - ((screensize_y * ar_normal) / 2), screensize_y - ragejamtextsize], [ragejamtextsize, ragejamtextsize], ragejamtext, MENU_TEXT_1, 1, 0);
		}
		else if ((screensize_x / screensize_y) == ar_normal) // perfectly 4:3 window
		{
			ragejamtextsize = screensize_x / strlen(ragejamtext);
			sui_text([0, screensize_y - ragejamtextsize], [ragejamtextsize, ragejamtextsize], ragejamtext, MENU_TEXT_1, 1, 0);
		}
		else // window is phone-shaped (?)
		{
			// (screensize_y / 2) - ((screensize_x * 0.75) / 2)
			ragejamtextsize = screensize_x / strlen(ragejamtext);
			sui_text([0, (screensize_y / 2) - ((screensize_x * 0.75) / 2) + ((screensize_x * 0.75) - ragejamtextsize)], [ragejamtextsize, ragejamtextsize], ragejamtext, MENU_TEXT_1, 1, 0);
		}
		return;
	}

	float ypos = 32;
	vector pos = [0, -24];
	vector size = [128, 132];

	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_END]);
	sui_push_frame(pos, size);
	
	sui_fill([0, 0], size, MENU_BG, 1, 0);
	sui_border_box([0, 0], size, 2, MENU_BORDER, 1, 0);
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
	
	ypos = 8;
	
	if ((cvar_string("game") == "katabase"))
	{
		my_button("mm_maps", [0, ypos], [size_x - 16, 20], _("m_maps")) ? current_menu = MENU_MAPS : 0;
		ypos += 24;
		my_button("mm_games", [0, ypos], [size_x - 16, 20], _("m_games")) ? current_menu = MENU_GAMES : 0;
		ypos += 24;
		my_button("mm_settings", [0, ypos], [size_x - 16, 20], _("m_settings")) ? current_menu = MENU_SETTINGS : 0;
	}
	else
	{
		if (cvar("developer") == 1)
			my_button("mm_maps", [0, ypos-64], [size_x - 16, 20], _("m_maps")) ? current_menu = MENU_MAPS : 0;

		if (clientstate() == 1)
		{
			my_button("mm_start", [0, ypos], [size_x - 16, 20], _("m_start")) ? localcmd("startgame\n") : 0;
		}
		else
		{
			my_button("mm_resume", [0, ypos], [size_x - 16, 20], _("m_resume")) ? m_close() : 0;
		}

		ypos += 24;
		my_button("mm_help", [0, ypos], [size_x - 16, 20], _("m_about")) ? current_menu = MENU_HELP : 0;
		ypos += 24;
		my_button("mm_settings", [0, ypos], [size_x - 16, 20], _("m_settings")) ? current_menu = MENU_SETTINGS : 0;
		ypos += 24;

		if (cvar("developer") == 1)
			my_button("mm_games", [0, ypos], [size_x - 16, 20], _("m_games")) ? current_menu = MENU_GAMES : 0;
	}

	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_END]);
	my_button("mm_quit", [0, -8], [size_x - 16, 20], _("m_quit")) ? localcmd("quit\n") : 0;
	sui_pop_frame();
	
	if (was_in_options)
	{
		localcmd("saveconfig\n");
		was_in_options = FALSE;
	}
};

void(vector size) root_menu =
{
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
	
	if (clientstate() == 2)
	{
		sui_fill([0, 0], size, '0 0 0', 0.5, 0);
	}
	switch (current_menu)
	{
		case MENU_MAIN: main_menu(); break;
		case MENU_SETTINGS: settings_menu(); break;
		case MENU_HELP: help_menu(); break;
		case MENU_MAPS: maps_menu(); break;
		case MENU_GAMES: games_menu(); break;
		default: break;
	}
};