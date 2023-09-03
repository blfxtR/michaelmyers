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

vanillacod()
{
	level.splitscreen=issplitscreen();
	level.xenon=false;
	level.ps3=false;
	level.onlinegame=true;
	level.console=false;
	level.rankedmatch=getdvarint("sv_pure");
	level.teambased=true;
	level.oldschool=false;
	level.gameended=false;
}

init_spawns()
{
	level.spawn = [];
	level.spawn["axis"] = getEntArray( "mp_dm_spawn", "classname" );
	level.spawn["allies"] = getEntArray( "mp_tdm_spawn", "classname" );
	level.spawn["spectator"] = getEntArray( "mp_global_intermission", "classname" )[0];

	if(getEntArray( "mp_global_intermission", "classname" ).size>0)
		level.spawn["spectator"]=getEntArray( "mp_global_intermission", "classname" )[0];
	else
		level.spawn["spectator"]=getentarray("mp_dm_spawn","classname")[0];
}

required_amount(value)
{
	done=false;
	while(!done)
	{
		wait .5;
		count=0;
		p=getentarray("player","classname");
		for(i=0;i<p.size;i++)
		{
			if(p[i].sessionstate == "playing")
				count++;
		}
		if(count >= value)
			break;
	}
}

setteam(team)
{
	if( self.pers["team"] == team )
		return;

	if(isalive(self))
		self suicide();
	
	self.pers["weapon"] = "none";
	self.pers["team"] = team;
	self.team = team;
	self.sessionteam = team;

	menu = game["menu_team"];
	if( team == "allies" )
	{
		self.pers["weapon"] = "hands_mp";
	}
	else if( team == "axis" )
	{
		self.pers["weapon"] = "knife_mp";
	}
	self setClientDvars( "g_scriptMainMenu", menu );
}

blackscreen()
{
	if(isdefined(self.blackscreen))	
		self.blackscreen destroy();

	self.blackscreen=newclienthudelem(self);
	self.blackscreen.x=0;
	self.blackscreen.y=0;
	self.blackscreen.alpha=1;
	self.blackscreen.sort=3;
	self.blackscreen.alignx="left";
	self.blackscreen.aligny="top";
	self.blackscreen.vertalign="fullscreen";
	self.blackscreen.horzalign="fullscreen";
	self.blackscreen.foreground=0;
	self.blackscreen.hidewheninmenu=false;
	self.blackscreen.archived=0;
	self.blackscreen setshader("white",640,480);
	self.blackscreen.color=(0,0,0);

	level waittill("hide_done");

	if(isdefined(self.blackscreen))	
		self.blackscreen destroy();
}

spectateperms()
{
	self allowSpectateTeam( "allies", true );
	self allowSpectateTeam( "axis", true );
	self allowSpectateTeam( "none", false );
}

delayStartRagdoll( ent, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath )
{
	if ( isDefined( ent ) )
	{
		deathAnim = ent getcorpseanim();
		if ( animhasnotetrack( deathAnim, "ignore_ragdoll" ) )
			return;
	}
	
	wait( 0.2 );
	
	if ( !isDefined( vDir ) )
		vDir = (0,0,0);
	
	explosionPos = ent.origin + ( 0, 0, getHitLocHeight( sHitLoc ) );
	explosionPos -= vDir * 20;
	//thread debugLine( ent.origin + (0,0,(explosionPos[2] - ent.origin[2])), explosionPos );
	explosionRadius = 40;
	explosionForce = .75;
	if ( sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_EXPLOSIVE" || isSubStr(sMeansOfDeath, "MOD_GRENADE") || isSubStr(sMeansOfDeath, "MOD_PROJECTILE") || sHitLoc == "object" || sHitLoc == "helmet" )
	{
		explosionForce = 2.9;
	}
	ent startragdoll( 1 );
	
	wait .05;
	
	if ( !isDefined( ent ) )
		return;
	
	// apply extra physics force to make the ragdoll go crazy
	physicsExplosionSphere( explosionPos, explosionRadius, explosionRadius/2, explosionForce );
	return;
}

getHitLocHeight(sHitLoc)
{
	switch(sHitLoc)
	{
		case "helmet":
		case "head":
		case "neck": return 60;
		case "torso_upper":
		case "right_arm_upper":
		case "left_arm_upper":
		case "right_arm_lower":
		case "left_arm_lower":
		case "right_hand":
		case "left_hand":
		case "gun": return 48;
		case "torso_lower": return 40;
		case "right_leg_upper":
		case "left_leg_upper": return 32;
		case "right_leg_lower":
		case "left_leg_lower": return 10;
		case "right_foot":
		case "left_foot": return 5;
	}
	return 48;
}

reportglitch()
{
	ori=self getorigin();
	ang=self getplayerangles();

	self iprintlnbold("Take a Screenshot for Blade");
	self iprintlnbold("Map: ^1"+getdvar("mapname"));
	self iprintlnbold("("+ori[0]+","+ori[1]+","+ori[2]+");("+ang[0]+","+ang[1]+","+ang[2]+")");
}

get_allies_players()
{
	p=[];
	plr=getentarray("player","classname");
	for(i=0;i<plr.size;i++)
	{
		if(isdefined(plr[i].pers["team"]) && plr[i].pers["team"] == "allies")
			p[p.size]=plr[i];
	}
	return p;
}