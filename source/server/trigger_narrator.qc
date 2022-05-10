//
// trigger_narrator.qc
//

class trigger_narrator : CBaseTrigger
{
	string narrator_line;

	void() trigger_narrator;
	
	virtual void() Trigger;
	virtual void(string, string) SpawnKey;
};

void trigger_narrator :: trigger_narrator ( void )
{
	if (narrator_line) precache_sound(narrator_line);
};

void trigger_narrator :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "narrator_line" : narrator_line = value; break;
		default: super :: SpawnKey(key, value); break;
	}
};

void trigger_narrator :: Trigger ( void )
{
	if (nextthink > time)
		return;

	UseTargets();

	if (!narrator_line || narrator_line == "")
		objerror("didn't set a narrator line!!");

	EasyMulticastString(EVENT_NARRATOR, narrator_line, other);

	nextthink = time + 0.1;
	touch = Null;
	think = Remove;
};