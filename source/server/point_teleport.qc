//
// point_teleport.qc
//

class point_teleport : CBaseEntity
{
	string destination;

	void() point_teleport;
	
	virtual void() Trigger;
	virtual void(string, string) SpawnKey;
};

void point_teleport :: point_teleport ( void )
{
	// ??
};

void point_teleport :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "destination" : destination = value; break;
		default: super :: SpawnKey(key, value); break;
	}
};

void point_teleport :: Trigger ( void )
{
	if (nextthink > time)
		return;

	entity pl = find(world, ::classname, "player");
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

	nextthink = time + 5;
	touch = Null;
	think = Remove;
};