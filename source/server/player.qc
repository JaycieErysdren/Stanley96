//
// player.qc
//

class player : CBaseEntity
{
	void() player;

	float usetime;
	float footsteptime;
	float readytime;

	float jump_flag;

	virtual vector(string) GetSpawn;
	virtual void() MovementStep;
	virtual void() Reload;
	#if defined(DUKE) || defined(BITCHHELL)
	virtual void() Attack;
	#endif
	virtual void() Melee;
	virtual void() Jump;
	virtual void() Crouch;
	virtual void() UnCrouch;
	virtual void() UseCheck;
	virtual void() PostFrame;
	virtual void() PreFrame;
	virtual void(float) SwitchWeapon;
	virtual void(float) Hurt;
	virtual void() Die;
	virtual void(vector, vector) SetSize;
};

void player :: player ( void )
{
	solid = SOLID_SLIDEBOX;
	precache_model("models/duke.iqm");
	setmodel(this, "models/duke.iqm");
	movetype = MOVETYPE_WALK;
	health = 100;
	setorigin(this, GetSpawn("origin"));
	angles = GetSpawn("angles");
	fixangle = TRUE;
	setsize(this, PLAYER_SIZE_MIN, PLAYER_SIZE_MAX);
	view_ofs = PLAYER_VIEW_OFFSET;

	items |= IT_SHOTGUN;
	weapon = IT_SHOTGUN;
	
	flags |= FL_CLIENT;
	takedamage = DAMAGE_YES;

	// reset MenuQC loading bar every time we get into a game
	localcmd("menu_cmd reset_loadingbar\n");

	#if defined(CRAFTWORLD)
		cvar_set("chase_active", "1");
	#endif
};

vector player :: GetSpawn ( string type )
{
	entity spawnpoint = find(world, ::classname, "info_player_start");

	if (!spawnpoint)
		return [0, 0, 0];

	switch (type)
	{
		case "origin" : return spawnpoint.origin;
		case "angles" : return spawnpoint.angles;
		default: objerror("didn't specify type"); break;
	}
};

void player :: Hurt ( float dmg )
{
	if (!takedamage || takedamage == DAMAGE_NO)
		return;

	health = health - dmg;

	if (health <= 0)
		Die();
};

void player :: Die ( void ) { };

void player :: PreFrame ( void )
{
	// scale safety check
	if (scale <= 0)
		scale = 1;

	if (scale != player_scale)
	{
		print("current scale is ", ftos(scale), " target scale is ", ftos(player_scale), "\n");
		scale = player_scale;
	}

	// skyroom stuff, gets networked to csqc by the engine
	view2 = sky_viewer;
	if (skyfogcmd2 != skyfogcmd) stuffcmd(this, 0, skyfogcmd, "\n");
	skyfogcmd2 = skyfogcmd;

	if (health > 0)
	{
		#if defined(CRAFTWORLD)
		layer = cvar("player_layer");

		if (layer == LAYER_BACK)
			setorigin(this, [origin_x, 160, origin_z]);
		else if (layer == LAYER_MIDDLE)
			setorigin(this, [origin_x, 96, origin_z]);
		else if (layer == LAYER_FRONT)
			setorigin(this, [origin_x, 32, origin_z]);
		#endif

		MovementStep();

		// stuff you can't do while noclipping
		if (movetype != MOVETYPE_NOCLIP)
		{
			if (button2 && flags & FL_ONGROUND)
				Jump();

			if (button4)
				Crouch();
			else
				UnCrouch();
		}

		// stuff you can't do if readytime hasn't expired
		if (time > readytime)
		{
			#if defined(DUKE) || defined(BITCHHELL)
			if (button0)
				Attack();
			#endif

			if (button3)
				UseCheck();

			if (button5)
				Melee();

			if (button6)
				Reload();
		}
	}
};

void player :: PostFrame ( void )
{
	if (health > 0)
	{
		if (jump_flag < -300 && flags & FL_ONGROUND)
		{
			sound(this, CHAN_VOICE, "player/jump_land1.wav", 1, ATTN_NORM);
			jump_flag = 0;
		}

		if (!(flags & FL_ONGROUND))
			jump_flag = velocity_z;
	}
};

void player :: Reload ( void ) { };

#if defined(DUKE) || defined(BITCHHELL)

