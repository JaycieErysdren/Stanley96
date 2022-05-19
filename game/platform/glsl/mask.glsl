!!ver 100-450
!!permu FULLBRIGHT

!!samps img=0 mask=1
!!samps =FULLBRIGHT fullbright

varying vec2 tc;
varying vec4 vc;

#ifdef VERTEX_SHADER

	attribute vec2 v_texcoord;
	attribute vec4 v_colour;

	void main ()
	{
		tc = v_texcoord;
		vc = v_colour;
		gl_Position = ftetransform();
	}

#endif

#ifdef FRAGMENT_SHADER

	void main ()
	{
		vec2 p = tc;

		#if defined(PIXELATE_D)
			vec2 pixels = vec2(PIXELATE_D);
			p.x -= mod(p.x, 1.0 / pixels.x);
			p.y -= mod(p.y, 1.0 / pixels.y);
		#endif

		#if defined(REPEAT_M)
			vec4 mask = texture2D(s_mask, tc * REPEAT_M);
		#else
			vec4 mask = texture2D(s_mask, tc);
		#endif

		#if defined(REPEAT_D)
			vec4 img = texture2D(s_img, p - floor(p) * REPEAT_D);
		#else
			vec4 img = texture2D(s_img, p - floor(p));
		#endif
		
		#if defined(ALPHA)
			img.a = mask.r * ALPHA;
		#else
			img.a = mask.r;
		#endif

		#if defined(DISCARD)
			if (img.a < 0.1)
				discard;
		#endif

		#if defined(FULLBRIGHT)
			img.rgb += texture2D(s_fullbright, tc).rgb;
		#endif
		
		gl_FragColor = vec4(img * mask.r);
	}

#endif