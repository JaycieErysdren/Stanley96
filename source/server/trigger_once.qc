//
// trigger_once.qc
//

class trigger_once : CBaseTrigger
{
	void() trigger_once;
};

void trigger_once :: trigger_once ( void )
{
	reset_time = -1;
};