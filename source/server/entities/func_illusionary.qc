//
// func_illusionary.qc
//

class func_illusionary : CBaseBrushEntity
{
	void() func_illusionary;
};

void func_illusionary :: func_illusionary ( void )
{
	Initialize(MOVETYPE_PUSH, SOLID_NOT);
};