void player :: Attack ( void )
{
	makevectors(v_angle);

	vector dir = aim(this, 1000);

	if (weapon == IT_SHOTGUN)
	{
		Client_ShakeOnce(origin, 512, 0.2, 0.1, 1.5);

		EasyMulticastFloat(EVENT_WEAPON, WEAPON_FIRE, this);

		LaunchBullet(origin + (view_ofs - [0, 0, 16]) + v_right*14, dir, 0.1, 10, 3000);
		LaunchBullet(origin + (view_ofs - [0, 0, 16]) + v_right*14, dir, 0.1, 10, 3000);
		LaunchBullet(origin + (view_ofs - [0, 0, 16]) + v_right*14, dir, 0.1, 10, 3000);
		LaunchBullet(origin + (view_ofs - [0, 0, 16]) + v_right*14, dir, 0.1, 10, 3000);
		LaunchBullet(origin + (view_ofs - [0, 0, 16]) + v_right*14, dir, 0.1, 10, 3000);

		currentammo -= 1;
		readytime = time + 1;
	}
};

#endif

void player :: SetSize ( vector minsize, vector maxsize )
{
	setsize(this, minsize, maxsize);
};

void player :: Jump ( void )
{
	sound(this, CHAN_AUTO, strcat("player/jump", ftos(ceil(random(0, 2))), ".wav"), 1, ATTN_NORM);
	flags &= ~FL_JUMPRELEASED;
	flags &= ~FL_ONGROUND;
	button2 = 0;

	velocity_z = velocity_z + 300;
};

void player :: UseCheck ( void )
{
	if (usetime > time)
		return;

	vector source = origin;
	source_z = absmin_z + size_z * 0.8;

	makevectors(v_angle);
	traceline(source, source + v_forward * 64, FALSE, this);

	if (trace_ent && trace_ent.flags & FL_USEABLE)
	{
		CBaseEntity use = (CBaseEntity)trace_ent;
		use.CallFunction("Use");
	}

	sound(this, CHAN_AUTO, strcat("player/use", ftos(ceil(random(0, 5))), ".wav"), 1, ATTN_NORM);

	usetime = time + 1;
};

void player :: MovementStep ( void )
{
	// these nested functions suck...
	string() footstep_snd =
	{
		string() footstep_check =
		{
			float surfacefloat = 0;
			string surfacestring = "";
			vector surfaceorigin = [0, 0, 0];

			traceline(origin, origin - [0, 0, 64], FALSE, this);

			if (trace_fraction != 1)
				surfaceorigin = trace_endpos;

			surfacefloat = getsurfacenearpoint(groundentity, surfaceorigin);

			if (surfacefloat >= 0)
				surfacestring = getsurfacetexture(groundentity, surfacefloat);

			surfacestring = substring(surfacestring, 0, 4);

			return surfacestring;
		};

		string check;
		string random_step = ftos(ceil(random(0, 4)));
		
		if (footstep_check() == "carp") // carpet
			check = strcat("player/footsteps/carpet", random_step, ".wav");
		else if (footstep_check() == "ston") // stone
			check = strcat("player/footsteps/concrete", random_step, ".wav");
		else if (footstep_check() == "conc") // concrete
			check = strcat("player/footsteps/concrete", random_step, ".wav");
		else if (footstep_check() == "meta") // metal
			check = strcat("player/footsteps/metal", random_step, ".wav");
		else if (footstep_check() == "tile") // tile
			check = strcat("player/footsteps/tile", random_step, ".wav");
		else if (footstep_check() == "colo") // solid color
			check = "";
		else // generic
			check = strcat("player/footsteps/concrete", random_step, ".wav");
		return check;
	};

	float high = vlen(velocity) > 250;
	float low = vlen(velocity) < 250;
	float delay = 0;
	string step = footstep_snd();

	if (velocity_x || velocity_y && !velocity_z && footsteptime < time)
	{
		sound(this, CHAN_AUTO, step, 0.5, ATTN_NORM);
		if (high) delay = 0.25;
		if (low) delay = 0.5;
		footsteptime = time + delay;
	}
};

void player :: Crouch ( void )
{
	setsize(this, PLAYER_SIZE_MIN_CROUCHED * scale, PLAYER_SIZE_MAX_CROUCHED * scale);
	view_ofs = PLAYER_VIEW_OFFSET_CROUCHED * scale;
};

void player :: UnCrouch ( void )
{
	tracebox(origin, PLAYER_SIZE_MIN, PLAYER_SIZE_MAX, [origin_x, origin_y, PLAYER_SIZE_MAX[2]], 0, this);

	if (!trace_allsolid)
	{
		button4 = 0;
		setsize(this, PLAYER_SIZE_MIN, PLAYER_SIZE_MAX);
		view_ofs = PLAYER_VIEW_OFFSET;
	}
};

void player :: Melee ( void )
{
	EasyMulticastFloat(EVENT_WEAPON, WEAPON_MELEE, this);
	readytime = time + 1;
};

void player :: SwitchWeapon ( float to ) { };