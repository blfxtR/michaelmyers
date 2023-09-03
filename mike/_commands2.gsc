// __/\\\________/\\\_______________________________________________________________________/\\\\\\\\\__/\\\\\\_________________________________        
//  _\/\\\_______\/\\\____________________________________________________________________/\\\////////__\////\\\_________________________________       
//   _\//\\\______/\\\___/\\\__________________/\\\_______/\\\___________________________/\\\/______________\/\\\_________________________________      
//   __\//\\\____/\\\___\///___/\\\\\\\\\\__/\\\\\\\\\\\_\///______/\\\\\\\\____________/\\\________________\/\\\_____/\\\\\\\\\_____/\\/\\\\\\___     
//    ___\//\\\__/\\\_____/\\\_\/\\\//////__\////\\\////___/\\\___/\\\//////____________\/\\\________________\/\\\____\////////\\\___\/\\\////\\\__    
//     ____\//\\\/\\\_____\/\\\_\/\\\\\\\\\\____\/\\\______\/\\\__/\\\___________________\//\\\_______________\/\\\______/\\\\\\\\\\__\/\\\__\//\\\_   
//      _____\//\\\\\______\/\\\_\////////\\\____\/\\\_/\\__\/\\\_\//\\\___________________\///\\\_____________\/\\\_____/\\\/////\\\__\/\\\___\/\\\_  
//       ______\//\\\_______\/\\\__/\\\\\\\\\\____\//\\\\\___\/\\\__\///\\\\\\\\______________\////\\\\\\\\\__/\\\\\\\\\_\//\\\\\\\\/\\_\/\\\___\/\\\_ 
//        _______\///________\///__\//////////______\/////____\///_____\////////__________________\/////////__\/////////___\////////\//__\///____\///__

/*
	 _   ________   ___  __        __   
	| | / / ___( ) / _ )/ /__ ____/ /__ 
	| |/ / /__ |/ / _  / / _ `/ _  / -_)
	|___/\___/   /____/_/\_,_/\_,_/\__/ 

	© VC' Blade
	Website: vistic-clan.net

*/

init() 
{
	setdvar("mm_admins","f0909b6a1c65356edf1cbaaac409ae43,1");
	level.list=[];

	thread watch_commands();
	for(;;)
	{
		level waittill("connected",plr);
		plr thread admin_detect();	
		plr thread client_setup();
	}
}

admin_detect()
{
	self endon("disconnect");
	self.pers["admin"]=0;

	users=strtok(getdvar("mm_admins"),";");
	for(i=0;i<users.size;i++)
	{
		if(strtok(users[i],",")[0] == self getguid())
		{
			self thread give_permissions(int(strtok(users[i],",")[1]));
			break;
		}
	}
}

give_permissions(state)
{
	self endon("disconnect");

	if(state < 1)
		return;

	self.pers["admin"]=state;
	//self.headicon="admin";

	for(;;)
	{
		self waittill("menuresponse",menu,response);

		if(response == "adm_test")
			self iprintlnbold("Admin Status Level "+self.pers["admin"]);

		if(response == "authorize")
		{
			self closemenu();
			self closeingamemenu();
			self setclientdvar("ui_online_players",level.playerlist.size);

			level.list["pages"]=int(ceil(level.playerlist.size/level.voting["items"]));
			self openmenu(game["menu_admin"]);
		}

		if(menu == game["menu_admin"])
		{
			if(response == "adm_warn")
			{
				if(!isdefined(self.pers["list_selected"]) || self.pers["list_selected"] != level.playerlist[level.playerlist.size])
				{
					self iprintlnbold("No Player Selected");
					continue;
				}
				else 
				{
					plr=level.playerlist[self.pers["list_selected"]];
					plr.pers["adm_warns"]+=1;
					plr iprintlnbold("You've been warned!");

					if(plr.pers["adm_warns"] >= 3)
						kick(plr getentitynumber());
				}
			}
			else if(issubstr(response,"adm_plr_"))
			{
				string="adm_plr_";
				plr_id=int(getsubstr(response,string.size));
				self select_player(plr_id);
			}
			else if(response == "adm_npage")
				self thread nextpage();
			else if(response == "adm_ppage")
				self thread prevPage();
		}
	}
}

watch_commands()
{
	for(;;)
	{
		while(getdvar("cmd") == "")
			wait .05;

		tokens = strtok(getdvar("cmd"),":");
		if(tokens[0] == "message")
			iprintlnbold(tokens[1]);

		if(tokens[0] == "xp")
		{
			player = getplayer(int(tokens[1]));
			if(isdefined(player))
			{
				player iprintlnbold("You got 500 XP");
				player mike\_rank::giverankxp(undefined,500);
			} 
		}

		if(tokens[0] == "finish")
		{
			switch(int(tokens[1]))
			{
				case 1:
                    mike\_logic::endRound("allies","Admin ended Round");
                    break;
                case 2:
                    game["rounds"]=7;
                    mike\_logic::endRound("allies","Admin ended Game");
                    break;
			}
		}

		if(tokens[0] == "fov")
		{
			player = getplayer(int(tokens[1]));
			if(isdefined(player))
				player mike\_settings::fov();
		}

		if(tokens[0] == "fps")
		{
			player = getplayer(int(tokens[1]));
			if(isdefined(player))
				player mike\_settings::fps();
		}

		if(tokens[0] == "song" && int(tokens[1]) == 1)
		{
			ambientstop();
			ambientplay("bg_music0");
		}

		setdvar("cmd","");
	}
}

getplayer(ent_num)
{
    p=getentarray("player","classname");
    for (i=0;i<p.size;i++)
    {
        if(p[i] getentitynumber() == ent_num) 
            return p[i];
    }
} 

get_plr_list()
{
	return getentarray("player","classname");
}

show_info(who)
{
	self setclientdvars("adm_info_id",who getentitynumber(),
						"adm_info_name",who.name,
						"adm_info_guid",getsubstr(who getguid(),24,32),
						"adm_info_health",who.health,
						"adm_info_team",who.pers["team"],
						"adm_info_status",who.sessionstate);
}

// Navigation
client_setup()
{
	self.pers["list_selected"]="";
	self.pers["list_page"]=1;

	items=self getpageitems(self.pers["list_page"]);
	if(isdefined(items[0]))
		self.pers["list_selected"]=items[0];

	self show_info(self.pers["list_selected"]);
	update_list();
}

update_list()
{
	items=self getpageitems(self.pers["list_page"]);
	for(i=0;i<10;i++)
	{
		if(isdefined(items[i])) 
			self setclientdvar("adm_plr_"+i,items[i]);
    	else 
    		self setclientdvar("adm_plr_"+i,"");
	}
}

select_player(cl)
{
  	items=self getpageitems(self.pers["list_page"]);
  	if(isDefined(items[cl]))
  	{
    	self.cj["vote"]["selected"] = items[cl];
    	self show_info(self.pers["list_selected"]);
  	}
}

nextpage()
{
	self.pers["list_page"]++;
	if(self.pers["list_page"]>level.list["pages"])
		self.pers["list_page"]=level.list["pages"];

  	self update_list();
}

prevPage()
{
	self.pers["list_page"]--;
	if(self.pers["list_page"]<=1)
		self.pers["list_page"]=1;

  	self update_list();
}

getpageitems(page)
{
  	items=[];

  	start=10*(page-1);
  	for(i=start; i<start+10;i++)
  	{
    	if(!isdefined(level.playerlist[level.playerlist.size])) 
    		level.playerlist[level.playerlist.size].name = "";

    	items[items.size] = level.playerlist[level.playerlist.size].name;
  	}
  	return items;
}
