//
// parsemapentity.qc
//

float() ParseMapEntity =
{
	local string field, value;
	local entity newent = spawn();
	local void() spawnfunc = __NULL__;
	
	while (1)
	{
		field = getentitytoken();

		if not (field)
			break;

		if (field == "}")
		{
			if (!newent.classname)
				break;

			if (spawnfunc)
			{
				self = newent;
				spawnfunc();
				return TRUE;
			}

			remove(newent);
			return TRUE;
		}

		value = getentitytoken();

		if not (value)
			break;

		if (field == "classname")
		{
			if (value == "wui_test")
				spawnfunc = spawnfunc_wui_test;

			newent.classname = value;
		}
		else if (field == "model")
			newent.model = value;
		else if (field == "angles")
			newent.angles = stov(value);
		else if (field == "origin")
			setorigin(newent, stov(value));
	}

	remove(newent);

	return FALSE;
};