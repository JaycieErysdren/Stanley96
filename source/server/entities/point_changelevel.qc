//
// point_changelevel.qc
//

class point_changelevel : CBaseEntity
{
	string nextmap;

	void() point_changelevel;
	
	virtual void() ChangeLevel;
	virtual void() Trigger;
	virtual void(string, string) SpawnKey;
};

void point_changelevel :: point_changelevel ( void )
{
	// ??
};

void point_changelevel :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "nextmap" : nextmap = value; break;
		default: super :: SpawnKey(key, value); break;
	}
};

void point_changelevel :: Trigger ( void )
{
	if (nextthink > time)
		return;

	UseTargets();

	nextthink = time + 0.1;
	touch = Null;
	think = ChangeLevel;
};

void point_changelevel :: ChangeLevel ( void )
{
	changelevel(nextmap);

	nextthink = time + 0.1;
	think = Remove;
};