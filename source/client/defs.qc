//
// defs.qc
//

jsonnode achievement_tree;

string achievement_title;
string achievement_description;
string achievement_image;

float achievement_timer;
float achievementbox_ypos;

float has_achievements;

vector skyroom_org;
vector skyroom_offs;
float skyroom_scale;
float skyroom_active;

vector skyroom_rotangle;
float skyroom_rotspeed;

float shake_frequency;
float shake_duration;
float shake_amplitude;
float shake_time;
vector shake_angle;

vector view_org;
vector view_offs;
vector view_finalangles;
vector view_finalorigin;

#if defined(DUKE)
entity cl_viewmodel;
#endif

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