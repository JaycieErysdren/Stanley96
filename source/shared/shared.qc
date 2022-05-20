//
// shared.qc
//

//
// ASPECT RATIO VALUES
//

float ar_normal = 4 / 3;
float ar_widescreen = 16 / 9;
float ar_widescreen2 = 16 / 10;
float ar_ultrawide = 21 / 9;

vector aspect_fullscreen = [4, 3];
vector aspect_widescreen = [16, 9];
vector aspect_widescreen_alt = [16, 10];
vector aspect_ultrawide = [21, 9];

//
// USEFUL FUNCTIONS
//

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
	vector display_pos;

	if (screensize_y < screensize_x && (screensize_y * ratio1) < screensize_x) // window is widescreen-shaped
		display_pos = [(screensize_x / 2) - ((screensize_y * ratio1) / 2), 0];
	else if ((screensize_x / screensize_y) == ratio1) // perfectly 16:9 window
		display_pos = [0, 0];
	else // window is phone-shaped (?)
		display_pos = [0, (screensize_y / 2) - ((screensize_x * ratio2) / 2)];
	
	return display_pos;
};

// CalculateDisplaySize
vector(vector screensize, vector aspect) CalculateDisplaySize =
{
	float ratio1 = aspect_x / aspect_y;
	float ratio2 = aspect_y / aspect_x;
	vector display_size;

	if (screensize_y < screensize_x && (screensize_y * ratio1) < screensize_x) // window is widescreen-shaped
		display_size = [screensize_y * ratio1, screensize_y];
	else if ((screensize_x / screensize_y) == ratio1) // perfectly 16:9 window
		display_size = [screensize_x, screensize_y];
	else // window is phone-shaped (?)
		display_size = [screensize_x, screensize_x * ratio2];

	return display_size;
};

//
// GLOBAL PLAYER VALUES
//

vector PLAYER_VIEW_OFFSET = [0, 0, 64];
vector PLAYER_SIZE_MIN = [-16, -16, 0];
vector PLAYER_SIZE_MAX = [16, 16, 72];

vector PLAYER_VIEW_OFFSET_CROUCHED = [0, 0, 28];
vector PLAYER_SIZE_MIN_CROUCHED = [-16, -16, 0];
vector PLAYER_SIZE_MAX_CROUCHED = [16, 16, 36];

//
// MULTICAST EVENTS
//

// generic events - 0 through 127

enum
{
	EVENT_ACHIEVEMENT,
	EVENT_SKYROOM,
	EVENT_SHAKE,
	EVENT_WUI
};

// project-specific events - always start at 128

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

// EVENT_WEAPON variables
enum class weaponevents
{
	WEAPON_RELOAD,
	WEAPON_FIRE,
	WEAPON_MELEE
};

#endif

//
// ITEM VALUSE
//

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

//
// GLOBAL ENTITY FLAGS
//

const float FL_USEABLE = 4096;

//
// GLOBAL ENTITY FIELDS
//

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
enum
{
	D_NORTH,
	D_SOUTH,
	D_EAST,
	D_WEST
};
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

//
// MATH
//

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