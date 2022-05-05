//
// GLOBAL DEFINITIONS
//

void() precache_everything =
{
	precache_model("progs/player.mdl");
};

string __fullspawndata;

entity activator;

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

//
// MULTICAST FUNCTIONS
//

void(float event, float value, entity ent) EasyMulticastFloat =
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, event);
	WriteFloat(MSG_MULTICAST, value);
	msg_entity = ent;
	multicast(ent.origin, MULTICAST_ONE_R);
};

void(float event, string value, entity ent) EasyMulticastString =
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, event);
	WriteString(MSG_MULTICAST, value);
	msg_entity = ent;
	multicast(ent.origin, MULTICAST_ONE_R);
};