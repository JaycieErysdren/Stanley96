//
// decore_model.qc
//

class decore_model : CBaseEntity
{
	void() decore_model;
	string mdl;

	virtual void(string, string) SpawnKey;
};

void decore_model :: decore_model ( void )
{
	super::CBaseEntity();

	solid = SOLID_NOT;
	if (!scale) scale = 1;

	precache_model(mdl);
	setmodel(this, mdl);
	setorigin(this, origin);
};

void decore_model :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "mdl" : mdl = value; break;
		case "scale" : scale = stof(value); break;
		default: super :: SpawnKey(key, value); break;
	}
};
