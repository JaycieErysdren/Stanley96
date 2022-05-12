//
// func_door.qc
//

enum
{
	FUNC_DOOR_STATE_OPEN,
	FUNC_DOOR_STATE_CLOSED,
	FUNC_DOOR_STATE_OPENING,
	FUNC_DOOR_STATE_CLOSING
};

enumflags
{
	FUNC_DOOR_FLAG_TOUCHABLE,
	FUNC_DOOR_FLAG_USEABLE,
	FUNC_DOOR_FLAG_CHANGEFRAMES,
	FUNC_DOOR_FLAG_NOT_SOLID,
	FUNC_DOOR_FLAG_STARTOPEN
};

class func_door : CBaseBrushEntity
{
	float distance;
	float lip;
	float speed;
	float reset_delay;
	string sound_start;
	string sound_stop;
	vector final_dest;
	vector pos_open;
	vector pos_closed;
	vector new_angles;

	void() func_door;
	virtual void(vector tdest, float tspeed, void() nextfunc) CalcMove;
	virtual void() CalcMoveDir;
	virtual void() CalcMovePos;
	virtual void() Done;
	virtual void() Return;
	virtual void(string) CallFunction;
	virtual void(string key, string value) SpawnKey;
	virtual void() Trigger;
	virtual void() Wait;
	virtual void() NextFunc;
};

void func_door :: func_door ( void )
{
	super::CBaseEntity();

	if (spawnflags & FUNC_DOOR_FLAG_NOT_SOLID)
		Initialize(MOVETYPE_PUSH, SOLID_NOT);
	else
		Initialize(MOVETYPE_PUSH, SOLID_BSP);

	if (spawnflags & FUNC_DOOR_FLAG_USEABLE) flags |= FL_USEABLE;
	if (sound_start) precache_sound(sound_start);
	if (sound_stop) precache_sound(sound_stop);

	if (spawnflags & FUNC_DOOR_FLAG_TOUCHABLE)
		touch = Touch;
	else
		touch = Null;

	blocked = Null;

	CalcMoveDir();

	if (!speed) speed = 50;
	if (!reset_delay) reset_delay = 1;
	if (!lip) lip = 8;
	if (!distance) distance = zeroconvertdefault(distance, BoundsAngleSize( movedir, size ) - lip);

	CalcMovePos();

	if (spawnflags & FUNC_DOOR_FLAG_STARTOPEN)
	{
		state = FUNC_DOOR_STATE_OPEN;
		setorigin(this, pos_open);
	}
	else
	{
		state = FUNC_DOOR_STATE_CLOSED;
	}
};

void func_door :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "sound_start" : sound_start = value; break;
		case "sound_stop" : sound_stop = value; break;
		case "reset_delay" : reset_delay = stof(value); break;
		case "speed" : speed = stof(value); break;
		case "lip" : lip = stof(value); break;
		case "angles" : new_angles = stov(value); break;
		default: super :: SpawnKey(key, value); break;
	}
};

void func_door :: CalcMoveDir ( void )
{
	makevectors(new_angles);
	movedir = v_forward;
	angles = [0, 0, 0];
};

void func_door :: CalcMovePos ( void )
{
	pos_open = origin + movedir * distance;
	pos_closed = origin;
};

void func_door :: NextFunc ( void ) { };

void func_door :: CallFunction ( string func )
{
	switch (func)
	{
		case "Open" : if (state == FUNC_DOOR_STATE_CLOSED) Trigger(); break;
		case "Close" : if (state == FUNC_DOOR_STATE_OPEN) Trigger(); break;
		default: super :: CallFunction(func); break;
	}
};

void func_door :: CalcMove ( vector tdest, float tspeed, void() nextfunc )
{
	vector vdestdelta;
	float len, traveltime;

	if (!tspeed || tspeed == 0)
		objerror("No move speed is defined!");

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

void func_door :: Wait ( void )
{
	if (state == FUNC_DOOR_STATE_OPENING)
		state = FUNC_DOOR_STATE_OPEN;
	else if (state == FUNC_DOOR_STATE_CLOSING)
		state = FUNC_DOOR_STATE_CLOSED;

	UseTargets();
	
	if (spawnflags & FUNC_DOOR_FLAG_CHANGEFRAMES)
		frame = 1;

	if (reset_delay < 0)
	{
		nextthink = ltime + 0.1;
		think = Null;
	}
	else
	{
		if (reset_delay == 0) reset_delay = 0.1;
		nextthink = ltime + reset_delay;
		think = Return;
	}
};

void func_door :: Return ( void )
{
	if (spawnflags & FUNC_DOOR_FLAG_CHANGEFRAMES)
		frame = 0;

	if (state == FUNC_DOOR_STATE_OPEN)
	{
		state = FUNC_DOOR_STATE_CLOSING;
		CalcMove(pos_closed, speed, Done);
	}
	else if (state == FUNC_DOOR_STATE_CLOSED)
	{
		state = FUNC_DOOR_STATE_OPENING;
		CalcMove(pos_open, speed, Done);
	}
};

void func_door :: Done ( void )
{
	if (sound_stop && sound_stop != "")
		sound(this, CHAN_VOICE, sound_stop, 1, ATTN_NORM);

	if (spawnflags & FUNC_DOOR_FLAG_CHANGEFRAMES)
		frame = 0;
};

void func_door :: Trigger ( void )
{
	if (state == FUNC_DOOR_STATE_OPENING || state == FUNC_DOOR_STATE_CLOSING)
		return;

	if (sound_start && sound_start != "")
		sound(this, CHAN_VOICE, sound_start, 1, ATTN_NORM);

	if (state == FUNC_DOOR_STATE_OPEN)
	{
		state = FUNC_DOOR_STATE_CLOSING;
		CalcMove(pos_closed, speed, Wait);
	}
	else if (state == FUNC_DOOR_STATE_CLOSED)
	{
		state = FUNC_DOOR_STATE_OPENING;
		CalcMove(pos_open, speed, Wait);
	}
};
