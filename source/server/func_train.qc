//
// func_train.qc
//

enum
{
	FUNC_TRAIN_STATE_OFF,
	FUNC_TRAIN_STATE_FORWARD,
	FUNC_TRAIN_STATE_BACKWARD,
	FUNC_TRAIN_STATE_FINISHED
};

class func_train : CBaseBrushEntity
{
	// entity variables
	float var_speed;
	float var_wait;
	
	string path_node;

	string sound_start;
	string sound_stop;

	vector final_dest;

	// entity functions
	void() func_train;
	virtual void(vector tdest, float tspeed, void() nextfunc) CalcMove;
	virtual void() Done;
	virtual void() FindStartPath;
	virtual void() MoveToNextPath;
	virtual void() MoveForward;
	virtual void() MoveBackward;
	virtual void(string key, string value) SpawnKey;
	virtual void() Trigger;
	virtual void() Wait;
	virtual void() NextFunc;
	virtual void(string) CallFunction;
};

void func_train :: func_train ( void )
{
	Initialize(MOVETYPE_PUSH, SOLID_BSP);

	if (sound_start && sound_start != "") precache_sound(sound_start);
	if (sound_stop && sound_stop != "") precache_sound(sound_stop);
	if (!var_speed) var_speed = 50;
	if (!var_wait) var_wait = 1;

	touch = Null;
	blocked = Null;

	state = FUNC_TRAIN_STATE_OFF;

	think = FindStartPath;
	nextthink = ltime + 0.5;
};

void func_train :: NextFunc ( void ) { };

void func_train :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "path_node" : path_node = value; break;
		case "sound_start" : sound_start = value; break;
		case "sound_stop" : sound_stop = value; break;
		case "speed" : var_speed = stof(value); break;
		case "wait" : var_wait = stof(value); break;
		default: super :: SpawnKey(key, value); break;
	}
};

void func_train :: CallFunction ( string func )
{
	switch (func)
	{
		case "MoveForward" : MoveForward(); break;
		case "MoveBackward" : MoveBackward(); break;
		default: super :: CallFunction(func); break;
	}
};

void func_train :: CalcMove ( vector tdest, float tspeed, void() nextfunc )
{
	vector vdestdelta;
	float len, traveltime;

	if (!tspeed || tspeed == 0)
		objerror("FUNC_TRAIN: No move speed is defined!");

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

void func_train :: FindStartPath ( void )
{
	CBaseEntity node = (CBaseEntity)find(world, ::targetname, path_node);

	setorigin(this, node.origin - (mins + maxs) * 0.5);

	// if it doesn't have a targetname set,
	// assume the level designer wants it to run automatically.
	if (!targetname)
	{
		state = FUNC_TRAIN_STATE_FORWARD;

		if (sound_start && sound_start != "")
			sound(this, CHAN_VOICE, sound_start, 1, ATTN_NORM);

		nextthink = ltime + 0.1;
		think = MoveForward;
	}
};

void func_train :: MoveToNextPath ( void )
{
	CBaseEntity node = (CBaseEntity)find(world, ::targetname, path_node);

	if ((node.target1 && node.target1 != "") || (node.target2 && node.target2 != ""))
	{
		if (state == FUNC_TRAIN_STATE_FORWARD)
			path_node = node.target1;
		else if (state == FUNC_TRAIN_STATE_BACKWARD)
			path_node = node.target2;

		CBaseEntity nextnode = (CBaseEntity)find(world, ::targetname, path_node);

		CalcMove(nextnode.origin - (mins + maxs) * 0.5, var_speed, Wait);
	}
	else
		Done();
};

void func_train :: MoveForward ( void )
{
	state = FUNC_TRAIN_STATE_FORWARD;

	Trigger();
};

void func_train :: MoveBackward ( void )
{
	state = FUNC_TRAIN_STATE_BACKWARD;

	Trigger();
};

void func_train :: Wait ( void )
{
	if (var_wait >= 0) var_wait = 0.1;

	nextthink = ltime + var_wait;
	think = MoveToNextPath;
};

void func_train :: Done ( void )
{	
	state = FUNC_TRAIN_STATE_FINISHED;

	if (sound_stop && sound_stop != "")
		sound(this, CHAN_VOICE, sound_stop, 1, ATTN_NORM);
};

void func_train :: Trigger ( void )
{
	if (state == FUNC_TRAIN_STATE_FINISHED)
		return;

	if (sound_start && sound_start != "" && state == FUNC_TRAIN_STATE_OFF)
		sound(this, CHAN_VOICE, sound_start, 1, ATTN_NORM);
	
	nextthink = ltime + 0.1;
	think = MoveToNextPath;
};