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
	super::CBaseEntity();

	solid = SOLID_NOT;
	if (!scale) scale = 1;

	precache_model(model);
	setmodel(this, model);
	setorigin(this, origin);
};

void decore_model :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "model" : model = value; break;
		case "scale" : scale = stof(value); break;
		default: super :: SpawnKey(key, value); break;
	}
};
