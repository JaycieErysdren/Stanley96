//
// func_rotate.qc
//

enum
{
	FUNC_ROTATE_STATE_OPEN,
	FUNC_ROTATE_STATE_CLOSED,
	FUNC_ROTATE_STATE_OPENING,
	FUNC_ROTATE_STATE_CLOSING
};

enumflags
{
	FUNC_ROTATE_FLAG_TOUCHABLE,
	FUNC_ROTATE_FLAG_USEABLE,
	FUNC_ROTATE_FLAG_CHANGEFRAMES,
	FUNC_ROTATE_FLAG_NOT_SOLID,
	FUNC_ROTATE_FLAG_STARTOPEN,
	FUNC_ROTATE_FLAG_CONTINIOUS
};

class func_rotate : CBaseBrushEntity
{
	float var_speed;
	float var_wait;
	float var_health;
	string sound_start;
	string sound_stop;
	vector new_angles;

	void() func_rotate;
	virtual void(vector tdest, float tspeed, void() nextfunc) CalcRotate;
	virtual void() Done;
	virtual void() Return;
	virtual void(string key, string value) SpawnKey;
	virtual void() Use;
	virtual void() Wait;
};

void func_rotate :: func_rotate ( void )
{
	if (!(spawnflags & FUNC_ROTATE_FLAG_STARTOPEN))
	{
		state = FUNC_ROTATE_STATE_CLOSED;
		angles = [0, 0, 0];
	}
	else
		state = FUNC_ROTATE_STATE_OPEN;

	if (spawnflags & FUNC_ROTATE_FLAG_NOT_SOLID)
		solid = SOLID_NOT;
	else
		solid = SOLID_BSP;

	movetype = MOVETYPE_PUSH;

	Initialize();

	if (spawnflags & FUNC_ROTATE_FLAG_USEABLE)
		flags |= FL_USEABLE;

	if (sound_start)
		precache_sound(sound_start);

	if (sound_stop)
		precache_sound(sound_stop);

	if (spawnflags & FUNC_ROTATE_FLAG_TOUCHABLE)
		touch = Touch;
	else
		touch = Null;

	if (!var_speed) var_speed = 50;
	if (!var_wait) var_wait = 1;
	if (!var_health) var_health = 10;

	blocked = Null;

	if (origin == [0, 0, 0])
		objerror("No origin brush detected!");

	void() rotate_forever { Use(); };

	if (spawnflags & FUNC_ROTATE_FLAG_CONTINIOUS)
	{
		nextthink = ltime + 0.1;
		think = rotate_forever;
	}
};

void func_rotate :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "sound_start" : sound_start = value; break;
		case "sound_stop" : sound_stop = value; break;
		case "health" : var_health = stof(value); break;
		case "speed" : var_speed = stof(value); break;
		case "wait" : var_wait = stof(value); break;
		case "angles" : new_angles = stov(value); break;
		default: super :: SpawnKey(key, value); break;
	}
};

void func_rotate :: CalcRotate ( vector tdest, float tspeed, void() nextfunc )
{
	if (spawnflags & FUNC_ROTATE_FLAG_CONTINIOUS)
	{
		if (tdest_x > 0) tdest_x = 360; else if (tdest_x < 0) tdest_x = -360; else tdest_x = 0; 
		if (tdest_y > 0) tdest_y = 360; else if (tdest_y < 0) tdest_y = -360; else tdest_y = 0; 
		if (tdest_z > 0) tdest_z = 360; else if (tdest_z < 0) tdest_z = -360; else tdest_z = 0;
	}

	if (!tspeed) {
		dprint(sprintf("^1func_door_rotating::^3RotToDest^7: No speed defined for %s!", targetname));
		return;
	}

	vector vdiff = (tdest - angles);
	float len = vlen(vdiff);
	float traveltime = (len / tspeed);

	if (spawnflags & FUNC_ROTATE_FLAG_CONTINIOUS)
	{
		if (traveltime > 0.0f)
		{
			avelocity = (vdiff * (1 / traveltime));
			nextthink = (ltime + 999999999999); // ????
		}

		return;
	}

	if (tdest == angles)
	{
		avelocity = [0, 0, 0];
		nextfunc();
		return;
	}

	if (traveltime <= 0.0f)
	{
		avelocity = [0, 0, 0];
		nextfunc();
		nextthink = 0.0f;
	}
	else
	{
		avelocity = (vdiff * (1 / traveltime));
		think = nextfunc;
		nextthink = (ltime + traveltime);
	}
};

void func_rotate :: Wait ( void )
{
	if (state == FUNC_ROTATE_STATE_OPENING)
		state = FUNC_ROTATE_STATE_OPEN;
	else if (state == FUNC_ROTATE_STATE_CLOSING)
		state = FUNC_ROTATE_STATE_CLOSED;

	avelocity = [0, 0, 0];	

	UseTargets();

	if (var_wait < 0)
	{
		think = Null;
	}
	else
	{
		nextthink = ltime + var_wait;
		think = Return;
		activator = enemy;
	}
};

void func_rotate :: Return ( void )
{
	state = FUNC_ROTATE_STATE_CLOSING;
	CalcRotate([0, 0, 0], var_speed, Done);

	if (spawnflags & FUNC_ROTATE_FLAG_CHANGEFRAMES)
		frame = 0;

	if (var_health)
		takedamage = DAMAGE_YES;
};

void func_rotate :: Done ( void )
{
	state = FUNC_ROTATE_STATE_CLOSED;

	if (sound_stop && sound_stop != "")
		sound(this, CHAN_VOICE, sound_stop, 1, ATTN_NORM);

	if (spawnflags & FUNC_ROTATE_FLAG_CHANGEFRAMES)
		frame = 0;
};

void func_rotate :: Use ( void )
{
	if (state == FUNC_ROTATE_STATE_OPENING || state == FUNC_ROTATE_STATE_CLOSING)
		return;

	if (spawnflags & FUNC_ROTATE_FLAG_CONTINIOUS)
	{
		state = FUNC_ROTATE_STATE_OPENING;
		CalcRotate(new_angles, var_speed, Wait);
		return;
	}

	if (state == FUNC_ROTATE_STATE_OPEN)
	{
		state = FUNC_ROTATE_STATE_CLOSING;
		CalcRotate([0, 0, 0], var_speed, Wait);
	}
	else
	{
		state = FUNC_ROTATE_STATE_OPENING;
		CalcRotate(new_angles, var_speed, Wait);
	}

	if (sound_start && sound_start != "")
		sound(this, CHAN_VOICE, sound_start, 1, ATTN_NORM);
};
