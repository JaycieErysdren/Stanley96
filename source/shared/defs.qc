//
// shared.qc
//

//
// SHARED DEFINITIONS - ALL MODULES
//

// ASPECT RATIO VALUES

float ar_normal = 4 / 3;
float ar_widescreen = 16 / 9;
float ar_widescreen2 = 16 / 10;
float ar_ultrawide = 21 / 9;

vector aspect_fullscreen = [4, 3];
vector aspect_widescreen = [16, 9];
vector aspect_widescreen_alt = [16, 10];
vector aspect_ultrawide = [21, 9];

// USEFUL FUNCTIONS

// cvar_toggle
void(string cvar_s, vector values) cvar_toggle =
{
	if (cvar(cvar_s) == values[0])
		cvar_set(cvar_s, ftos(values[1]));
	else
		cvar_set(cvar_s, ftos(values[0]));
};

// CalculateDisplayPos
vector(vector screensize, vector aspect) CalculateDisplayPos =
{
	float ratio1 = aspect_x / aspect_y;
	float ratio2 = aspect_y / aspect_x;
	vector dpos;

	if (screensize_y < screensize_x && (screensize_y * ratio1) < screensize_x) // window is widescreen-shaped
		dpos = [(screensize_x / 2) - ((screensize_y * ratio1) / 2), 0];
	else if ((screensize_x / screensize_y) == ratio1) // perfectly 16:9 window
		dpos = [0, 0];
	else // window is phone-shaped (?)
		dpos = [0, (screensize_y / 2) - ((screensize_x * ratio2) / 2)];
	
	return dpos;
};

// CalculateDisplaySize
vector(vector screensize, vector aspect) CalculateDisplaySize =
{
	float ratio1 = aspect_x / aspect_y;
	float ratio2 = aspect_y / aspect_x;
	vector dsize;

	if (screensize_y < screensize_x && (screensize_y * ratio1) < screensize_x) // window is widescreen-shaped
		dsize = [screensize_y * ratio1, screensize_y];
	else if ((screensize_x / screensize_y) == ratio1) // perfectly 16:9 window
		dsize = [screensize_x, screensize_y];
	else // window is phone-shaped (?)
		dsize = [screensize_x, screensize_x * ratio2];

	return dsize;
};

// GLOBAL PLAYER VALUES
vector PLAYER_VIEW_OFFSET = [0, 0, 64];
vector PLAYER_SIZE_MIN = [-16, -16, 0];
vector PLAYER_SIZE_MAX = [16, 16, 72];

vector PLAYER_VIEW_OFFSET_CROUCHED = [0, 0, 28];
vector PLAYER_SIZE_MIN_CROUCHED = [-16, -16, 0];
vector PLAYER_SIZE_MAX_CROUCHED = [16, 16, 36];

// GENERIC MULTICAST EVENTS
enum
{
	EVENT_ACHIEVEMENT,
	EVENT_SKYROOM,
	EVENT_SHAKE,
	EVENT_WUI
};

// PROJECT-SPECIFIC MULTICAST EVENTS
#if defined(STANLEY)

enum
{
	EVENT_NARRATOR = 128
};

#endif

#if defined(DUKE) || defined(BITCHHELL)

enum
{
	EVENT_WEAPON = 128,
};

// EVENT_WEAPON VALUES
enum class weaponevents
{
	WEAPON_RELOAD,
	WEAPON_FIRE,
	WEAPON_MELEE
};

#endif

// PROJECT-SPECIFIC ITEM VALUES
#if defined(DUKE)

enum
{
	IT_FISTS,
	IT_PISTOL,
	IT_SHOTGUN,
	IT_RPG
};

#elif defined(BITCHHELL)

enum
{
	IT_BAT,
	IT_PISTOL,
	IT_SHOTGUN
};

#endif

// GLOBAL ENTITY FLAGS
const float FL_USEABLE = 4096;

// GLOBAL ENTITY FIELDS
.float state;
.float identity;

#if defined(CRAFTWORLD)
.float layer;

// world layers
enum
{
	LAYER_FRONT,
	LAYER_MIDDLE,
	LAYER_BACK
};

// cardinal directions
// directions[0] = NORTH
// directions[1] = EAST
// directions[2] = SOUTH
// directions[3] = WEST
vector directions[] = {[0, 90, 0], [0, 0, 0], [0, -90, 0], [0, 180, 0]};
#endif

