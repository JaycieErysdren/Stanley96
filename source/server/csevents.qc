void(string targ, string func) CSEv_FireTarget_ss =
{
	for (entity ent = world; (ent = find(ent, ::targetname, targ));)
	{
		CBaseEntity use = (CBaseEntity)ent;
		use.CallFunction(func);
	}
};