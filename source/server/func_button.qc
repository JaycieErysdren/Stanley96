//
// func_button.qc
//

enumflags
{
	FUNC_BUTTON_LOCKED
};

class func_button : CBaseBrushEntity
{
	void() func_button;

	virtual void() Use;
	virtual void(string) CallFunction;
	virtual void() DisableUse;
	virtual void() EnableUse;
};

void func_button :: func_button ( void )
{
	Initialize(MOVETYPE_PUSH, SOLID_BSP);

	if (!(spawnflags & FUNC_BUTTON_LOCKED))
		flags |= FL_USEABLE;

	touch = Null;
};

void func_button :: CallFunction ( string func )
{
	switch (func)
	{
		case "DisableUse" : DisableUse(); break;
		case "EnableUse" : EnableUse(); break;
		default: super :: CallFunction(func); break;
	}
};

void func_button :: Use ( void )
{
	if (nextthink > time)
		return;

	UseTargets();

	nextthink = time + 0.5;
};

void func_button :: DisableUse ( void )
{
	flags &= ~FL_USEABLE;
};

void func_button :: EnableUse ( void )
{
	flags |= FL_USEABLE;
};