//
// ENGINE BUILTINS
//

void(float prevprogs) init =
{
	// set up all the custom cvars
	autocvar(accessibility_resolution_scale, 1, "Accessibility: Screen resolution scaler");
	autocvar(accessibility_crosshair, 0, "Accessibility: Always-on crosshair");
	autocvar(accessibility_colorblind, 0, "Accessibility: Colorblind mode");
	autocvar(r_viewmode, 0, "Screen Viewmode: 0 = default 1 = fullscreen 2 = widescreen");
	autocvar(r_fade_color, [0, 0, 0], "On-screen fade color");
	autocvar(r_fade_alpha, 0, "On-screen fade alpha");
	autocvar(achievement_display_time, 5, "Achievement notifcation display time, in seconds");
	autocvar(achievement_enable, 1, "Controls whether or not achievements are enabled");
};

// MATH

// zeroconvert
// shorthand for turning -1 to 0 for keyvalues for which 0 is a valid non-default selection
// from Copper

float(float in) zeroconvert =
{
	if (in == -1) return 0;
	return in;
};

float(float in, float def) zeroconvertdefault =
{
	if (in == -1) return 0;
	if (in == 0) return def;
	return in;
};

// BoundsAngleSize
// for measuring how large an entity is along an arbitrary vector
// from Copper

float(vector v, vector s) BoundsAngleSize =
{
	v_x = fabs(v_x);
	v_y = fabs(v_y);
	v_z = fabs(v_z);
	
	// size is always + + + but this is in case I switch the parameters somewhere
	s_x = fabs(s_x);
	s_y = fabs(s_y);
	s_z = fabs(s_z);
	
	return v * s;
};


//
// SSQC MODULE DEFS
//

#if defined(SSQC)
	string __fullspawndata;
	.entity activator;

	float player_scale;

	entity sky_viewer;
	string skyfogcmd;
	string skyfogcmd2;

	.string skyname;

	//
	// MULTICAST FUNCTIONS
	//

	void(float event, float value, entity ent) EasyMulticastFloat =
	{
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, event);
		WriteFloat(MSG_MULTICAST, value);
		msg_entity = ent;
		multicast(ent.origin, MULTICAST_ONE_R);
	};

	void(float event, string value, entity ent) EasyMulticastString =
	{
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, event);
		WriteString(MSG_MULTICAST, value);
		msg_entity = ent;
		multicast(ent.origin, MULTICAST_ONE_R);
	};

	void(float event, vector value, entity ent) EasyMulticastVector =
	{
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, event);
		WriteCoord(MSG_MULTICAST, value_x);
		WriteCoord(MSG_MULTICAST, value_y);
		WriteCoord(MSG_MULTICAST, value_z);
		msg_entity = ent;
		multicast(ent.origin, MULTICAST_ONE_R);
	};

	void(float event, vector vec, float fl, entity ent) EasyMulticastVecAndFloat =
	{
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, event);
		WriteCoord(MSG_MULTICAST, vec_x);
		WriteCoord(MSG_MULTICAST, vec_y);
		WriteCoord(MSG_MULTICAST, vec_z);
		WriteFloat(MSG_MULTICAST, fl);
		msg_entity = ent;
		multicast(ent.origin, MULTICAST_ONE_R);
	};
#endif

//
// CSQC MODULE DEFS
//

#if defined(CSQC)
	.string targetname;

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

	#if defined(DUKE) || defined(BITCHHELL)
	entity cl_viewmodel1;
	entity cl_viewmodel2;
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
#endif

//
// MENU MODULE DEFS
//

#if defined(MENU)
	float menu_loadingbar_width;
	float menu_active;
	//float menu_gamestate;
	string menu_bg;
	string loading_bg;

	vector display_pos;
	vector display_size;

	float changed_settings;

	vector binds_scroll;

	// menu IDs

	enum
	{
		MENU_MAIN,
		MENU_SETTINGS,
		MENU_ABOUT,
		MENU_ACCESSIBILITY,
		MENU_GAMES,
		MENU_MAPS
	};

	// tab border IDs

	enum
	{
		TAB_INACTIVE,
		TAB_ACTIVE
	};

	float current_menu;

	// style definitions

	vector MENU_BG = '0.15 0.15 0.15';
	vector MENU_BG_DARK = '0.05 0.05 0.05';
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

	// open and close functions

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
#endif