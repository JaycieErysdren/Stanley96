//
// CBaseBrushEntity.qc
//

class CBaseBrushEntity : CBaseEntity
{
	void() CBaseBrushEntity;

	virtual void() Initialize;
};

void CBaseBrushEntity :: CBaseBrushEntity ( void )
{
	if (!movetype)
		movetype = MOVETYPE_NONE;

	if (!solid)
		solid = SOLID_NOT;
};

void CBaseBrushEntity :: Initialize ( void )
{
	setmodel(this, model);
	setorigin(this, origin);
};