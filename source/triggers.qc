//
// TRIGGER_NARRATOR
//

void() trigger_narrator_end =
{
	remove(self);
};

void() trigger_narrator_touch =
{
	if (self.nextthink > time)
		return;

	if (other.classname != "player")
		return;

	self.enemy = other;

	if (!self.narrator || self.narrator == "")
		objerror("didn't set a narrator line!!");

	EasyMulticastFloat(EVENT_NARRATOR, stof(self.narrator), other);

	self.nextthink = time + 1;
	self.think = trigger_narrator_end;
};

void() trigger_narrator =
{
	setmodel (self, self.model);
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
	self.solid = SOLID_TRIGGER;

	self.touch = trigger_narrator_touch;
};