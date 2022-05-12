//
// light.qc
//

class light : CBaseEntity
{
	void() light;

	virtual void(string, string) SpawnKey;
};

void light :: light ( void )
{
	makestatic(this);
};

void light :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "light" : break;
		case "_color" : break;
		case "angle" : break;
		case "delay" : break;
		default: super :: SpawnKey(key, value); break;
	}
};