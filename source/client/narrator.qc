//
// narrator.qc
//

jsonnode(string line) initialize_narrator =
{
	filestream j = fopen("json/captions.json", FILE_READNL);
	jsonnode tree = json_parse(fgets(j));
	fclose(j);
	
	if (tree)
	{
		// play narrator line specified
		//soundupdate(self, CHAN_VOICE, line, 1.0, ATTN_NONE, 100, 0, 0);
		//current_line_sample = line;
		localsound(line, CHAN_VOICE, cvar("volume"));
		caption_iteration = 0;
		caption_timer = time + 0.1;

		return tree[line];
	}

	return 0;
};