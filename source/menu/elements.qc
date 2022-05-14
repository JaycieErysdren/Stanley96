//
// elements.qc
//

float(string id, vector pos, vector size, string text, float frame) button =
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