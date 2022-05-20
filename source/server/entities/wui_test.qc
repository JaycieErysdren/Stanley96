//
// wui_test.qc
//

class wui_test : CBaseEntity
{
	void() wui_test;
	
	virtual void() Trigger;
};

void wui_test :: wui_test ( void )
{
	print("^1WUI_TEST WITH TARGETNAME ", targetname, " SPAWNED IN SSQC!\n");
};

void wui_test :: Trigger ( void )
{
	CBaseEntity p = (CBaseEntity)find(world, ::classname, "player");

	if (p)
		EasyMulticastVector(EVENT_WUI, origin, p);

	print("^1Hello!\n");
};