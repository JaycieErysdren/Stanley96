//
// weapons.qc
//

void(float event) WeaponEvent =
{
	float activeweapon = getstatf(STAT_ACTIVEWEAPON);

	if (event == WEAPON_FIRE)
	{
		if (activeweapon == IT_SHOTGUN) { SetEntityFrame(cl_viewmodel, F_SHOTGUN_SHOOT); localsound(S_SHOTGUN_SHOOT, CHAN_WEAPON); }
	}
	else if (event == WEAPON_RELOAD)
	{
		if (activeweapon == IT_SHOTGUN) return;
	}
};

void() UpdateWeapon =
{
	float activeweapon = getstatf(STAT_ACTIVEWEAPON);
	cl_viewmodel.frame1time += frametime;
};