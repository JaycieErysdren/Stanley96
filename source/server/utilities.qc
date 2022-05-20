//
// utilities.qc
//

// ParticleBlood
void(vector org, vector vel, float damage) ParticleBlood =
{
	particle(org, vel*0.1, 73, damage*2);
};

// ParticleImpact
void(vector org, vector vel, float damage) ParticleImpact =
{
	particle(org, vel*0.1, 2, damage*2);
};

#if defined(DUKE) || defined(BITCHHELL)

// LaunchBullet
void(vector org, vector dir, float spread, float damage, float speed) LaunchBullet =
{
	void() BulletTouch =
	{
		if (other == self.owner)
			return;

		if (other.solid == SOLID_TRIGGER)
			return;

		#ifdef 0
		if (other.flags & FL_MONSTER)
		{
			CBaseMonster temp = (CBaseMonster)other;
			temp.Hurt(self.health);

			ParticleBlood(self.origin, [0, 0, 0], 5);

			remove(self);
			return;
		}

		if (other.flags & FL_CLIENT)
		{
			localcmd("hurtme ", ftos(self.health), "\n");
			ParticleBlood(self.origin, [0, 0, 0], 5);
			remove(self);
			return;
		}
		#endif

		if (pointcontents(self.origin) == CONTENT_SKY)
		{
			remove(self);
			return;
		}

		ParticleImpact(self.origin, [0, 0, 0], 15);
		remove(self);
	};

	void() BulletRemove =
	{
		remove(self);
	};

	CBaseEntity bullet = spawn(CBaseEntity);

	bullet.owner = self;
	bullet.movetype = MOVETYPE_FLYMISSILE;
	bullet.solid = SOLID_BBOX;

	if (spread)
	{
		dir += random(-1,1) * spread * v_right;
		dir += random(-1,1) * spread * v_up;
	}

	if (damage)
		bullet.health = damage;
	else
		bullet.health = 5;

	bullet.angles = vectoangles(dir);

	bullet.touch = BulletTouch;
	bullet.classname = "_Bullet";
	bullet.think = BulletRemove;
	bullet.nextthink = time + 6;
	setmodel(bullet, "models/bullet.mdl");
	setsize(bullet, [0, 0, 0], [0, 0, 0]);
	setorigin(bullet, org);
	bullet.scale = 3;
	bullet.modelflags |= MF_GRENADE;

	if (speed)
		bullet.velocity = dir * speed;
	else
		bullet.velocity = dir * 2048;
};

#endif

// Client_ShakeOnce
void(vector pos, float radius, float duration, float frequency, float amplitude) Client_ShakeOnce =
{
	for (entity pl = world; (pl = find(pl, ::classname, "player"));) {
		float amp;

		if (vlen(pos - pl.origin) > radius)
			continue;

		amp = 1.0 - (vlen(pos - pl.origin) / radius);

		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EVENT_SHAKE);
		WriteFloat(MSG_MULTICAST, duration);
		WriteFloat(MSG_MULTICAST, amplitude * amp);
		WriteFloat(MSG_MULTICAST, frequency);

		msg_entity = pl;
		multicast([0,0,0], MULTICAST_ONE);
	}
};