//
// trigger_changelevel.qc
//

class trigger_changelevel : CBaseTrigger
{
	string nextmap;

	void() trigger_changelevel;
	
	virtual void() ChangeLevel;
	virtual void() Trigger;
	virtual void(string, string) SpawnKey;
};

void trigger_changelevel :: trigger_changelevel ( void )
{
	// ??
};

void trigger_changelevel :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "nextmap" : nextmap = value; break;
		default: super :: SpawnKey(key, value); break;
	}
};

void trigger_changelevel :: Trigger ( void )
{
	if (nextthink > time)
		return;

	// probably no reason to do this because we're switching levels right now
	//UseTargets();

	nextthink = time + 0.1;
	touch = Null;
	think = ChangeLevel;
};

void trigger_changelevel :: ChangeLevel ( void )
{
	changelevel(nextmap);

	nextthink = time + 0.1;
	think = Remove;
};