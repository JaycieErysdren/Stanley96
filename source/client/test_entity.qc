//
// test_entity.qc
//

void() spawn_func_rotate =
{
	self.drawmask = MASK_HIGHLIGHT;

	setmodel(self, self.model);
	setorigin(self, self.origin);
};