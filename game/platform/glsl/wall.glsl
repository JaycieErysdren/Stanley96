!!ver 100 450

!!permu FULLBRIGHT
!!permu FOG
!!permu LIGHTSTYLED

!!cvardf r_fakesoftware = 0
!!cvardf r_pixel_maxres

!!samps diffuse lightmap
!!samps =FULLBRIGHT fullbright
!!samps !MASK colourmap=0 paletted=1

#include "sys/defs.h"
#include "sys/fog.h"

varying vec2 txc;
varying vec2 lmc;

#ifdef VERTEX_SHADER

	void main()
	{
		txc = v_texcoord;
		lmc = v_lmcoord;

		gl_Position = ftetransform();
	}

#endif

#ifdef FRAGMENT_SHADER

	void main()
	{
		vec2 ntxc = txc;

		// this is really just a weird debug command now
		#if r_pixel_maxres > 0
			vec2 pixels = vec2(r_pixel_maxres);
			ntxc.x -= mod(ntxc.x, 1.0 / pixels.x);
			ntxc.y -= mod(ntxc.y, 1.0 / pixels.y);
		#elif defined(PXLX) && defined(PXLY)
			vec2 pixels = vec2(PXLX, PXLY);
			ntxc.x -= mod(ntxc.x, 1.0 / pixels.x);
			ntxc.y -= mod(ntxc.y, 1.0 / pixels.y);
		#endif

		#if defined(RPTD)
			vec4 diffuse = texture2D(s_diffuse, ntxc - floor(ntxc) * RPTD);
		#else
			vec4 diffuse = texture2D(s_diffuse, ntxc - floor(ntxc));
		#endif

		vec3 lightmaps = (texture2D(s_lightmap, lmc) * e_lmscale).rgb;

		#if r_fakesoftware == 1
			lightmaps *= 0.5;
			float pal = texture2D(s_paletted, ntxc).r;
			lightmaps -= 1.0 / 128.0;
			diffuse.r = texture2D(s_colourmap, vec2(pal, 1.0-lightmaps.r)).r;
			diffuse.g = texture2D(s_colourmap, vec2(pal, 1.0-lightmaps.g)).g;
			diffuse.b = texture2D(s_colourmap, vec2(pal, 1.0-lightmaps.b)).b;
		#else
			diffuse.rgb *= lightmaps.rgb;
		#endif

		#if defined(DISCARD)
			if (diffuse.a < 0.1) discard;
		#endif

		vec4 final = fog4(diffuse * e_colourident);

		gl_FragColor = final;
	}

#endif