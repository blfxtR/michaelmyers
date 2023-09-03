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
	level.voting_enabled=true;

	rot=strtok(getdvar("sv_maprotation")," ");
	level.maps=[];
	for(i=0;i<rot.size;i++)
	{
		if(rot[i] != "map")
			level.maps[level.maps.size]=rot[i];

		wait .05;
	}

	if(level.maps.size < 3)
	{
		println("ERROR; Map Rotation is not big enough!");
		level.voting_enabled=false;

		return;
	}
}

start_voting()
{
	level.vote_items=[];

	if(!level.voting_enabled)
		return;

	level.vote_items[0]="";
	level.vote_items[1]="";
	level.vote_items[2]="";

	inuse="";
	for(i=0;i<3;i++)
	{
		found="";
		choosing=false;
		while(!choosing)
		{
			found=level.maps[randomint(level.maps.size)];
			if(!issubstr(inuse,found) && found != getdvar("mapname"))
			{
				inuse += found;
				choosing=true;
			}
			wait .05;
		}

		if(choosing == true)
			level.vote_items[i]=found;
		
		wait .05;
	}

	level.votes[0]=0;
	level.votes[1]=0;
	level.votes[2]=0;

	level.voteinprogress=true;

	level.players=getentarray("player","classname");
	for(i=0;i<level.players.size;i++)
	{
		plr=level.players[i];

		plr setclientdvars("vote_item_0",level.vote_items[0],
							"vote_item_1",level.vote_items[1],
							"vote_item_2",level.vote_items[2],
							"vote_0",level.votes[0],
							"vote_1",level.votes[1],
							"vote_2",level.votes[2]);

		wait .05;

		plr thread update_dvars();
		plr thread vote_response();

		plr.last_vote=3;
		wait .05;

		plr openmenu(game["menu_vote"]);
	}
	level thread vote_timer(level.dvar["voteTime"]);
}

vote_timer(time)
{
	for(i=0;i<time;i++)
	{
		level.vote_timer=(time-i);
		wait 1;
	}
	level.vote_timer=0;
	wait .05;
	level.voteinprogress=false;
}

update_dvars()
{
	while(isdefined(level.voteinprogress) && level.voteinprogress == true)
	{
		self setclientdvars("vote_item_0",mike\_maps::getmapname(level.vote_items[0]),
							"vote_item_1",mike\_maps::getmapname(level.vote_items[1]),
							"vote_item_2",mike\_maps::getmapname(level.vote_items[2]),
							"vote_0",level.votes[0],
							"vote_1",level.votes[1],
							"vote_2",level.votes[2],
							"vote_timer",level.vote_timer);

		wait .05;
	}
}

set_winning_map()
{
	winner=level.votes[0];
	num=0;
	for(i=0;i<level.vote_items.size;i++)
	{
		if(level.votes[i] > winner)
		{
			winner=level.votes[i];
			num=i;
		}
	}
	return level.vote_items[num];
}

change_map(map)
{
	setdvar("sv_maprotationcurrent","gametype mike map "+map);
	exitlevel(false);
}

//===================================================
// ### Menu Sided Scripts
vote_response()
{
	self closemenu();
	self closeingamemenu();

	for(;;)
	{
		self waittill("menuresponse",menu,response);
		if(menu==game["menu_vote"])
			vote_map(response);
	}
}

vote_map(response)
{ 
	if(isdefined(level.voteinprogress) && level.voteinprogress == true)
	{
		switch(response)
		{
			case "0":
				if(self.last_vote!=0)
				{
					level.votes[self.last_vote]-=1;
					level.votes[0]+=1;
					self.last_vote=0;
				}
				break;

			case "1":
				if(self.last_vote!=1)
				{
					level.votes[self.last_vote]-=1;
					level.votes[1]+=1;
					self.last_vote=1;
				}
				break;

			case "2":
				if(self.last_vote!=2)
				{
					level.votes[self.last_vote]-=1;
					level.votes[2]+=1;
					self.last_vote=2;
				}
				break;
		}
	}
}