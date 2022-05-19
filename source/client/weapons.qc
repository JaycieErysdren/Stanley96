//
// weapons.qc
//

void(float event) WeaponEvent =
{
	float activeweapon = getstatf(STAT_ACTIVEWEAPON);

	if (event == WEAPON_FIRE)
	{
		if (activeweapon == IT_SHOTGUN) { SetEntityFrame(cl_viewmodel1, F_SHOTGUN_SHOOT); localsound(S_SHOTGUN_SHOOT, CHAN_WEAPON, cvar("volume")); }
	}
	else if (event == WEAPON_RELOAD)
	{
		if (activeweapon == IT_SHOTGUN) return;
	}
	else if (event == WEAPON_MELEE)
	{
		SetEntityFrame(cl_viewmodel2, F_KICK_SHOOT);
	}
};

void() UpdateWeapon =
{
	float activeweapon = getstatf(STAT_ACTIVEWEAPON);
	cl_viewmodel1.frame1time += frametime;
	cl_viewmodel2.frame1time += frametime;
};