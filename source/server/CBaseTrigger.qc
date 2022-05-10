//
// CBaseTrigger.qc
//

class CBaseTrigger : CBaseBrushEntity
{
	float reset_time;

	void() CBaseTrigger;
	
	virtual void() Trigger;
	virtual void(string, string) SpawnKey;
};

void CBaseTrigger :: CBaseTrigger ( void )
{
	solid = SOLID_TRIGGER;

	Initialize();

	modelindex = 0;
	model = "";

	if (!reset_time) reset_time = 1;
	//if (target1_sound) precache_sound(target1_sound);
};

void CBaseTrigger :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "reset_time" : reset_time = stof(value); break;
		default: super :: SpawnKey(key, value); break;
	}
};

void CBaseTrigger :: Trigger ( void )
{
	if (nextthink > time)
		return;

	UseTargets();

	if (reset_time > 0)	
	{
		think = Null;
		nextthink = time + reset_time;
	}
	else
	{
		nextthink = time + 0.1;
		touch = Null;
		think = Remove;
	}
};