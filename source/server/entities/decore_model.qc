//
// decore_model.qc
//

class decore_model : CBaseEntity
{
	void() decore_model;

	virtual void(string, string) SpawnKey;
};

void decore_model :: decore_model ( void )
{
	// setup defaults
	scale = 1;
	frame = 0;
	skin = 0;

	super::CBaseEntity();

	movetype = MOVETYPE_NONE;
	solid = SOLID_NOT;

	if (model)
	{
		precache_model(model);
		setmodel(this, model);
		setorigin(this, origin);
	}
	else
		objerror("DECORE_MODEL: NO MODEL SET!");
};

void decore_model :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "model" : model = value; break;
		case "scale" : scale = stof(value); break;
		case "frame" : frame = stof(value); break;
		case "skin" : skin = stof(value); break;
		case "solid" : solid = stof(value); break;
		default: super :: SpawnKey(key, value); break;
	}
};
