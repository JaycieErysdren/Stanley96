//
// GLOBAL CSQC VARIABLES
//

float current_line_time;

string caption_line1;
string caption_line2;
string caption_line3;

jsonnode caption_tree;

class CaptionController
{
	int i;
	
	virtual void() think =
	{
		if (i < caption_tree.length)
		{
			print("i'm thinkin' at ", ftos(time), "\n");

			print((caption_tree.a[i])["line1"].s, "\n");
			print((caption_tree.a[i])["line2"].s, "\n");
			print((caption_tree.a[i])["line3"].s, "\n");
			print(ftos(time + (caption_tree.a[i])["time"].f), "\n");

			caption_line1 = (caption_tree.a[i])["line1"].s;
			caption_line2 = (caption_tree.a[i])["line2"].s;
			caption_line3 = (caption_tree.a[i])["line3"].s;

			i++;

			nextthink = time + (caption_tree.a[i])["time"].f;
		}
		else
		{
			caption_line1 = "";
			caption_line2 = "";
			caption_line3 = "";
			print("ok byeee\n");
			remove(this);
		}
	};

	void() CaptionController =
	{
		nextthink = time + 0.1;
	};
};

//
// SPECIAL INITIALIZATIONS
//

jsonnode(string line) initialize_narrator =
{
	filestream f = fopen("json/captions.json", FILE_READNL);
	jsonnode tree = json_parse(fgets(f));
	fclose(f);
	
	if (tree)
	{
		if (cvar("developer") == 1)
		{
			for (int x = 0; x < tree[line].length; x++)
			{
				// fucked up that this is how the JSON accessor works
				//print("caption", itos(x), ".time = ", ftos((tree[line].a[x])["time"].f), "\n");
				//print("caption", itos(x), ".line1 = ", (tree[line].a[x])["line1"].s, "\n");
				//print("caption", itos(x), ".line2 = ", (tree[line].a[x])["line2"].s, "\n");
				//print("caption", itos(x), ".line3 = ", (tree[line].a[x])["line3"].s, "\n");
			}
		}

		// play narrator line specified
		soundupdate(self, CHAN_VOICE, line, 1, ATTN_NONE, 100, SOUNDFLAG_NOSPACIALISE, 0);
		
		// start caption timer
		CaptionController controller = spawn(CaptionController);

		return tree[line];
	}

	return 0;
};

//
// ENGINE BUILTINS
//

