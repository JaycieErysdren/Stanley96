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