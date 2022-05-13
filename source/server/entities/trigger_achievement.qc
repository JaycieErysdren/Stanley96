//
// trigger_achievement.qc
//

class trigger_achievement : CBaseTrigger
{
	string achievement;

	void() trigger_achievement;
	
	virtual void() Trigger;
	virtual void(string, string) SpawnKey;
};

void trigger_achievement :: trigger_achievement ( void )
{
	// ??
};

void trigger_achievement :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "achievement" : achievement = value; break;
		default: super :: SpawnKey(key, value); break;
	}
};

void trigger_achievement :: Trigger ( void )
{
	if (nextthink > time)
		return;

	UseTargets();

	if (!achievement || achievement == "")
		objerror("didn't set an achievement id!!");

	EasyMulticastString(EVENT_ACHIEVEMENT, achievement, other);

	nextthink = time + 0.1;
	touch = Null;
	think = Remove;
};