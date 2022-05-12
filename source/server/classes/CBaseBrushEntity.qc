//
// CBaseBrushEntity.qc
//

class CBaseBrushEntity : CBaseEntity
{
	void() CBaseBrushEntity;

	virtual void(float, float) Initialize;
};

void CBaseBrushEntity :: CBaseBrushEntity ( void )
{
	// ??
};

void CBaseBrushEntity :: Initialize ( float move_type, float solid_type )
{
	movetype = move_type;
	solid = solid_type;

	setmodel(this, model);
	setorigin(this, origin);
};