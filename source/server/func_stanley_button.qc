//
// func_stanley_button.qc
//

class func_stanley_button : CBaseBrushEntity
{
	void() func_stanley_button;
	virtual void() Use;
};

void func_stanley_button :: func_stanley_button ( void )
{
	solid = SOLID_BSP;
	movetype = MOVETYPE_PUSH;

	Initialize();

	flags |= FL_USEABLE;

	touch = Null;
};

void func_stanley_button :: Use ( void )
{
	if (nextthink > time)
		return;

	UseTargets();

	nextthink = time + 0.5;
};
