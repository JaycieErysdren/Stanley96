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

	#ifdef REPEAT4
		uniform vec2 repeat = vec2(2, 2);
	#elif defined(REPEAT8)
		uniform vec2 repeat = vec2(4, 4);
	#else
		uniform vec2 repeat = vec2(1, 1);
	#endif

	void main ()
	{
		vec4 mask = texture2D(s_mask, tc);

		vec4 img = texture2D(s_img, tc  * repeat);
		
		#ifdef FADEHALF
			img.a = mask.r * 0.5;
		#elif defined(FADEQUARTER)
			img.a = mask.r * 0.25;
		#else
			img.a = mask.r;
		#endif

		if (img.a < 0.1)
			discard;

		#ifdef FULLBRIGHT
			img.rgb += texture2D(s_fullbright, tc).rgb;
		#endif
		
		gl_FragColor = vec4(img * mask.r);
	}

#endif