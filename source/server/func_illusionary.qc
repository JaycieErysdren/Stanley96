//
// func_illusionary.qc
//

class func_illusionary : CBaseBrushEntity
{
	void() func_illusionary;
};

void func_illusionary :: func_illusionary ( void )
{
	movetype = MOVETYPE_PUSH;
	solid = SOLID_NOT;

	Initialize();
};