//
// ASPECT RATIO VALUES
//

float ar_normal = 4 / 3;
float ar_laptop1 = 1366 / 768;
float ar_widescreen = 16 / 9;

//
// PLAYER STATS
//

enum
{
	STAT_NARRATOR_LINE1 = 33,
	STAT_NARRATOR_LINE2 = 34,
	STAT_NARRATOR_LINE3 = 35
};

//
// MULTICAST EVENTS
//

enum
{
	EVENT_NARRATOR
};

//
// NARRATOR LINES?
//

enum
{
	NARRATOR_LINE000,
	NARRATOR_LINE001
};

//
// GLOBAL ENTITY FIELDS
//

.string narrator_line1;
.string narrator_line2;
.string narrator_line3;
.string narrator;