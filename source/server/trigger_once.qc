//
// trigger_once.qc
//

class trigger_once : CBaseTrigger
{
	void() trigger_once;
};

void trigger_once :: trigger_once ( void )
{
	target_reset = -1;
};