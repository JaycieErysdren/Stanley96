//
// point_skycamera.qc
//

enumflags
{
	POINT_SKYCAMERA_DONT_SKYROOM
};

class point_skycamera : CBaseEntity
{
	string skybox;

	float skyroom_scale;

	float skyfog_density;
	vector skyfog_color;

	vector rotation_angles;
	float rotation_speed;

	void() point_skycamera;
	
	virtual void() UpdateSky;
	virtual void() UpdateSkyFog;
	virtual void() Trigger;
	virtual void(string, string) SpawnKey;
	virtual void(string) CallFunction;
};

void point_skycamera :: point_skycamera ( void )
{
	// hack
	skin = 16;

	super :: CBaseEntity();

	UpdateSky();
};

void point_skycamera :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "skybox" : skybox = value; break;
		case "skyroom_scale" : skyroom_scale = stof(value); break;
		case "rotation_angles" : rotation_angles = stov(value); break;
		case "rotation_speed" : rotation_speed = stof(value); break;
		case "skyfog_density" : skyfog_density = stof(value); break;
		case "skyfog_color" : skyfog_color = stov(value); break;
		default: super :: SpawnKey(key, value); break;
	}
};

void point_skycamera :: CallFunction ( string func )
{
	switch (func)
	{
		case "UpdateSky" : UpdateSky(); break;
		default: super :: CallFunction(func); break;
	}
};


void point_skycamera :: Trigger ( void )
{
	UpdateSky();
};

void point_skycamera :: UpdateSky ( void )
{
	if (!(spawnflags & POINT_SKYCAMERA_DONT_SKYROOM))
	{
		entity viewer = spawn();
		viewer.classname = "_SkyViewer";
		viewer.angles = rotation_angles;
		viewer.frame = rotation_speed;
		viewer.skin = skyroom_scale;
		setorigin(viewer, origin);
		sky_viewer = viewer;
	}

	if (skybox && skybox != "")
		localcmd(strcat("sky ", skybox, "\n"));

	print("sky updated.\n");

	if (!targetname || targetname == "")
		Remove();
};

void point_skycamera :: UpdateSkyFog ( void )
{
	if (skyfog_color)
		skyfog_color = [skyfog_color_x / 255, skyfog_color_y / 255, skyfog_color_z / 255];
	else
		skyfog_color = [1, 1, 1];

	string realcolor = strcat(ftos(skyfog_color_x), " ", ftos(skyfog_color_y), " ", ftos(skyfog_color_z));
	string skyroomfogcmd = strcat("skyroomfog ", ftos(skyfog_density), " ", realcolor);
};