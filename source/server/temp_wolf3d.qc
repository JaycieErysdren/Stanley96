//
// temp_wolf3d.qc
//

// stolen shamelessly from the Quake Wolf3D port, for the 2022/05/05 30th anniversary of the game

void() wolf_decor =
{
	if (!self.model)
	{
		precache_model ("sprites/decor/wolfdeco.spr");
		setmodel (self, "sprites/decor/wolfdeco.spr");
	}
	else
	{
		precache_model (self.model);
		setmodel (self, self.model);
	}

	if (self.model == "sprites/decor/wolfdeco.spr")
	{
		if ( (self.frame == 6) || (self.frame == 15) )
		{
			setsize (self, '-16 -16 -32', '16 16 24');
			return;
		}
	}

	if (!self.frame)
		self.frame = 0;

	if (world.model != "maps/sce1.bsp")
		makestatic (self);
};