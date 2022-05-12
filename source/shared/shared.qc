//
// ASPECT RATIO VALUES
//

float ar_normal = 4 / 3;
float ar_laptop1 = 1366 / 768;
float ar_widescreen = 16 / 9;

//
// MULTICAST EVENTS
//

enum
{
	EVENT_NARRATOR
};

//
// GLOBAL ENTITY FLAGS
//

const float FL_USEABLE = 4096;

//
// GLOBAL ENTITY FIELDS
//

.float state;
.float identity;

//
// ENGINE BUILTINS
//

void(float prevprogs) init =
{
	// set up all the custom cvars
	autocvar(_ents_only, 0, "DEBUG: Draw only entities");
	autocvar(accessibility_resolution_scale, 1, "Accessibility: Screen resolution scaler");
	autocvar(accessibility_crosshair, 0, "Accessibility: Always-on crosshair");
	autocvar(accessibility_colorblind, 0, "Accessibility: Colorblind mode");
	autocvar(stanley_view, 0, "Stanley96: 0 = default 1 = fullscreen 2 = widescreen");
	autocvar(stanley_fade_color, [0, 0, 0], "Stanley96: On-screen fade color");
	autocvar(stanley_fade_alpha, 0, "Stanley96: On-screen fade alpha");
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