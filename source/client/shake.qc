//
// shake.qc
//

void() UpdateShake =
{
	if (shake_duration > 0.0) {
		vector shakevec = [0,0,0];
		shakevec[0] += random() * 3;
		shakevec[1] += random() * 3;
		shakevec[2] += random() * 3;
		shake_angle += (shakevec * shake_amplitude) * (shake_duration / shake_time);
		shake_duration -= frametime;
	}
}

void() ResetShake =
{
	shake_angle = [0, 0, 0];
};