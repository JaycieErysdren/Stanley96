//
// CBaseEntity.qc
//

class CBaseEntity
{
	string target_remove;
	string target_sound;
	float target_delay;
	float target_reset;
	
	string parentname;

	float alpha;

	void() CBaseEntity;

	// for spawnkeys
	virtual void() InitKeys;
	virtual void(string, string) SpawnKey;

	// normal stuff
	virtual void() Null;
	virtual void() Remove;
	virtual void() Think;
	virtual void() Touch;
	virtual void() Use;
	virtual void() UseTargets;
};

void CBaseEntity :: CBaseEntity ( void )
{
	identity = 1; // hack

	InitKeys();

	if (!use)
		use = Use;

	if (!touch)
		touch = Touch;

	if (!alpha)
		alpha = 1;

	if (!think)
		think = Think;

	if (!nextthink)
		nextthink = time + 0.1;

	if (!target_reset) target_reset = 1;
	if (target_sound) precache_sound(target_sound);

	switch(effects)
	{
		case 1 : effects = EF_BRIGHTFIELD; break;
		case 2 : effects = EF_BRIGHTLIGHT; break;
		case 3 : effects = EF_DIMLIGHT; break;
		case 4 : effects = EF_NODRAW; break;
		case 5 : effects = EF_ADDITIVE; break;
		case 6 : effects = EF_BLUE; break;
		case 7 : effects = EF_RED; break;
		case 8 : effects = EF_GREEN; break;
		case 9 : effects = EF_FULLBRIGHT; break;
		case 10 : effects = EF_NOSHADOW; break;
		case 11 : effects = EF_NODEPTHTEST; break;
		default : break;
	}
};

void CBaseEntity :: InitKeys ( void )
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2)
		SpawnKey(argv(i), argv(i+1));
	
	__fullspawndata = "";
};

void CBaseEntity :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		// ignore all the engine defaults
		case "classname": break;
		case "origin": break;
		case "spawnflags": break;
		case "killtarget": break;
		case "message": break;
		case "model": break;
		case "effects": break;
		case "skin": break;
		case "_tb_layer": break;
		// actual vars we need to look at
		case "alpha" : alpha = stof(value); break;
		case "parentname" : if (value != "") parentname = value; break;
		case "target" : target = value; break;
		case "targetname" : targetname = value; break;
		case "target_delay": target_delay = stof(value); break;
		case "target_remove": target_remove = value; break;
		case "target_reset" : target_reset = stof(value); break;
		case "target_sound": target_sound = value; break;
		default: print(sprintf("^3%s^7::SpawnKey:: Unknown key '%s' with value '%s'\n", classname, key, value)); break;
	}
};

void CBaseEntity :: FrameUpdate ( void )
{
	if (parentname)
	{
		entity p = find(world, ::targetname, parentname);

		if (p)
			setorigin(this, p.origin);
	}
};

void CBaseEntity :: Null ( void ) { };

void CBaseEntity :: Remove ( void ) { remove(this); };

void CBaseEntity :: Think ( void ) { };

void CBaseEntity :: Touch ( void )
{
	if (other.classname != "player")
		return;

	activator = other;

	Use();
};

void CBaseEntity :: Use ( void ) { };

void CBaseEntity :: UseTargets ( void )
{
	void() delay_think
	{
		UseTargets();
		Remove();
	}

	if (target_delay)
	{
		CBaseEntity usetimer = spawn(CBaseEntity);

		usetimer.classname = "_DelayedUse";
		usetimer.nextthink = time + target_delay;
		usetimer.think = delay_think;
		usetimer.message = message;
		usetimer.target_remove = target_remove;
		usetimer.target = target;
		usetimer.target_delay = 0;

		return;
	}

	if (activator.classname == "player" && message != "")
	{
		centerprint(activator, message);

		if (target_sound)
			sound(activator, CHAN_VOICE, target_sound, 1, ATTN_NORM);
	}

	if (target_remove)
	{
		for (entity ent = world; (ent = find(ent, ::targetname, target_remove));)
		{
			CBaseEntity tempkill = (CBaseEntity)ent;
			tempkill.activator = this;
			tempkill.Remove();
		}
	}

	if (target)
	{
		for (entity ent = world; (ent = find(ent, ::targetname, target));)
		{
			CBaseEntity tempuse = (CBaseEntity)ent;
			tempuse.activator = this;
			tempuse.Use();
		}
	}
};
