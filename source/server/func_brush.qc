//
// func_brush.qc
//

class func_brush : CBaseBrushEntity
{
	void() func_brush;
};

void func_brush :: func_brush ( void )
{
	movetype = MOVETYPE_PUSH;
	solid = SOLID_BSP;

	Initialize();
};