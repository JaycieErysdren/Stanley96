//
// achievements.qc
//

void() clear_achievements =
{
	float success = fremove("achievements.dat");
	
	if (success == 0)
		print("Successfully cleared achievement data.\n");
	else
		print("Could not clear achievement data.\n");
};

jsonnode(string id) initialize_achievement =
{
	if (cvar("achievement_enable") <= 0)
		return 0;

	filestream f = fopen("achievements.dat", FILE_READ);

	if (f > 0)
	{
		string line;

		while ((line = fgets(f)))
		{
			tokenizebyseparator(line, ",");

			if (argv(0) == id)
			{
				//print("you already have this achievement, silly!\n");
				fclose(f);
				return 0;
			}
		}

		fclose(f);
	}

	filestream j = fopen("json/achievements.json", FILE_READNL);
	jsonnode tree = json_parse(fgets(j));
	fclose(j);

	if (tree && tree[id]["title"].s != "")
	{
		filestream w = fopen("achievements.dat", FILE_APPEND);

		if (w > 0)
		{
			if (has_achievements == 0)
				fputs(w, strcat(id, ",", strftime(1, "%Y-%m-%d %H:%M")));
			else
				fputs(w, strcat("\n", id, ",", strftime(1, "%Y-%m-%d %H:%M")));

			fclose(w);
		}

		has_achievements = 1;

		float displaytime = cvar("achievement_display_time");

		if (displaytime <= 0)
			return 0;
		else
		{
			achievement_timer = time + displaytime;
			achievementbox_ypos = -16 * cvar("accessibility_resolution_scale");

			return tree[id];
		}

	}

	return 0;
};
