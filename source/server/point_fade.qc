//
// point_fade.qc
//

class point_fade : CBaseEntity
{
	float fade_time;
	float fade_alpha;
	float fade_type;
	string fade_color;

	void() point_fade;
	
	virtual void() FadeTo;
	virtual void() FadeFrom;
	virtual void() Trigger;
	virtual void(string, string) SpawnKey;
};

void point_fade :: point_fade ( void )
{
	// ??
};

void point_fade :: SpawnKey ( string key, string value )
{
	switch (key)
	{
		case "fade_type" : fade_type = stof(value); break;
		case "fade_time" : fade_time = stof(value); break;
		case "fade_color" : fade_color = value; break;
		default: super :: SpawnKey(key, value); break;
	}
};

void point_fade :: Trigger ( void )
{
	if (nextthink > time)
		return;

	if (!fade_color || fade_color == "")
		cvar_set("r_fade_color", "0 0 0");
	else
		cvar_set("r_fade_color", fade_color);

	if (fade_type == 1)
	{
		fade_alpha = 0;
		nextthink = time + 0.1;
		think = FadeTo;
	}
	else
	{
		fade_alpha = 0;
		nextthink = time + 0.1;
		think = FadeTo;
	}
};

void point_fade :: FadeTo ( void )
{
	fade_alpha += frametime / fade_time;
	fade_alpha = bound(0, fade_alpha, 1);
	
	cvar_set("r_fade_alpha", ftos(fade_alpha));

	if (fade_alpha >= 1)
	{
		UseTargets();
		nextthink = time + 0.1;
		think = Remove;
	}
	else
	{
		nextthink = time + 0.1;
	}
};

void point_fade :: FadeFrom ( void )
{
	fade_alpha -= frametime / fade_time;
	fade_alpha = bound(0, fade_alpha, 1);
	
	cvar_set("r_fade_alpha", ftos(fade_alpha));

	if (fade_alpha <= 0)
	{
		UseTargets();
		nextthink = time + 0.1;
		think = Remove;
	}
	else
	{
		nextthink = time + 0.1;
	}
};