//
// utilities.qc
//

// SetEntityFrame
void(entity ent, float newframe) SetEntityFrame =
{
	ent.frame = newframe;
	ent.frame1time = 0.0f;
};

// TriggerMapEntity
void(string name, string func) TriggerMapEntity =
{
	print("Triggering entity ", name, " with function ", func, " at ", ftos(time), "\n");
	sendevent("FireTarget", "ss", name, func);
};
