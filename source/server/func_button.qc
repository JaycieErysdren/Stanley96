//
// func_button.qc
//

class func_button : CBaseBrushEntity
{
	void() func_button;
	virtual void() Use;
};

void func_button :: func_button ( void )
{
	Initialize(MOVETYPE_PUSH, SOLID_BSP);

	flags |= FL_USEABLE;

	touch = Null;
};

void func_button :: Use ( void )
{
	if (nextthink > time)
		return;

	UseTargets();

	nextthink = time + 0.5;
};
