//
// trigger_teleport.qc
//

class trigger_teleport : CBaseTrigger
{
	string destination;

	void() trigger_teleport;
	
	virtual void() Use;
	virtual void(string, string) SpawnKey;
};

void trigger_teleport :: trigger_teleport ( void )
{
	// ??
};

void trigger_teleport :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "destination" : destination = value; break;
		default: super :: SpawnKey(key, value); break;
	}
};

void trigger_teleport :: Use ( void )
{
	if (nextthink > time)
		return;
	
	activator = enemy;

	entity pl = activator;
	CBaseEntity dest = (CBaseEntity)find(world, ::targetname, destination);
	
	if (!pl)
		objerror("CAN'T FIND PLAYER!");
	
	if (!dest)
		objerror("CAN'T FIND DESTINATION ENTITY!");
	
	if (dest.classname != "info_teleport_destination")
		objerror("TELEPORT DESTINATION IS NOT THE RIGHT CLASS!");
	
	UseTargets();
	pl.angles = dest.angles;
	pl.fixangle = TRUE;
	pl.origin = dest.origin;
	pl.velocity = [0, 0, 0];

	nextthink = time + 0.1;
	touch = Null;
	think = Remove;
};