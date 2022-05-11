//
// decore_fire.qc
//

class decore_fire : CBaseEntity
{
	float type;
	float length;
	float speed;

	void() decore_fire;

	virtual void() Think;
	virtual void(string, string) SpawnKey;
};

void decore_fire :: decore_fire ( void )
{
	super::CBaseEntity();

	if (type == 1)
	{
		precache_model("sprites/firebig.spr");
		setmodel(this, "sprites/firebig.spr");
		length = 13;
	}
	else
	{
		precache_model("sprites/firesmall.spr");
		setmodel(this, "sprites/firesmall.spr");
		length = 13;
	}

	//effects |= EF_ADDITIVE;
	solid = SOLID_NOT;
	if (!scale) scale = 1;
	if (!speed) speed = 0.1;

	think = Think;
	nextthink = time + speed;
};

void decore_fire :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "type" : type = stof(value); break;
		case "scale" : scale = stof(value); break;
		case "speed" : speed = stof(value); break;
		default: super :: SpawnKey(key, value); break;
	}
};

void decore_fire :: Think ( void )
{
	if (frame >= length)
		frame = 0;
	else
		frame += 1;

	if (!speed) speed = 0.1;
	nextthink = time + speed;
};