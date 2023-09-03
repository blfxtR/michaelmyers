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
	if(self.pers["team"] == "axis") // Only for Michael
	{
		self giveweapon("c4_mp");
		self setactionslot(1,"weapon","c4_mp");
		self thread watchusage();
	}
}

watchusage()
{
	self endon("disconnect");
	self endon("death");

 	for(;;)
 	{
 		if(isdefined(self) && isdefined(self getCurrentWeapon()))
 		{
 			if(self getcurrentweapon() == "c4_mp" && !self.flashlight)
	 		{
	 			self.flashlight=true;
	 			wait .4;
	 			self switchtoweapon("knife_mp");
	 			self takeweapon("c4_mp");
	 			self thread doflashlight();
	 		}
 		}
 		wait .05;
 	}
}

doflashlight()
{
	if(isdefined(self.flash_light) || self.pers["team"] != "axis")
		return;

	self.flash_light=spawn("script_model",self gettagorigin("j_spinelower"));
	self.flash_light setmodel("tag_origin");

	wait .05;

	playfxontag(level.fx["flashlight"],self.flash_light,"tag_origin");
	self.flash_light linkto( self );
	self thread redoflashlight();

	wait 15;

	if(isdefined(self.flash_light))
	{
		self.flash_light unlink();
		self.flash_light delete();
	}

	self thread flashlight_cooldown();
}

redoflashlight()
{
	self waittill("death");

	if(isdefined(self.flash_light))
	{
		self.flash_light unlink();
		self.flash_light delete();
	}	

	if(isdefined(self.flashlight_delay))
		self.flashlight_delay destroy();
}

flashlight_cooldown()
{
	self.flashlight_delay=mike\_logic::createhud(self,-5,60,"right","middle","default",1.5,undefined,(1,0,0)); // Replace text with flashlight icon + add timer to icon :>
	self.flashlight_delay.hidewheninmenu=true;
	self.flashlight_delay.label=&"Charge\n&&1";
	self.flashlight_delay settimer(level.flashlightDelay);

	wait level.flashlightDelay;

	if(isdefined(self.flashlight_delay))
		self.flashlight_delay destroy();

	self giveweapon("c4_mp");
	self setactionslot(1,"weapon","c4_mp");

	wait .05;

	self.flashlight=false;
}
