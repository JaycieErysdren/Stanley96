//
// point_command.qc
//

class point_command : CBaseEntity
{
	string command_name;

	void() point_command;
	
	virtual void() Trigger;
	virtual void(string, string) SpawnKey;
};

void point_command :: point_command ( void )
{
	// ??
};

void point_command :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "command_name" : command_name = value; break;
		default: super :: SpawnKey(key, value); break;
	}
};

void point_command :: Trigger ( void )
{
	if (nextthink > time)
		return;

	if (!command_name || command_name == "")
		objerror("POINT_COMMAND: DIDN'T SET VALUES CORRECTLY!");
	else
		localcmd(command_name, "\n");

	nextthink = time + 1; // prevent spam
};