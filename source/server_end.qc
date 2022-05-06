//
// server_end.qc
//

// this stuff needs to be defined after everything else, or else it won't work :/

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