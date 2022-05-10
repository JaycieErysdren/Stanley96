//
// CBaseEntity.qc
//

class CBaseEntity
{
	string target1;
	string target1_func;
	float target1_delay;

	string target2;
	string target2_func;
	float target2_delay;

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
	virtual void() Trigger;
	virtual void(string) CallFunction;
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
		case "parentname" : parentname = value; break;
		case "targetname" : targetname = value; break;
		case "target1" : target1 = value; break;
		case "target1_delay": target1_delay = stof(value); break;
		case "target1_func": target1_func = value; break;
		case "target2" : target2 = value; break;
		case "target2_delay": target2_delay = stof(value); break;
		case "target2_func": target2_func = value; break;
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

	Trigger();
};

void CBaseEntity :: Trigger ( void ) { };

void CBaseEntity :: CallFunction ( string func )
{
	switch (func)
	{
		case "Use" : Use(); break;
		case "Remove" : Remove(); break;
		case "Trigger" : Trigger(); break;
		default: print("^1WARNING: ^3", classname, " ^dhas unrecognized CallFunction input ", func, "!\n"); break;
	}
};

void CBaseEntity :: Use ( void )
{
	Trigger();
};

void CBaseEntity :: UseTargets ( void )
{
	void() delay_think
	{
		UseTargets();
		Remove();
	}

	if (target1_delay)
	{
		CBaseEntity usetimer1 = spawn(CBaseEntity);

		usetimer1.classname = "_DelayedUse";
		usetimer1.nextthink = time + target1_delay;
		usetimer1.think = delay_think;
		usetimer1.target1 = target1;
		usetimer1.target1_delay = 0;
	}

	if (target2_delay)
	{
		CBaseEntity usetimer2 = spawn(CBaseEntity);

		usetimer2.classname = "_DelayedUse";
		usetimer2.nextthink = time + target2_delay;
		usetimer2.think = delay_think;
		usetimer2.target2 = target2;
		usetimer2.target2_delay = 0;
	}

	if (target1 && !target1_delay)
	{
		for (entity ent = world; (ent = find(ent, ::targetname, target1));)
		{
			CBaseEntity targ1 = (CBaseEntity)ent;
			targ1.activator = this;

			if (target1_func)
				targ1.CallFunction(target1_func);
			else
				targ1.CallFunction("Trigger");
		}
	}

	if (target2 && !target2_delay)
	{
		for (entity ent = world; (ent = find(ent, ::targetname, target2));)
		{
			CBaseEntity targ2 = (CBaseEntity)ent;
			targ2.activator = this;

			if (target2_func)
				targ2.CallFunction(target2_func);
			else
				targ2.CallFunction("Trigger");
		}
	}
};
