//
// defs.qc
//

#if defined(STANLEY)

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

#endif

//
// CUSTOM DRAWMASKS
//

enum
{
	MASK_HIGHLIGHT = 16
};