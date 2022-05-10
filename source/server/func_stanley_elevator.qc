//
// func_stanley_elevator.qc
//

enum
{
	FUNC_STANLEY_ELEVATOR_STATE_OFF,
	FUNC_STANLEY_ELEVATOR_STATE_ON,
	FUNC_STANLEY_ELEVATOR_STATE_FINISHED,
};

class func_stanley_elevator : CBaseBrushEntity
{
	// entity variables
	float var_speed;
	float var_wait;

	string sound_start;
	string sound_stop;

	vector final_dest;

	// stanley96
	string button_up;
	string button_down;
	string track_up;
	string track_down;

	// entity functions
	void() func_stanley_elevator;
	virtual void(vector tdest, float tspeed, void() nextfunc) CalcMove;
	virtual void() Done;
	virtual void() FindStartPath;
	virtual void() MoveToNextPath;
	virtual void(string key, string value) SpawnKey;
	virtual void() Use;
	virtual void() Wait;
	virtual void() NextFunc;
};

void func_stanley_elevator :: func_stanley_elevator ( void )
{
	// this is essentially my standard movetrack brush code, 
	// but with some modifications to make it work specifically
	// for stanley96's elevator (cuz i'm too lazy to make it in map logic)
	// - jaycie 2022-05-09

	solid = SOLID_BSP;
	movetype = MOVETYPE_PUSH;
	Initialize();

	if (sound_start && sound_start != "") precache_sound(sound_start);
	if (sound_stop && sound_stop != "") precache_sound(sound_stop);
	if (!var_speed) var_speed = 50;
	if (!var_wait) var_wait = 1;

	touch = Null;
	blocked = Null;

	state = FUNC_STANLEY_ELEVATOR_STATE_OFF;

	think = FindStartPath;
	nextthink = ltime + 0.5;
};

void func_stanley_elevator :: NextFunc ( void ) { };

void func_stanley_elevator :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "button_up" : button_up = value; break;
		case "button_down" : button_down = value; break;
		case "track_up" : track_up = value; break;
		case "track_down" : track_down = value; break;
		case "sound_start" : sound_start = value; break;
		case "sound_stop" : sound_stop = value; break;
		case "speed" : var_speed = stof(value); break;
		case "wait" : var_wait = stof(value); break;
		default: super :: SpawnKey(key, value); break;
	}
};

void func_stanley_elevator :: CalcMove ( vector tdest, float tspeed, void() nextfunc )
{
	vector vdestdelta;
	float len, traveltime;

	if (!tspeed || tspeed == 0)
		objerror("FUNC_STANLEY_ELEVATOR: No move speed is defined!");

	void() CalcMoveDone =
	{
		setorigin(this, final_dest);
		velocity = [0, 0, 0];
		think = NextFunc;
		nextthink = ltime + 0.1;
	};

	NextFunc = nextfunc;

	think = CalcMoveDone;

	final_dest = tdest;

	if (tdest == origin)
	{
		velocity = [0, 0, 0];
		nextthink = ltime + 0.1;
		return;
	}
	
	vdestdelta = tdest - origin; // set destdelta to the vector needed to move
	len = vlen(vdestdelta); // calculate length of vector
	traveltime = len / tspeed; // divide by speed to get time to reach dest

	if (traveltime < 0.1)
	{
		velocity = [0, 0, 0];
		nextthink = ltime + 0.1;
		return;
	}

	nextthink = ltime + traveltime; // set nextthink to trigger a think when dest is reached
	velocity = vdestdelta * (1/traveltime); // scale the destdelta vector by the time spent traveling to get velocity
};

void func_stanley_elevator :: FindStartPath ( void )
{
	CBaseEntity node = (CBaseEntity)find(world, ::targetname, target);

	setorigin(this, node.origin - (mins + maxs) * 0.5);

	// if it doesn't have a targetname set,
	// assume the level designer wants it to run automatically.
	if (!targetname)
	{
		state = FUNC_STANLEY_ELEVATOR_STATE_ON;

		if (sound_start && sound_start != "")
			sound(this, CHAN_VOICE, sound_start, 1, ATTN_NORM);

		nextthink = ltime + 0.1;
		think = MoveToNextPath;
	}
};

void func_stanley_elevator :: MoveToNextPath ( void )
{
	print("hello!!\n");
	/*
	CBaseEntity node = (CBaseEntity)find(world, ::targetname, target);

	if (!node.target || node.target == "")
	{
		Done();
		return;
	}

	target = node.target;
	*/

	CBaseEntity nextnode = (CBaseEntity)find(world, ::targetname, target);

	CalcMove(nextnode.origin - (mins + maxs) * 0.5, var_speed, Wait);
};

void func_stanley_elevator :: Wait ( void )
{
	if (var_wait >= 0) var_wait = 0.1;

	nextthink = ltime + var_wait;
	think = MoveToNextPath;
};

void func_stanley_elevator :: Done ( void )
{	
	state = FUNC_STANLEY_ELEVATOR_STATE_FINISHED;

	if (sound_stop && sound_stop != "")
		sound(this, CHAN_VOICE, sound_stop, 1, ATTN_NORM);
};

void func_stanley_elevator :: Use ( void )
{
	print("i have been used by an ", activator.targetname, "\n");
	print(button_up, "\n");
	print(button_down, "\n");
	print(track_up, "\n");
	print(track_down, "\n");

	if (state == FUNC_STANLEY_ELEVATOR_STATE_FINISHED)
		return;

	if (sound_start && sound_start != "" && state == FUNC_STANLEY_ELEVATOR_STATE_OFF)
		sound(this, CHAN_VOICE, sound_start, 1, ATTN_NORM);

	state = FUNC_STANLEY_ELEVATOR_STATE_ON;
	
	if (activator.targetname == button_up)
	{
		print("haha up!\n");
		target = track_up;
	}
	else if (activator.targetname == button_down)
	{
		print("haha down!\n");
		target = track_down;
	}

	nextthink = ltime + 0.1;
	think = MoveToNextPath;
};