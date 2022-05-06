//
// point_narrator.qc
//

class point_narrator : CBaseEntity
{
	string narrator_line;

	void() point_narrator;
	
	virtual void() Use;
	virtual void(string, string) SpawnKey;
};

void point_narrator :: point_narrator ( void )
{
	if (narrator_line) precache_sound(narrator_line);
};

void point_narrator :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "narrator_line" : narrator_line = value; break;
		default: super :: SpawnKey(key, value); break;
	}
};

void point_narrator :: Use ( void )
{
	if (nextthink > time)
		return;

	UseTargets();

	if (!narrator_line || narrator_line == "")
		objerror("didn't set a narrator line!!");

	EasyMulticastString(EVENT_NARRATOR, narrator_line, other);

	nextthink = time + 0.1;
	think = Remove;
};