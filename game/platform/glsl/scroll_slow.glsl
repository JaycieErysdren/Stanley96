!!ver 100 450
!!permu FOG
!!samps diffuse lightmap
#include "sys/defs.h"
#include "sys/fog.h"
varying vec2 tc;
varying vec2 lm0;
#ifdef VERTEX_SHADER
	void main ()
	{
		tc = v_texcoord.st;
		
		tc.s += e_time * -0.009;

		lm0 = v_lmcoord;
		gl_Position = ftetransform();
	}
#endif
#ifdef FRAGMENT_SHADER
	void main ()
	{
		vec2 ntc;
		ntc.s = tc.s;
		ntc.t = tc.t;
		vec3 ts = vec3(texture2D(s_diffuse, ntc));
		
		ts *= (texture2D(s_lightmap, lm0) * e_lmscale).rgb;
		
		gl_FragColor = fog4(vec4(ts, 1.0) * e_colourident);
	}
#endif