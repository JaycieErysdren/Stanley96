//
// point_relay.qc
//

class point_relay : CBaseEntity
{
	float relay_delay;

	void() point_relay;
	
	virtual void() Execute;
	virtual void() Use;
	virtual void(string, string) SpawnKey;
};

void point_relay :: point_relay ( void )
{
	// ??
};

void point_relay :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "relay_delay" : relay_delay = stof(value); break;
		default: super :: SpawnKey(key, value); break;
	}
};

void point_relay :: Use ( void )
{
	if (nextthink > time)
		return;

	if (relay_delay < 0)
		relay_delay = 0;

	nextthink = time + relay_delay;
	think = Execute;
};

void point_relay :: Execute ( void )
{
	UseTargets();

	nextthink = time + 0.1;
	think = Remove;
};