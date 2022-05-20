//
// wui.qc
//

// wui entity class

class wui_test
{
	void() wui_test;
	virtual float() predraw;
};

void wui_test :: wui_test ( void )
{
	print("^2WUI SPAWNWED\n");
	drawmask = MASK_ENGINE;
};

float wui_test :: predraw ( void )
{
	float vsz = 32;
	float hsz = vsz / 2;
	makevectors(angles);
	//print("wui_test, v_right: ", vtos([v_right[0] * (vsz / 2), v_right[1] * (vsz / 2), v_right[2] * (vsz / 2)]), "\n");

	vector mvec = [v_right[0] + v_up[0], v_right[1] + v_up[1], v_right[2] + v_up[2]];

	vector vertexpos1 = origin + [mvec[0] * hsz, mvec[1] * hsz, mvec[2] * hsz];
	vector vertexpos2 = origin + [-mvec[0] * hsz, mvec[1] * hsz, mvec[2] * hsz];
	vector vertexpos3 = origin + [-mvec[0] * hsz, -mvec[1] * hsz, -mvec[2] * hsz];
	vector vertexpos4 = origin + [mvec[0] * hsz, -mvec[1] * hsz, -mvec[2] * hsz];

	vector vclr = [1, 1, 1];
	float valpha = 1;

	vector vtcmin = [0, 0];
	vector vtcmax = [1, 1];

	R_BeginPolygon("textures/worldui/ezbase", 0, FALSE);
	R_PolygonVertex(vertexpos1, vtcmin, vclr, valpha);
	R_PolygonVertex(vertexpos2, [vtcmax[0], vtcmin[1]], vclr, valpha);
	R_PolygonVertex(vertexpos3, vtcmax, vclr, valpha);
	R_PolygonVertex(vertexpos4, [vtcmin[0], vtcmax[1]], vclr, valpha);
	R_EndPolygon();

	addentity(this);
	return (PREDRAW_NEXT);
};