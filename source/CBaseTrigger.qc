//
// CBaseTrigger.qc
//

class CBaseTrigger : CBaseBrushEntity
{
	void() CBaseTrigger;
	
	virtual void() Use;
};

void CBaseTrigger :: CBaseTrigger ( void )
{
	solid = SOLID_TRIGGER;

	Initialize();

	modelindex = 0;
	model = "";
};

void CBaseTrigger :: Use ( void )
{
	if (nextthink > time)
		return;
	
	activator = enemy;

	UseTargets();

	if (target_reset > 0)	
	{
		think = Null;
		nextthink = time + target_reset;
	}
	else
	{
		nextthink = time + 0.1;
		touch = Null;
		think = Remove;
	}
};