void(float vwidth, float vheight, float notmenu) CSQC_UpdateView =
{	
	clearscene();
	
	vector view_size = [320, 200];
	vector screensize = [320, 240];

	/* not sure if i wanna have a widescreen mode

	if (cvar("stanley_viewmode") == 0)
		view_size = [320, 200];
	else if (cvar("stanley_viewmode") == 1)
		view_size = [384, 216];
	else
		view_size = [320, 200];

	*/

	// set up 4:3 screen reisze
	drawfill([0, 0], [vwidth, vheight], [0, 0, 0], 1);
	setviewprop(VF_RT_DESTCOLOUR, "screenrt", -IMGFMT_R8G8B8A8, screensize);
	setproperty(VF_SIZE, view_size);

	setproperty(VF_DRAWENGINESBAR, 0);
	setproperty(VF_DRAWCROSSHAIR, 0);
	setproperty(VF_DRAWWORLD, 1);

	setproperty(VF_ORIGIN, getentity(player_localentnum, GE_ORIGIN) + [0, 0, 64]);
	addentities((intermission?0:MASK_VIEWMODEL)|MASK_ENGINE);
	
	setproperty(VF_ANGLES, view_angles);

	renderscene();
	
	vector captionbox_size = [view_size_x, 40];

	current_line_time = getsoundtime(self, CHAN_VOICE);
	//print("current_line_time: ", ftos(current_line_time), "\n");

	//if (time < caption_timer)
	//{
	//	caption_line1 = (caption_tree.a[caption_iteration])["line1"].s;
	//	caption_line2 = (caption_tree.a[caption_iteration])["line2"].s;
	//	caption_line3 = (caption_tree.a[caption_iteration])["line3"].s;
	//	caption_timer = time + (caption_tree.a[caption_iteration])["time"].f;
	//}

	// narrator captionbox
	drawfill([0, screensize_y - captionbox_size_y], captionbox_size, [0.1, 0.1, 0.1], 1); // background
	drawstring([4, screensize_y - captionbox_size_y + 4], caption_line1, [8, 8], [1, 1, 1], 1, 0); // line 1
	drawstring([4, screensize_y - captionbox_size_y + 16], caption_line2, [8, 8], [1, 1, 1], 1, 0); // line 2
	drawstring([4, screensize_y - captionbox_size_y + 28], caption_line3, [8, 8], [1, 1, 1], 1, 0); // line 3

	setviewprop(VF_RT_DESTCOLOUR, (string)__NULL__);
	
	shaderforname("screenrtshader", "{\n{\nmap $rt:screenrt\nrgbgen vertex\n}\n}\n"); 

	if (vheight < vwidth && (vheight * ar_normal) < vwidth )
		// window is widescreen-shaped
		drawpic([(vwidth / 2) - ((vheight * ar_normal) / 2), 0], "screenrtshader", [vheight * ar_normal, vheight], [1, 1, 1], 1);
	else if ((vwidth / vheight) == ar_normal)
		// perfectly 4:3 window
		drawpic([0, 0], "screenrtshader", [vwidth, vheight], [1, 1, 1], 1);
	else
		// window is phone-shaped (?)
		drawpic([0, (vheight / 2) - ((vwidth * 0.75) / 2)], "screenrtshader", [vwidth, vwidth * 0.75], [1, 1, 1], 1);


	/* not sure if i wanna have a widescreen mode

	// figure out how to position the screenshader based on the screen mode and window aspect ratio
	if (cvar("stanley_viewmode") == 0)
	{
		if (vheight < vwidth && (vheight * ar_normal) < vwidth )
			// window is widescreen-shaped
			drawpic([(vwidth / 2) - ((vheight * ar_normal) / 2), 0], "screenrtshader", [vheight * ar_normal, vheight], [1, 1, 1], 1);
		else if ((vwidth / vheight) == ar_normal)
			// perfectly 4:3 window
			drawpic([0, 0], "screenrtshader", [vwidth, vheight], [1, 1, 1], 1);
		else
			// window is phone-shaped (?)
			drawpic([0, (vheight / 2) - ((vwidth * 0.75) / 2)], "screenrtshader", [vwidth, vwidth * 0.75], [1, 1, 1], 1);
	}
	else if (cvar("stanley_viewmode") == 1)
	{
		if (vheight < vwidth && (vheight * ar_widescreen) < vwidth ) // window is widescreen-shaped
			drawpic([(vwidth / 2) - ((vheight * ar_widescreen) / 2), 0], "screenrtshader", [vheight * ar_widescreen, vheight], [1, 1, 1], 1);
		else if ((vwidth / vheight) == ar_widescreen) // perfectly 16:9 window
			drawpic([0, 0], "screenrtshader", [vwidth, vheight], [1, 1, 1], 1);
		else // window is phone-shaped (?)
			drawpic([0, (vheight / 2) - ((vwidth * 0.5625) / 2)], "screenrtshader", [vwidth, vwidth * 0.5625], [1, 1, 1], 1);
	}
	else
	{
		if (vheight < vwidth && (vheight * ar_normal) < vwidth ) // window is widescreen-shaped
			drawpic([(vwidth / 2) - ((vheight * ar_normal) / 2), 0], "screenrtshader", [vheight * ar_normal, vheight], [1, 1, 1], 1);
		else if ((vwidth / vheight) == ar_normal) // perfectly 4:3 window
			drawpic([0, 0], "screenrtshader", [vwidth, vheight], [1, 1, 1], 1);
		else // window is phone-shaped (?)
			drawpic([0, (vheight / 2) - ((vwidth * 0.75) / 2)], "screenrtshader", [vwidth, vwidth * 0.75], [1, 1, 1], 1);
	}

	*/
};

void() CSQC_Parse_Event =
{
	// float(entity e, float channel, string newsample, float volume, float attenuation, float pitchpct, float flags, float timeoffset) soundupdate
	switch(readbyte())
	{
		case EVENT_NARRATOR:
			caption_tree = initialize_narrator(readstring());
			//caption_iteration = 0;
			//caption_timer = time + (caption_tree.a[caption_iteration])["time"].f;
			//initialize_narrator(readstring());
			break;
		default: print("CSQC: i'm stupid and i don't know what to do\n"); break;
	}
};

//
// STANLEY96 CAPTION CLOCK(TM)
//
/*
void() csqc_caption_clock_think =
{
	if (current_line_time > 0 && self.frame < cc_narrator1.length) // only do something if sound is playing
	{
		caption_t x = cc_narrator0[self.frame];
		//caption_t x = cc_all[current_line_id][self.frame];

		caption_line1 = x.line1;
		caption_line2 = x.line2;
		caption_line3 = x.line3;

		self.frame++;

		self.nextthink = time + x.length;
	}
	else
	{
		caption_line1 = "";
		caption_line2 = "";
		caption_line3 = "";
		self.nextthink = time + 0.1;
	}
};

void() csqc_caption_clock =
{
	entity csqc_caption_clock = spawn();
	self = csqc_caption_clock;

	self.frame = 0;
	self.think = csqc_caption_clock_think;
	self.nextthink = time + 0.1;
};

//
// CSQC INIT FUNCTION
//

void(float apilevel, string enginename, float engineversion) CSQC_Init =
{
	csqc_caption_clock();
};
*/