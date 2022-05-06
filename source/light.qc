//
// light.qc
//

class light : CBaseEntity
{
	void() light;
};

void light :: light ( void )
{
	makestatic(this);
};