//
// FUNC_BRUSH
//

void() func_brush =
{
	self.solid = SOLID_BSP;
	//self.angles = self.mangle;
	self.movetype = MOVETYPE_PUSH;
	setmodel(self, self.model);
}