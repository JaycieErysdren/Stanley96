//
// func_accessibility.qc
//

class func_accessibility : CBaseBrushEntity
{
	float accessibility_type;
	string temp_model;
	
	void() func_accessibility;

	virtual void() Hide;
	virtual void() UnHide;
	virtual void() Think;
	virtual void(string, string) SpawnKey;
};

void func_accessibility :: func_accessibility ( void )
{
	movetype = MOVETYPE_PUSH;
	solid = SOLID_NOT;

	Initialize();

	temp_model = model;
};

void func_accessibility :: Hide ( void )
{
	setmodel(this, "");
};

void func_accessibility :: UnHide ( void )
{
	setmodel(this, temp_model);
};

void func_accessibility :: Think ( void )
{
	// continiously check if the cvar has changed

	if (accessibility_type == 0) // color blindness
	{
		if (cvar("accessibility_colorblind") == 1)
			UnHide();
		else
			Hide();
	}
	else
		objerror("FUNC_ACCESSIBILITY: INVALID TYPE SET!");

	nextthink = time + 0.1;
};

void func_accessibility :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "accessibility_type" : accessibility_type = stof(value); break;
		default: super :: SpawnKey(key, value); break;
	}
};
