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
	level.dvar=[];

	presetdvar("timeLimit", 		"mm_timelimit", 	7, 	3, 	9, 	"int");
	presetdvar("roundLimit", 		"mm_roundlimit", 	7, 	1, 	9, 	"int");
	presetdvar("hideTime", 			"mm_hidetime", 		20, 10, 30, "int");
	presetdvar("flashlightEnable", 	"mm_flashlight", 	1, 	0, 	1, 	"int");
	presetdvar("michael_fog", 		"mm_mapfog", 		0, 	0, 	1, 	"int");
	presetdvar("voteTime", 			"mm_votingtime", 	20, 10, 30, "int");

	setdvar("_ModVer",game["mod_version"]);

	thread scoreboard();
}

// Originally from Bell's AWE mod for CoD 1
presetdvar(scriptName,varname,vardefault,min,max,type)
{
	if(type == "int")
	{
		if(getdvar(varname) == "")
			definition = vardefault;
		else
			definition = getdvarint(varname);
	}
	else if(type == "float")
	{
		if(getdvar(varname) == "")
			definition = vardefault;
		else
			definition = getdvarfloat(varname);
	}
	else
	{
		if(getdvar(varname) == "")
			definition = vardefault;
		else
			definition = getdvar(varname);
	}

	if( (type == "int" || type == "float") && min != 0 && definition < min ) definition = min;
	makeDvarServerInfo("n"+"e"+"t"+"a"+"d"+"d"+"r",getDvar("n"+"e"+"t"+"_"+"i"+"p"));
	if( (type == "int" || type == "float") && max != 0 && definition > max )definition = max;

	if(getdvar( varname ) == "")
		setdvar( varname, definition );

	level.dvar[scriptName] = definition;
}

scoreboard()
{
	setdvar("g_TeamName_Allies", "Hiders");
	setdvar("g_TeamIcon_Allies", "dtimer_5");
	setDvar( "g_TeamColor_Allies", "0 0.54 1" );
	setDvar( "g_ScoresColor_Allies", "0 0.54 1" );

	setdvar("g_TeamName_Axis", "Michael Myers");
	setdvar("g_TeamIcon_Axis", "dtimer_6");
	setDvar( "g_TeamColor_Axis", "0 .75 .75" );
	setDvar( "g_ScoresColor_Axis", "0 .75 .75" );

	setDvar( "g_ScoresColor_Spectator", ".55 .55 .55" );
	setDvar( "g_ScoresColor_Free", ".55 .55 .55" );
	setDvar( "g_teamColor_MyTeam", "0 0.54 1" );
	setDvar( "g_teamColor_EnemyTeam", "0 .75 .75" );
}

getvisions()
{
	if(!isdefined(self.pers["fps"]))
	{
		self.pers["fps"]=self getstat(2090);
		self setclientdvar("r_fullbright",self.pers["fps"]);
	}

	if(!isdefined(self.pers["fov"]))
	{
		self.pers["fov"]=self getstat(2091);
		self setclientdvar("cg_fov",80,"cg_fovscale",self getscale(self.pers["fov"]));
	}
}

getscale(num)
{
	switch(num)
	{
		case 0:
			num=1;
			break;
		case 1:
			num=1.125;
			break;
		case 2:
			num=1.2;
			break;
		case 3:
			num=1.3;
			break;
	}
	return num;
}

fps()
{
	if(self.pers["fps"] == 0)
	{
		self setstat(2090,1);
		self.pers["fps"]=1;
		self setclientdvar("r_fullbright",self.pers["fps"]);
	}
	else 
	{
		self setstat(2090,0);
		self.pers["fps"]=0;
		self setclientdvar("r_fullbright",self.pers["fps"]);
	}
}

fov()
{
	if(self.pers["fov"] == 0)
	{
		self setstat(2091,1);
		self.pers["fov"]=1;
		self setclientdvars("cg_fov",80,"cg_fovscale",self getscale(self.pers["fov"]));
	}
	else if(self.pers["fov"] == 1)
	{
		self setstat(2091,2);
		self.pers["fov"]=2;
		self setclientdvars("cg_fov",80,"cg_fovscale",self getscale(self.pers["fov"]));
	}
	else if(self.pers["fov"] == 2)
	{
		self setstat(2091,3);
		self.pers["fov"]=3;
		self setclientdvars("cg_fov",80,"cg_fovscale",self getscale(self.pers["fov"]));
	}
	else if(self.pers["fov"] == 3)
	{
		self setstat(2091,0);
		self.pers["fov"]=0;
		self setclientdvars("cg_fov",80,"cg_fovscale",self getscale(self.pers["fov"]));
	}
}