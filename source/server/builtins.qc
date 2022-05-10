//
// builtins.qc
//

//
// GLOBAL DEFINITIONS
//

void() precache_everything =
{
	precache_model("progs/player.mdl");
	precache_sound("player/use1.wav");
	precache_sound("player/use2.wav");
	precache_sound("player/use3.wav");
	precache_sound("player/use4.wav");
	precache_sound("player/use5.wav");
	precache_sound("player/footsteps/carpet1.wav");
	precache_sound("player/footsteps/carpet2.wav");
	precache_sound("player/footsteps/carpet3.wav");
	precache_sound("player/footsteps/carpet4.wav");
	precache_sound("player/footsteps/concrete1.wav");
	precache_sound("player/footsteps/concrete2.wav");
	precache_sound("player/footsteps/concrete3.wav");
	precache_sound("player/footsteps/concrete4.wav");
	precache_sound("player/footsteps/metal1.wav");
	precache_sound("player/footsteps/metal2.wav");
	precache_sound("player/footsteps/metal3.wav");
	precache_sound("player/footsteps/metal4.wav");
	precache_sound("player/footsteps/tile1.wav");
	precache_sound("player/footsteps/tile2.wav");
	precache_sound("player/footsteps/tile3.wav");
	precache_sound("player/footsteps/tile4.wav");
};

float player_footsteptimer;
float player_usetimer;

//
// PLAYER FUNCTIONS
//

void() info_player_start = {};
void() info_teleport_destination = {};

vector() GetSpawnPoint =
{
	entity spawnpoint = find(world, classname, "info_player_start");

	if (spawnpoint)
		return spawnpoint.origin;
	else
		return [0, 0, 0];
};

vector() GetSpawnAngles =
{
	entity spawnpoint = find(world, classname, "info_player_start");

	if (spawnpoint)
		return spawnpoint.angles;
	else
		return [0, 0, 0];
};

//
// PLAYER FOOTSTEPS
//

string() Player_Footstep_Check =
{
	float surfacefloat = 0;
	string surfacestring = "";
	vector surfaceorigin = '0 0 0';

	traceline(self.origin, self.origin - '0 0 64', FALSE, self);

	if (trace_fraction != 1)
		surfaceorigin = trace_endpos;

	surfacefloat = getsurfacenearpoint(self.groundentity, surfaceorigin);

	if (surfacefloat >= 0)
		surfacestring = getsurfacetexture(self.groundentity, surfacefloat);

	surfacestring = substring(surfacestring, 0, 4);

	return surfacestring;
};

string() Player_Footstep_Sound =
{
	string check;
	string random_step = ftos(ceil(random(0, 4)));
	
	if (Player_Footstep_Check() == "carp") // carpet
		check = strcat("player/footsteps/carpet", random_step, ".wav");
	else if (Player_Footstep_Check() == "ston") // stone
		check = strcat("player/footsteps/concrete", random_step, ".wav");
	else if (Player_Footstep_Check() == "conc") // concrete
		check = strcat("player/footsteps/concrete", random_step, ".wav");
	else if (Player_Footstep_Check() == "meta") // metal
		check = strcat("player/footsteps/metal", random_step, ".wav");
	else if (Player_Footstep_Check() == "tile") // tile
		check = strcat("player/footsteps/tile", random_step, ".wav");
	else if (Player_Footstep_Check() == "colo") // solid color
		check = "";
	else // generic
		check = strcat("player/footsteps/concrete", random_step, ".wav");
	return check;
};

void() Player_Footstep =
{
	float high = vlen(self.velocity) > 250;
	float low = vlen(self.velocity) < 250;
	float delay = 0;
	string step = Player_Footstep_Sound();

	if (self.velocity_x || self.velocity_y && !self.velocity_z && player_footsteptimer < time)
	{
		sound(self, CHAN_AUTO, step, 0.5, ATTN_NORM);
		if (high) delay = 0.25;
		if (low) delay = 0.5;
		player_footsteptimer = time + delay;
	}
};

//
// PLAYER +USE
//

void() Player_UseCheck = 
{
	if (player_usetimer > time)
		return;

	vector source = self.origin;
	source_z = self.absmin_z + self.size_z * 0.8;

	makevectors(self.v_angle);
	traceline(source, source + v_forward * 64, FALSE, self);

	if (trace_ent && trace_ent.flags & FL_USEABLE)
	{
		CBaseEntity use = (CBaseEntity)trace_ent;
		use.Use();
	}

	sound(self, CHAN_AUTO, strcat("player/use", ftos(ceil(random(0, 5))), ".wav"), 1, ATTN_NORM);

	player_usetimer = time + 1;
};

//
// ENGINE BUILTINS
//

void() main = {};

void() StartFrame =
{
	for (entity a = world; (a = findfloat(a, ::identity, 1));)
	{
		CBaseEntity ent = (CBaseEntity)a;
		ent.FrameUpdate();
	}
};

void() RestoreGame = {};

void() PlayerPreThink =
{
	if (self.health)
	{
		Player_Footstep();

		if (self.button3)
			Player_UseCheck();
	}
};

void() PlayerPostThink = {};
void() ClientConnect = {};

void() worldspawn =
{	
	precache_everything();
};

void() PutClientInServer =
{
	self.classname = "player";
	self.solid = SOLID_SLIDEBOX;
	setmodel(self, "progs/player.mdl");
	self.movetype = MOVETYPE_WALK;
	self.health = 100;
	setorigin(self, GetSpawnPoint());
	self.angles = GetSpawnAngles();
	self.fixangle = TRUE;

	if (cvar_string("mapname") == "wolf")
	{
		// wolf3d player size
		setsize(self, [-16, -16, 0], [16, 16, 56]);
		self.view_ofs = [0, 0, 32];
	}
	else
	{
		// half-life 2 player size
		setsize(self, [-16, -16, 0], [16, 16, 72]);
		self.view_ofs = [0, 0, 64];
	}

	// quake player size
	// setsize(self, [-16, -16, -24], [16, 16, 32]);
	// self.view_ofs = [0, 0, 22];
	
	// reset MenuQC loading bar every time we get into a game
	localcmd("menu_cmd reset_loadingbar\n");
};

void() SV_RunClientCommand =
{
	runstandardplayerphysics(self);
};