//
// func_door.qc
//

class func_door : CBaseBrushEntity
{
	void() func_door;
};

void func_door :: func_door ( void )
{
	movetype = MOVETYPE_PUSH;
	solid = SOLID_BSP;

	Initialize();
};