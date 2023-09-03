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
	game["menu_team"] = "team_select";
	game["menu_knifes"] = "knife_select";
	game["menu_vote"] = "voting";
	game["menu_admin"] = "admin_menu";

	precacheMenu("scoreboard");
	precacheMenu(game["menu_team"]);
	precacheMenu(game["menu_knifes"]);
	precacheMenu(game["menu_vote"]);
	precacheMenu(game["menu_admin"]);
	
	precacheString( &"MP_HOST_ENDED_GAME" );
	precacheString( &"MP_HOST_ENDGAME_RESPONSE" );

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		
		player setClientDvar("ui_3dwaypointtext", "1");
		player.enable3DWaypoints = true;
		player setClientDvar("ui_deathicontext", "1");
		player.enableDeathIcons = true;
		player.classType = undefined;
		player.selectedClass = false;
		
		player thread mike\_settings::getvisions();
		player thread onMenuResponse();
	}
}

onMenuResponse()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("menuresponse", menu, response);

		if(response=="back")
		{
			self closemenu();
			self closeingamemenu();
			continue;
		}	

		if(response == "fullbright")
			self mike\_settings::fps();
		else if(response == "fieldofview")
			self mike\_settings::fov();
		else if(response == "glitchfound")
			self mike\_common::reportglitch();
		else if(response == "test")
			self openmenu(game["menu_admin"]);
			
		if( menu == game["menu_team"] )
		{
			self closemenu();
			self closeingamemenu();

			if(self.pers["team"] == "axis")
			{
				self iprintlnbold("Michael cant switch Teams!");
				continue;
			}
			else 
			{
				switch(response)
				{
					case "allies":
					case "axis":
					case "autoassign":
						self mike\_common::setteam( "allies" );
						if(self.sessionstate == "playing" || game["state"] == "round ended" )
							continue;
							
						if( game["state"] == "readyup")
							self mike\_logic::spawnPlayer();
						break;

					case "spectator":
						self mike\_common::setteam( "spectator" );
						self mike\_logic::spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
						break;
				}
			}
		}
		else if(menu == game["menu_knifes"])
		{
			self closemenu();
			self closeingamemenu();

			knife=int(response)-1;
			if(knife >= level.hiderknifes.size || knife <= -1)
				continue;

			if(self.pers["rank"] >= level.hiderknifes[knife]["level"])
			{
				self iprintlnbold("You selected ^1"+level.hiderknifes[knife]["name"]);
				self setstat(666,knife);
			}
		}
		else if(menu == game["menu_quickcommands"])
			self thread quickcommands(response);
	}
}

quickcommands(response)
{
	self endon("disconnect");
	
	if(!isdefined(self.pers["team"]) || self.pers["team"]=="spectator" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;
	
	switch(response)		
	{
		case "1":
			saytext = "^5Follow Me!";
			break;
		case "2":
			saytext = "^5Keep Quiet!";
			break;
		case "3":
			saytext = "^5Michael is close!";
			break;
		case "4":
			saytext = "^5Contact! Michael is here!";
			break;
		case "5":
			saytext = "^5Roger.";
			break;
		default:
			assert(response == "6");
			saytext = "^5Negative.";
			break;
	}
	self doQuickMessage(saytext);
	wait 2;
	self.spamdelay = undefined;
}

doQuickMessage(saytext)
{
	if(self.sessionstate != "playing")
		return;

	self sayteam(saytext);
}