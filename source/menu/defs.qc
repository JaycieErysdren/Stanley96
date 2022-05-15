//
// defs.qc
//

float menu_loadingbar_width;
float menu_active;
//float menu_gamestate;
string menu_bg;
string loading_bg;

vector display_pos;
vector display_size;

float changed_settings;

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
