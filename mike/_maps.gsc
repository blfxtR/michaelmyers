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
	level.glitch_spots=[];

	switch(getdvar("mapname"))
	{
		case "mp_crash":
		case "mp_crash_snow":
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((1793,1084,590),30,400);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((1301,167,488),30,400);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((654,-855,392),20,92);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((666,-838,441),20,92);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((179,-780,448),50,92);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((685,-746,437),50,92);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((1370,-1343,350),22,120);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((-339,898,383),50,200);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((-339,963,383),50,200);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((-339,1028,383),50,200);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((1180,1424,411),100,400);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((1072,1341,2100),30,100);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((1687,650,700),10,50);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((225,550,450),50,100);
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((-17.0276,-1015.46,370.125),47,100);		
			break;
		case "mp_b12_v2":
			level.glitch_spots[level.glitch_spots.size]=add_glitchspot((991.125,-425.603,91.1963),5,100);
			break;
	}
}

add_glitchspot(t,w,h)
{
	spot=spawn("trigger_radius",t,0,w,h);
	spot setcontents(1);
	spot.targetname="script_collision";

	return spot;
}

fogpreseted(map)
{
	switch(map)
	{
		case "mp_crash":
		case "mp_crossfire":
		case "mp_shipment":
		case "mp_convoy":
		case "mp_bloc":
		case "mp_bog":
		case "mp_broadcast":	
		case "mp_carentan":		
		case "mp_countdown":	
		case "mp_crash_snow":
		case "mp_creek":	
		case "mp_citystreets":
		case "mp_farm":
		case "mp_killhouse":
		case "mp_overgrown":
		case "mp_pipeline":
		case "mp_showdown":
		case "mp_strike":
		case "mp_vacant":	
		case "mp_cargoship":
		case "mp_backlot":
		case "mp_nuketown":
		case "mp_highrise":
		case "mp_b12_v2":
			return true;
	}
	return false;
}

getmapname(map)
{
	tokens=strtok(map,"_");
	if(!tokens.size)
		return map;

	return (getletters(tokens[1]));
}

getletters(string)
{
	if(!isDefined(string))
		return;
	abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	abcklein = "abcdefghijklmnopqrstuvwxyz";
	for(i=0;i<abc.size;i++)
	{
		if(string[0] == abcklein[i])
		{
			string = abc[i] + getSubStr(string,1,string.size);
			return string;
		}
	}
	return string;
}