//
// elements.qc
//

// interactable menu elements go here
// the "in_" means interactable

// generic button
float(string id, vector pos, vector size, string text, float frame) in_button =
{
	sui_push_frame(pos, size);

	if (frame == TRUE)
	{
		vector basecolor = sui_is_hovered(id) ? MENU_BUTTON + MENU_HIGHLIGHT * 0.1 : MENU_BUTTON; 
		basecolor = sui_is_held(id) ? MENU_BUTTON - MENU_DARKEN * 0.1 : basecolor;
		sui_fill([0, 0], size, basecolor, 0.6, 0);
		sui_border_box([0, 0], size, 1, MENU_BUTTON_BORDER, 0.4, 0);
	}

	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
	sui_text([0, 0], MENU_TEXT_SMALL, text, MENU_TEXT_1, 1, 0);	
	sui_action_element([0, 0], size, id, sui_noop);
	sui_pop_frame();

	return sui_is_clicked(id);
};

// generic tab
float(string id, vector pos, vector size, string text, float state) in_tab =
{
	sui_push_frame(pos, size);

	vector basecolor;

	if (state == TAB_ACTIVE)
	{
		basecolor = sui_is_hovered(id) ? MENU_BG + MENU_HIGHLIGHT * 0.1 : MENU_BG; 
		basecolor = sui_is_held(id) ? MENU_BG - MENU_DARKEN * 0.1 : basecolor;
	}
	else
	{
		basecolor = sui_is_hovered(id) ? MENU_BG_DARK + MENU_HIGHLIGHT * 0.1 : MENU_BG_DARK; 
		basecolor = sui_is_held(id) ? MENU_BG_DARK - MENU_DARKEN * 0.1 : basecolor;
	}

	sui_fill([0, 0], size, basecolor, 0.6, 0);

	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
	sui_text([0, 0], MENU_TEXT_SMALL, text, MENU_TEXT_1, 1, 0);	
	sui_action_element([0, 0], size, id, sui_noop);
	sui_pop_frame();

	return sui_is_clicked(id);
};

// generic checkbox
float(string id, vector pos, vector size, string cvar_s, string text) in_cvarcheckbox =
{
	sui_push_frame(pos, size);

	vector basecolor = sui_is_hovered(id) ? MENU_BUTTON + MENU_HIGHLIGHT * 0.1 : MENU_BUTTON; 
	basecolor = sui_is_held(id) ? MENU_BUTTON - MENU_DARKEN * 0.1 : basecolor;
	sui_fill([0, 0], [size_y, size_y], basecolor, 0.6, 0);
	sui_border_box([0, 0], [size_y, size_y], 1, MENU_BUTTON_BORDER, 0.4, 0);

	if (cvar(cvar_s) == 1)
		sui_pic([2, 2], [size_y - 4, size_y - 4], "gfx/x", [1, 1, 1], 1, 0);

	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
	sui_text([size_y + 4, 0], MENU_TEXT_SMALL, text, MENU_TEXT_1, 1, 0);	
	sui_action_element([0, 0], size, id, sui_noop);
	sui_pop_frame();

	return sui_is_clicked(id);
};

// generic slider
void(string id, vector pos, vector size, vector minmaxsteps, __inout float value) in_slider =
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

// cvar slider
void(vector pos, vector size, vector minmaxsteps, string cvar_s, string name, string format) in_cvarslider =
{
	float current = cvar(cvar_s);
	float old = current;
	sui_push_frame(pos, [size_x, size_y * 0.5 - 4]);
	sui_text([0, 0], MENU_TEXT_SMALL, name, MENU_TEXT_1, 1, 0);
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_START]);
	sui_text([0, 0], MENU_TEXT_SMALL, sprintf(format, current), MENU_TEXT_1, 1, 0);
	sui_pop_frame();
	in_slider(strcat(cvar_s, "sldr"), [pos_x, pos_y + size_y * 0.5], [size_x, size_y * 0.5], minmaxsteps, current);
	if (current != old) cvar_set(cvar_s, ftos(current));
};