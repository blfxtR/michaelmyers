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

setupFlashlight()
{
	self.maxbattery=100;
	self.battery=self.maxbattery;
	
	self thread flashbattery();
	self thread watchusage();
}

flashbattery()
{
	self endon("disconnect");

	self setclientdvar("mm_flash_battery",1);
	while(1)
	{
		battery=(self.battery/self.maxbattery);
		if(battery>1)
			battery=1;

		self setclientdvar("mm_flash_battery",battery+0.005);
		wait 0.5;
	}
}

watchusage()
{
	self endon("disconnect");
	self endon("death");

	while(isalive(self) && self getcurrentweapon() == "flashlight_mp")
	{
		while(!self attackbuttonpressed())
			wait .05;

		if(self attackbuttonpressed() && self getcurrentweapon() == "flashlight_mp")
		{
			if(isdefined(self.flashlight) && self.flashlight == false)
			{
				self iprintlnbold("flashlight enabled");
				self.flashlight=true;
				self thread doflashlight();
			}
			else 
			{
				self iprintlnbold("flashlight disabled");
				self.flashlight=false;

				if(isdefined(self.flash_light))
					self.flash_light delete();
			}
			wait 1;
		}
		else 
		{
			self iprintlnbold("flashlight removed");
			self.flashlight=false;

			if(isdefined(self.flash_light))
				self.flash_light delete();
		}
		wait 2;
	}
}

doFlashlight()
{
	if(isdefined(self.flash_light))
		self.flash_light delete();

	self.flash_light=spawn("script_model",(0,0,0));
	self.flash_light setmodel("tag_origin");

	self iprintlnbold("fake model created");

	wait .05;
	playfxontag(level.fx["flashlight"],self.flash_light,"tag_origin");

	self iprintlnbold("playing fx");

	self thread battery_usage();
	self thread redoflashlight();

	while( self.flashlight == true && int(self.battery) > 0 )
	{
		self.flash_light.origin = self gettagorigin("tag_inhand"); // tag_inhand ,works good but character glows
		self.flash_light.angles = self getplayerangles();

		wait 0.05;
	}
}

redoflashlight()
{
	self waittill("death");

	if(isdefined(self.flash_light))
		self.flash_light delete();
}

battery_usage()
{
	while(self.flashlight == true && int(self.battery) > 0)
	{
		self.battery -= (1+randomint(3));

		if(self.battery<=20)
			self iprintlnbold("Low Battery! "+int(self.battery)+"/ 100");

		wait 5;
	}
}

battery_spot(state)
{
	//if(!level.dvar["flashlightEnable"])
	//	return;

	if(state)
	{
		level.battery_spot=[];

		i=0;
		while(isdefined(getent("mm_battery_"+i,"targetname")))
		{
			level.battery_spot[i]=getent("mm_battery_"+i,"targetname");
			i++;
		}
		wait 1;

		for(i=0;i<level.battery_spot.size;i++)
			level.battery_spot[i] thread trigger_action();
	}
}

trigger_action()
{
	self setcursorhint("HINT_ACTIVATE");
	self waittill("trigger",who);

	if(who.pers["team"] == "allies")
	{
		who iprintlnbold("You found a Battery!");

		charge=(10+randomint(36));
		if((who.battery+charge) > 100)
			who.battery=who.maxbattery;
		else 
			who.battery += charge;
	}
	else if(who.pers["team"] == "axis")
		who iprintlnbold("You destroyed a Battery!");
	
	who mike\_rank::giverankxp("battery_pick");
	self delete();
}