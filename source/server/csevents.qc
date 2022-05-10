void(string targ) CSEv_FireTarget_s =
{
	for (entity ent = world; (ent = find(ent, ::targetname, targ));)
	{
		CBaseEntity use = (CBaseEntity)ent;
		//use.Use();
		use.CallFunction("Trigger");
	}
};