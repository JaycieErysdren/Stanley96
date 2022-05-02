//
// NARRATOR LINE TABLE
//

string narrator_lines[] =
{
	"stanley/to_the_lounge.wav",
	"stanley/door_on_his_left.wav"
};

//
// NARRATOR CAPTION TABLES
//

struct caption_t {
	float length;
	string line1;
	string line2;
	string line3;
};

caption_t cc_narrator0[] =
{
	{ 4.8, "Stanley decided to go to the staff", "lounge, to check on his co-workers.", "" },
	{ 5.6, "He never functioned well by himself,", "and constantly needed support and", "guidance from others." },
	{ 3.3, "So the thought of total solitude was", "terrifying to him.", "" }
};

caption_t cc_narrator1[] =
{
	{ 4.9, "When Stanley came to a set of two open", "doors, he entered the door on his left.", "" }
};
