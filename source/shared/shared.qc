//
// shared.qc
//

//
// USEFUL FUNCTIONS
//

void(string cvar_s, vector values) cvar_toggle =
{
	if (cvar(cvar_s) == values[0])
		cvar_set(cvar_s, ftos(values[1]));
	else
		cvar_set(cvar_s, ftos(values[0]));
};

//
// ASPECT RATIO VALUES
//

float ar_normal = 4 / 3;
float ar_laptop1 = 1366 / 768;
float ar_widescreen = 16 / 9;

//
// MULTICAST EVENTS
//

// generic events - 1 through 127

enum
{
	EVENT_ACHIEVEMENT,
	EVENT_SKYROOM
};

// project-specific events - always start at 128

#if defined(STANLEY)

enum
{
	EVENT_NARRATOR = 128
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