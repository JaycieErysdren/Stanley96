//
// GLOBAL DEFINITIONS
//

void() precache_everything =
{
	precache_model("progs/player.mdl");
	//precache_model("progs/v_shot.mdl");
	//precache_sound("weapons/guncock.wav");
};

//
// PLAYER FUNCTIONS
//

void() info_player_start = {};

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
// ENGINE BUILTINS
//

void() main = {};
void() StartFrame = {};
void() RestoreGame = {};
void() PlayerPreThink = {};
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

	// half-life 2 player size
	setsize(self, [-16, -16, 0], [16, 16, 72]);
	self.view_ofs = [0, 0, 64];

	// quake player size
	// setsize(self, [-16, -16, -24], [16, 16, 32]);
	// self.view_ofs = [0, 0, 22];
};

void() SV_RunClientCommand =
{
	runstandardplayerphysics(self);
};