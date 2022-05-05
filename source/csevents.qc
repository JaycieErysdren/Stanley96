void(string targ) CSEv_FireTarget_s =
{
	CBaseEntity t = (CBaseEntity)find(world, ::targetname, targ);

	if (t)
		t.Use();
};