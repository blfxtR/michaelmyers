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

loadout()
{
	self detachall();
	self takeallweapons();
	self clearperks();

	if(self.pers["team"]=="allies")
	{
		self giveweapon("flashlight_mp");
		self setspawnweapon("flashlight_mp");

		self setmodel(level.hidermodels[randomint(8)]["model"]);
		self setviewmodel("viewmodel_hands_zombie");
	}
	else 
	{
		self giveweapon("axe_mp");
		self setspawnweapon("axe_mp");

		self setmodel("myers");
		self setviewmodel("viewmodel_hands_zombie");

		self setperk("specialty_longersprint");
		self setperk("specialty_quieter");
	}
}

health()
{
	if(self.pers["team"]=="allies")
		self.maxhealth=100;
	else 
		self.maxhealth=300;

	self.health=self.maxhealth;
}

speed()
{
	if(self.pers["team"]=="allies")
		self setmovespeedscale(1.0);
	else 
	{
		if(mike\_common::get_allies_players().size > 3)
			self setmovespeedscale(self get_speed());
		else 
			self setmovespeedscale(1.05);
	}
}

get_speed()
{
	speed=1.05;
	plr=getentarray("player","classname");
	for(i=0;i<plr.size;i++)
	{
		if(isdefined(plr[i].pers["team"]) && plr[i].pers["team"] == "allies")
			speed += 0.01;
	}
	iprintlnbold("Michaels Speed: "+speed);
	
	return speed;
}

createknifes()
{
	level.hiderknifes=[];
	table="mp/knifetable.csv";

	for(idx=1;isdefined(tablelookup(table,0,idx,0)) && tablelookup(table,0,idx,0)!="";idx++)
	{
		id=int(tablelookup(table,0,idx,1));
		level.hiderknifes[id]["level"]=(int(tablelookup(table,0,idx,2))-1);
		level.hiderknifes[id]["knife"]=(tablelookup(table,0,idx,3));
		level.hiderknifes[id]["name"]=tablelookup(table,0,idx,4);

		precacheitem(level.hiderknifes[id]["knife"]);
	}
}

createmodels()
{
	level.hidermodels=[];
	table="mp/modeltable.csv";

	for(idx=1;isdefined(tablelookup(table,0,idx,0)) && tablelookup(table,0,idx,0)!="";idx++)
	{
		id=int(tablelookup(table,0,idx,1));
		level.hidermodels[id]["level"]=(int(tablelookup(table,0,idx,2))-1);
		level.hidermodels[id]["model"]=(tablelookup(table,0,idx,3));
		level.hidermodels[id]["name"]=tablelookup(table,0,idx,4);

		precachemodel(level.hidermodels[id]["model"]);
	}
}