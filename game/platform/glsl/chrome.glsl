!!ver 130
!!permu FRAMEBLEND
!!permu SKELETAL
!!permu UPPERLOWER
!!permu FOG
!!samps diffuse reflectcube upper lower
!!cvardf gl_affinemodels=0
!!cvardf gl_ldr=1
!!cvardf gl_halflambert=1
!!cvardf gl_mono=0
!!cvardf gl_kdither=0
!!cvardf gl_stipplealpha=0

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!samps =FAKESHADOWS shadowmap

!!cvardf r_skipDiffuse

#include "sys/defs.h"
#include "sys/fog.h"

#if gl_affinemodels == 1
	#define affine noperspective
#else
	#define affine
#endif

affine varying vec2 tex_c;
varying vec3 light;

#ifdef VERTEX_SHADER
	#include "sys/skeletal.h"

	float lambert( vec3 normal, vec3 dir ) {
		return dot( normal, dir );
	}
	float halflambert( vec3 normal, vec3 dir ) {
		return ( dot( normal, dir ) * 0.5 ) + 0.5;
	}

	/* Rotate Light Vector */
	vec3 rlv(vec3 axis, vec3 origin, vec3 lightpoint)
	{
		vec3 offs;
		vec3 result;
		offs[0] = lightpoint[0] - origin[0];
		offs[1] = lightpoint[1] - origin[1];
		offs[2] = lightpoint[2] - origin[2];
		result[0] = dot(offs[0], axis[0]);
		result[1] = dot(offs[1], axis[1]);
		result[2] = dot(offs[2], axis[2]);
		return result;
	}

	void main ()
	{
		vec3 n, s, t, w;
		gl_Position = skeletaltransform_wnst(w,n,s,t);
		tex_c = v_texcoord;

		light = e_light_ambient + (e_light_mul * halflambert(n, e_light_dir));

		light *= e_lmscale.r;

		if (gl_ldr == 1.0) {
			if (light.r > 1.5)
				light.r = 1.5;
			if (light.g > 1.5)
				light.g = 1.5;
			if (light.b > 1.5)
				light.b = 1.5;

			light.rgb * 0.5;
			light.rgb = floor(light.rgb * vec3(32,64,32))/vec3(32,64,32);
			light.rgb * 2.0;
			light.rgb *= 0.75;
		}

		vec3 rorg = rlv(vec3(0,0,0), w, e_light_dir);
		vec3 viewc = normalize(rorg - w);
		float d = dot(n, viewc);
		vec3 reflected;
		reflected.x = n.x * 2.0 * d - viewc.x;
		reflected.y = n.y * 2.0 * d - viewc.y;
		reflected.z = n.z * 2.0 * d - viewc.z;
		tex_c.x = 0.5 + reflected.y * 0.5;
		tex_c.y = 0.5 - reflected.z * 0.5;
	}
#endif


#ifdef FRAGMENT_SHADER
	#include "sys/pcf.h"

	void main ()
	{
		vec4 diffuse_f;

		diffuse_f = texture2D(s_diffuse, tex_c);

		diffuse_f.rgb *= light;

		if (e_colourident.z != 2.0) {
			diffuse_f *= e_colourident;
		}

		gl_FragColor = fog4(diffuse_f);
	}
#endif
