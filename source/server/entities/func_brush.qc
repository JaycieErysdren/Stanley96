//
// func_brush.qc
//

enumflags
{
	FUNC_BRUSH_START_INVISIBLE,
	FUNC_BRUSH_START_NONSOLID,
	FUNC_BRUSH_START_ALTFRAMES,
	FUNC_BRUSH_TOGGLE_VISIBILITY,
	FUNC_BRUSH_TOGGLE_SOLIDITY,
	FUNC_BRUSH_TOGGLE_FRAMES
};

class func_brush : CBaseBrushEntity
{
	string temp_model;

	void() func_brush;

	virtual void() Trigger;
	virtual void() ToggleVisible;
	virtual void() ToggleSolid;
	virtual void() ToggleFrame;
	virtual void(string) CallFunction;
};

void func_brush :: func_brush ( void )
{
	if (spawnflags & FUNC_BRUSH_START_NONSOLID)
		Initialize(MOVETYPE_PUSH, SOLID_NOT);
	else
		Initialize(MOVETYPE_PUSH, SOLID_BSP);

	touch = Null;
	temp_model = model;

	if (spawnflags & FUNC_BRUSH_START_INVISIBLE)
		ToggleVisible();

	if (spawnflags & FUNC_BRUSH_START_ALTFRAMES)
		frame = 1;
};

void func_brush :: CallFunction ( string func )
{
	switch (func)
	{
		case "ToggleVisible" : ToggleVisible(); break;
		case "ToggleSolid" : ToggleSolid(); break;
		case "ToggleFrame" : ToggleFrame(); break;
		default: super :: CallFunction(func); break;
	}
};

void func_brush :: Trigger ( void )
{
	if (spawnflags & FUNC_BRUSH_TOGGLE_VISIBILITY)
		ToggleVisible();

	if (spawnflags & FUNC_BRUSH_TOGGLE_SOLIDITY)
		ToggleSolid();

	if (spawnflags & FUNC_BRUSH_TOGGLE_FRAMES)
		ToggleFrame();
};

void func_brush :: ToggleVisible ( void )
{
	if (model != "")
		setmodel(this, "");
	else
		setmodel(this, temp_model);
};

void func_brush :: ToggleSolid ( void )
{
	if (solid == SOLID_BSP)
		solid = SOLID_NOT;
	else
		solid = SOLID_BSP;
};

void func_brush :: ToggleFrame ( void )
{
	frame = 1 - frame;
};