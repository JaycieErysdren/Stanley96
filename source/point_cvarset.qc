//
// point_cvarset.qc
//

class point_cvarset : CBaseEntity
{
	string cvar_name;
	string cvar_value;

	void() point_cvarset;
	
	virtual void() Use;
	virtual void(string, string) SpawnKey;
};

void point_cvarset :: point_cvarset ( void )
{
	// ??
};

void point_cvarset :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "cvar_name" : cvar_name = value; break;
		case "cvar_value" : cvar_value = value; break;
		default: super :: SpawnKey(key, value); break;
	}
};

void point_cvarset :: Use ( void )
{
	if (nextthink > time)
		return;

	if (!cvar_name || cvar_name == "" || !cvar_value || cvar_value == "")
		objerror("POINT_CVARSET: DIDN'T SET VALUES CORRECTLY!");
	else
		cvar_set(cvar_name, cvar_value);

	nextthink = time + 1; // prevent spam
};