//
// builtins.qc
//

//
// GLOBAL DEFINITIONS
//

void() precache_everything =
{
	//precache_model("progs/player.mdl");
	precache_model("sprites/null.spr");
	precache_sound("player/jump_land1.wav");
	precache_sound("player/jump1.wav");
	precache_sound("player/jump2.wav");
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

void() initialize_lightstyles =
{
	// 0 normal
	lightstyle(0, "m");
	
	// 1 FLICKER (first variety)
	lightstyle(1, "mmnmmommommnonmmonqnmmo");
	
	// 2 SLOW STRONG PULSE
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	
	// 3 CANDLE (first variety)
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
	
	// 4 FAST STROBE
	lightstyle(4, "mamamamamama");
	
	// 5 GENTLE PULSE 1
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");
	
	// 6 FLICKER (second variety)
	lightstyle(6, "nmonqnmomnmomomno");
	
	// 7 CANDLE (second variety)
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");
	
	// 8 CANDLE (third variety)
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
	
	// 9 SLOW STROBE (fourth variety)
	lightstyle(9, "aaaaaaaazzzzzzzz");
	
	// 10 FLUORESCENT FLICKER
	lightstyle(10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
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
	if (self.classname != "player")
		return;

	player pl = (player)self;
	pl.PreFrame();
};

void() PlayerPostThink =
{
	if (self.classname != "player")
		return;

	player pl = (player)self;
	pl.PostFrame();
};

void() ClientConnect = {};

void() worldspawn =
{	
	precache_everything();
	initialize_lightstyles();

	// flush data
	forceinfokey(world, "skyname", "");
	// force it
	forceinfokey(world, "skyname", self.skyname);
};

void() PutClientInServer =
{
	spawnfunc_player();
};

void() SV_RunClientCommand =
{
	if (self.view_ofs[2] == PLAYER_VIEW_OFFSET_CROUCHED[2])
		input_movevalues *= 0.4;

	runstandardplayerphysics(self);
};