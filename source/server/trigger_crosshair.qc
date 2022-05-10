//
// trigger_crosshair.qc
//

class trigger_crosshair : CBaseTrigger
{
	float mode;

	void() trigger_crosshair;

	virtual void() Use;
	virtual void(string, string) SpawnKey;
};

void trigger_crosshair :: trigger_crosshair ( void )
{
	// ??
};

void trigger_crosshair :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "mode" : mode = stof(value); break;
		default: super :: SpawnKey(key, value); break;
	}
};

void trigger_crosshair :: Use ( void )
{
	if (mode == 1 && cvar("crosshair") == 0)
		cvar_set("crosshair", "1");
	else if (mode == 0 && cvar("crosshair") == 1)
		cvar_set("crosshair", "0");
	else if (mode != 0 && mode != 1)
		objerror("TRIGGER_CROSSHAIR: MODE NOT SET TO POSSIBLE VALUE!");
};