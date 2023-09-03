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
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	mike\_common::vanillacod();
	mike\_common::init_spawns();

	level.fx=[];
	level.fx["flashlight"]=loadfx("effects/flashlight");
	level.fx["glowstick"]=loadfx("effects/glowstick");

	level.tempEntity = spawn( "script_model", (0,0,0) );
	level.playerlist=[];

	game["mod_version"]=0.3;

	precacheitem("knife_mp");
	precacheitem("g36c_gl_mp");
	precacheitem("axe_mp");
	precacheitem("flashlight_mp");

	precacheshader("white");
	precacheshader("black");
	precacheshader("dtimer_0");
	precacheshader("dtimer_1");
	precacheshader("dtimer_2");
	precacheshader("dtimer_5");
	precacheshader("dtimer_6");
	precacheshader("stance_prone");

	precacheStatusIcon( "hud_status_connecting" );
	precacheStatusIcon( "hud_status_dead" );

	precachemodel("viewmodel_hands_zombie");
	precachemodel("myers");
	precacheModel("tag_origin");
	precachemodel("knife_bowie");
	precachemodel("knife_huntsman");
	precachemodel("knife_m9bayonet");

	if(getdvar("last_mike") == "")
		setdvar("last_mike","last_"+randomint(255));
	
	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_hud_message::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_clientids::init();
	thread maps\mp\gametypes\_gameobjects::init();
	thread maps\mp\gametypes\_spawnlogic::init();
	thread maps\mp\gametypes\_oldschool::deletePickups();
	thread maps\mp\gametypes\_quickmessages::init();

	if(!isdefined(game["rounds"]))
		game["rounds"]=1;

	game["roundStarted"]=false;
	game["state"]="readyup";

	level.humans=0;
	level.michael=0;
	level.michael_killed=false;
	level.michael_afk=false;

	setDvar( "jump_slowdownEnable", 1 ); // Slows players so they cant strafe away from mike, even tho hes faster (huehue)
	setDvar( "bullet_penetrationEnabled", 0 );
	setDvar( "g_playerCollisionEjectSpeed", 1 );

	thread mike\_items::createknifes();
	thread mike\_items::createmodels();

	thread mike\_menus::init();
	thread mike\_settings::init();
	thread mike\_rank::init();
	thread mike\_bots::init();
	thread mike\_commands::init();
	thread mike\_voting::init();
	thread mike\_maps::init();

	thread gameLogic();
	thread playerCount();
	thread bg_music();
}

bg_music() // Creepy BG Music
{
	i=0;
	while(1)
	{
		ambientstop(2);
		ambientplay("bg_music"+i,2);
		i++;

		if(i>5)
			i=0;

		wait 120+randomint(60);
	}
}

gameLogic()
{
	level endon("endround");
	waittillframeend;

	visionsetnaked("mpIntro",0);

	if(isdefined(level.matchStartText)) level.matchStartText destroy();

	wait 0.2;

	level.matchstarttext=createhud(level,0,-3,"center","bottom","default",1.4,(1,0,0));
    level.matchStartText.foreground = true;
 	level.matchStartText.hidewheninmenu = true;
 	level.matchStartText settext("Waiting for more Players to start the Round...");

	mike\_common::required_amount(2);
	selecttimer();

	level notify( "round_started", game["roundsplayed"] );
	game["state"] = "playing";
	game["roundStarted"] = true;

	visionsetnaked(getdvar("mapname"),2);
	thread after_round_start();

	level.mm_alive=undefined;
	while( game["state"] == "playing" )
	{
		wait 0.1;

		level.human=[];
		level.humans=0;
		level.michael=0;

		p=getentarray("player","classname");
		if(p.size>0)
		{
			for(i=0;i<p.size;i++)
			{
				if(isdefined(p[i].pers["team"]))
				{
					if(p[i].pers["team"]=="allies" && p[i].sessionstate == "playing")
					{
						level.human[level.human.size]=p[i];
						level.humans++;
					}
					else if(p[i].pers["team"]=="axis" && p[i].sessionstate == "playing")
						level.michael++;
				}
			}		
		}	

		if(!isdefined(level.mm_alive))
			level.mm_alive=level.humans;

		if(level.humans>1 && !level.michael && !level.michael_killed)
		{
			selectMichael();
			continue;
		}

		if(level.mm_alive>=3 && level.humans==1)
			level.human[0] thread last_alive_bonus(1);

		if(!level.humans && level.michael)
			thread endRound("axis","All Hiders died!");
		else if(level.humans && !level.michael)
			thread endRound("allies","Michael Myers died!");
		else if(!level.humans && !level.michael)
			thread endRound("axis","No one left!");
	}
}

after_round_start()
{
	players=getentarray("player","classname");
	for(i=0;i<players.size;i++)
	{
		if(players[i].sessionstate == "playing")
		{
			players[i] unLink();
			players[i] enableWeapons();
		}
	}
}

selecttimer()
{
	if(isdefined(level.matchStartText))
		level.matchStartText destroy();

	icon=createhud(level,0,-140,"center","middle"); // 0
	icon.alpha=0.7;
	icon.hidewheninmenu=true;
	icon setshader("dtimer_6",64,64);

	timer=createhud(level,0,-100,"center","middle","objective",1.5,(1,0,0)); // 40
	timer.hidewheninmenu=true;
	timer settenthstimer(5);

	text=createhud(level,0,-185,"center","middle","default",1.5,undefined,(1,0,0)); // -45
	text.hidewheninmenu=true;
	text settext("Choosing Michael");

	wait 5.5;

	icon destroy();
	timer destroy();
	text destroy();
}

createhud(what,x,y,alignx,aligny,font,scale,color,glow)
{
	if(isplayer(what))
		hud=newclienthudelem(what);
	else 
		hud=newhudelem();
	hud.alignx=alignx;
	hud.aligny=aligny;
	hud.horzalign=alignx;
	hud.vertalign=aligny;
	hud.x=x;
	hud.y=y;

	if(isdefined(font))
		hud.font=font;

	if(isdefined(scale))
		hud.fontscale=scale;

	if(isdefined(color))
		hud.color=color;

	if(isdefined(glow))
	{
		hud.glowalpha=1;
		hud.glowcolor=glow;
	}

	return hud;
}

spawnPlayer()
{
	self endon("disconnect");

	if(game["state"]=="endmap")
		return;

	self.team=self.pers["team"];
	self.sessionteam=self.team;
	self.sessionstate="playing";
	self.spectatorclient=-1;
	self.killcamentity=-1;
	self.archivetime=0;
	self.psoffsettime=0;
	self.statusicon="";
	
	spot=level.spawn[self.pers["team"]][randomInt(level.spawn[self.pers["team"]].size)];
	self spawn(spot.origin,spot.angles);

	self mike\_items::loadout();
	self mike\_items::health();
	self mike\_items::speed();

	self.pers["weapon"]=level.hiderknifes[self getstat(666)]["knife"];

	self thread after_spawn();

	self notify( "spawned_player" );
	level notify( "player_spawn", self );
}

after_spawn()
{
	self endon("disconnect");
    self endon("death");
	waittillframeend;

	if(self.sessionstate != "playing")
		return;

	if(game["state"] == "readyup")
	{
		self linkTo( level.tempEntity );
		self disableWeapons();
	}

	if(self.pers["team"] == "allies")
	{
		self thread still_alive();
		self thread health_regeneration();

		//if(level.dvar["flashlightEnable"])
			self thread mike\_flashlight::setupFlashlight();
	}
	else 
		self thread anti_afk();
}

still_alive()
{
	if(self.sessionstate != "playing" || self.pers["team"] != "allies")
		return;

	level waittill("hide_done");

	while(isalive(self) && self.pers["team"] == "allies")
	{
		wait 30;
		self mike\_rank::giverankxp("still_alive");
	}
}

health_regeneration()
{
	self endon("death");

	if(self.sessionstate != "playing" || self.pers["team"] != "allies" || self.health <= 0)
		return;

	while(isalive(self) && self.pers["team"] == "allies")
	{
		wait .05;
		if(self.health == self.maxhealth)
			continue;

		if(self.health <= 0)
			return;

		if(self.health < self.maxhealth)
		{
			self.health += (1+randomint(10));
			wait (10+randomint(11));
		}
	}
}

anti_afk()
{
	if(self.sessionstate != "playing" || self.pers["team"] != "axis")
		return;

	level waittill("hide_done");

	time=0;
	prev_org=self.origin-(0,0,5);

	while(isalive(self) && self.pers["team"] == "axis")
	{
		wait .2;

		if(distance(prev_org,self.origin) <= 10)
			time++;
		else 
			time=0;
			
		if(time == 150)
		{
			iprintlnbold("Michael seems AFK, get on and kill him!");
    		self freezecontrols(1);
    		level.michael_afk=true;

    		plr=getentarray("player","classname");
    		for(i=0;i<plr.size;i++)
    		{
    			plr[i] takeallweapons();
    			plr[i] giveweapon(plr[i].pers["weapon"]);
    			plr[i] switchtoweapon(plr[i].pers["weapon"]);
    		}
    		break;
		}
		prev_org=self.origin;
	}
}

timeLimit()
{
	level.timeLimit = level.dvar["timeLimit"];
	level.starttime = getTime();

	while(game["state"]=="playing")
	{
		thread checkTimeLimit();
		if (isDefined(level.startTime) && getTimeRemaining() < 3000)
		{
			wait 0.1;
			continue;
		}
		wait 1;
	}
}

checkTimeLimit()
{
	if (!isDefined(level.startTime)) 
		return;
		
	timeLeft = getTimeRemaining();
	setGameEndTime(getTime() + int(timeLeft));

	if (timeLeft > 0) 
		return;
		
	level thread endRound("allies","Hiders Survived!");
}

getTimeRemaining()
{
	return level.timeLimit * 60000 - getTimePassed();
}

getTimePassed()
{
	if (!isDefined(level.startTime)) 
		return 0;
	return (gettime() - level.startTime);
}

endRound(team,message)
{
	if(game["state"]=="round ended" || !game["roundStarted"])
		return;
	
	level notify("round_ended",team,message);
	level notify("endround");

	game["state"]="round ended";
	game["rounds"]+=1;

	visionsetnaked("roundend",2);

	if(int(game["rounds"]) >= (level.dvar["roundLimit"]+1))
	{
		level endmap("end");
		return;
	}
	else 
		level thread glowmessage(message);

	wait 5; // Requires more Time?
	map_restart(true);
}

glowmessage(text)
{
	notifyData = spawnStruct();
	notifyData.notifyText = text;
	notifyData.glowColor = (1,0,0);
	notifyData.duration = 8.8;

	players = getentarray("player","classname");
	for( i = 0; i < players.size; i++ )
		players[i] thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}

endmap(reason)
{
	game["state"]="endmap";
	level notify("intermission");
	level notify("game over");

	setdvar("g_deadChat",1);

	ambientstop();
	ambientplay("end_game");

	p=getentarray("player","classname");
	for(i=0;i<p.size;i++)
		p[i] thread end_function();

	wait .05;

	p=getentarray("player","classname");
	for(i=0;i<p.size;i++)
	{
		p[i] spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		p[i] allowSpectateTeam( "allies", false );
		p[i] allowSpectateTeam( "axis", false );
		p[i] allowSpectateTeam( "freelook", false );
		p[i] allowSpectateTeam( "none", false );
		wait .05;
	}
	wait 2;

	mike\_voting::start_voting();
	wait level.dvar["voteTime"]+1.5;
	mod_credits();

	p=getentarray("player","classname");
	for(i=0;i<p.size;i++)
	{
		p[i] spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		p[i].sessionstate = "intermission";
	}
	wait 2;

	if(level.voting_enabled == true)
		mike\_voting::change_map(mike\_voting::set_winning_map());
	else
		exitlevel(false);
}

end_function()
{
	if(!isdefined(self))
		return;

	if(isdefined(self.blackscreen))	
		self.blackscreen destroy();

	self closemenu();
	self closeingamemenu();
	self freezecontrols(1);
}

selectMichael()
{
	if(game["state"] != "playing" || level.michael >= 1 || level.michael_killed == true)
		return;

	p=getentarray("player","classname");
	num=randomint(p.size);
	mike=p[num];

	if(mike getentitynumber() == getdvarint( "last_mike" ))
	{	
		if( isDefined( p[num-1] ) && isPlayer( p[num-1] ) )
			mike = p[num-1];
		else if( isDefined( p[num+1] ) && isPlayer( p[num+1] ) )
			mike = p[num+1];
	}

	if(!isdefined(mike) || mike.sessionstate=="spectator")
	{
		level thread selectMichael();
		return;
	}

	mike mike\_common::setteam("axis");
	mike spawnplayer();

	setdvar("last_mike",mike getentitynumber());

	level.mike=mike;
	level thread hideandatmosphere();

	wait .1;
}

hideandatmosphere()
{
	if(mike\_maps::fogpreseted(getdvar("mapname")) || level.dvar["michael_fog"] == 1)
		setExpFog(64,128,0,0,0,.1);

	level.mike freezecontrols(1);
	level.mike thread mike\_common::blackscreen(); // usefull cause he would be blind until they all hide

	p=getentarray("player","classname");
	for(i=0;i<p.size;i++)
	{
		if(p[i].pers["team"] == "allies")
			p[i] thread hidetimer(level.dvar["hideTime"]);
	}

	wait level.dvar["hideTime"];
	level.mike freezecontrols(0);
	level notify("hide_done"); // uses blackscreen
	level.mike thread hud_text("You're Michael. Find all Hiders!");

	if(level.mm_alive>=2 && level.humans==1)
		level.human[0] thread last_alive_bonus(0);

	thread timeLimit();
}

hud_text(text)
{
	if(isdefined(self.hud_text))
		self.hud_text destroy();

	self.hud_text=createhud(self,0,-150,"center","middle","default",1.8,undefined,(1,0,0));
    self.hud_text.foreground = true;
 	self.hud_text.hidewheninmenu = true;
 	self.hud_text settext(text);
 	self.hud_text setpulsefx(100,int(8.8*1000),1000);
 	wait 5;

 	self.hud_text destroy();
}

hidetimer(value)
{
	if(isdefined(self.hide_timer))
		self.hide_timer destroy();

	self.hide_timer=createhud(self,0,-3,"center","bottom","default",1.5,(1,0,0));
    self.hide_timer.foreground = true;
 	self.hide_timer.hidewheninmenu = true;
 	self.hide_timer.label=&"Remaining Time to Hide: &&1";
 	self.hide_timer settenthstimer(value);
 	wait value;

 	self.hide_timer destroy();
}

PlayerLastStand( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self suicide();
}

PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if(self.sessionteam=="spectator" || game["state"]=="endmap")
		return;

	level notify( "player_damage", self, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

	if(isplayer(eAttacker) && eAttacker.pers["team"]==self.pers["team"])
		return;

	if(isDefined(eAttacker) && isPlayer(eAttacker) && self!=eAttacker && isDefined(level.mike) && (level.mike==self||level.mike==eAttacker))
	{
		eAttacker playlocalsound("MP_hit_alert");
		eAttacker.hud_damagefeedback.alpha = 1;
		eAttacker.hud_damagefeedback fadeOverTime(1);
		eAttacker.hud_damagefeedback.alpha = 0;
	}

	if( sMeansOfDeath == "MOD_FALLING" && self.pers["team"] == "axis")
		iDamage = int(iDamage*0.25);

    if( sMeansOfDeath == "MOD_MELEE" )
		eAttacker thread bloodsplat();

	if(!isDefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		if(iDamage < 1)
			iDamage = 1;

		self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	}
}

PlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	self endon("spawned");
	self notify("killed_player");
	self notify("death");

	if(self.sessionteam == "spectator" || game["state"] == "endmap" )
		return;

	level notify( "player_killed", self, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );

	if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
		sMeansOfDeath = "MOD_HEAD_SHOT";

	body=self cloneplayer(deathAnimDuration);
	if(self isOnLadder() || self isMantling())
		body startRagDoll();

	thread mike\_common::delayStartRagdoll( body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath ); // Somehow keeps erroring on the Mike Model?!

	self.statusicon = "hud_status_dead";
	self.sessionstate =  "spectator";

	if(isplayer(attacker))
	{
		if(attacker!=self)
		{
			attacker.kills++;
			attacker.pers["kills"]++;

			kills = attacker maps\mp\gametypes\_persistence::statGet( "kills" );
			attacker maps\mp\gametypes\_persistence::statSet( "kills", kills+1 );

			if( self.pers["team"] == "axis" )
				attacker mike\_rank::giverankxp("dead_mike");
			if( self.pers["team"] == "allies" )
				attacker mike\_rank::giverankxp("kill");
		}
	}

	deaths = self maps\mp\gametypes\_persistence::statGet( "deaths" );
	self maps\mp\gametypes\_persistence::statSet( "deaths", deaths+1 );
	self.deaths++;
	self.pers["deaths"]++;
	self.died = true;

	obituary( self, attacker, sWeapon, sMeansOfDeath );

	if(self.pers["team"] == "axis")
	{
		level.michael_killed=true;
		self thread mike\_common::setteam("allies");
	}
}

bloodsplat()
{
	self endon( "disconnect" );

	hud = NewClientHudElem( self );
	hud.alignX = "center";
	hud.alignY = "middle";
	hud.horzalign = "center";
	hud.vertalign = "middle";
	hud.alpha = 1;
	hud.x = RandomIntRange(-320,320);
	hud.y = RandomIntRange(-240,240);
	hud setShader( "dtimer_"+randomint(3),512,512);
	wait 1;
	hud FadeOverTime(3);
	hud.alpha = 0;
	wait 3;
	hud destroy();
}

playerConnect()
{
	level notify("connected",self);

	self.guid = self getGuid();
	self.number = self getEntityNumber();
	self.statusicon = "hud_status_connecting";
	self.died = false;
	self.doingNotify = false;
	self.flashlight=false;	// Mikes Flashlight

	if( !isDefined( self.name ) )
		self.name = "undefined name";
	if( !isDefined( self.guid ) )
		self.guid = "undefined guid";

	self setClientDvars( "show_hud", "true", "ip", getDvar("net_ip"), "port", getDvar("net_port") );
	if(!isdefined(self.pers["team"]))
	{
		self.sessionstate="spectator";
		self.team="spectator";
		self.pers["team"] = "spectator";

		self.pers["score"]=0;
		self.pers["kills"]=0;
		self.pers["deaths"]=0;
		self.pers["assists"]=0;
	}
	else
	{
		self.score = self.pers["score"];
		self.kills = self.pers["kills"];
		self.assists = self.pers["assists"];
		self.deaths = self.pers["deaths"];
	}

	if(game["state"]=="endmap")
	{
		self spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		self.sessionstate = "intermission";
		return;
	}

	if(isdefined(self.pers["weapon"]) && self.pers["team"]!="spectator")
	{
		self mike\_common::setteam("allies");
		spawnplayer();
		return;
	}
	else 
	{
		self spawnSpectator( level.spawn["spectator"].origin, level.spawn["spectator"].angles );
		self thread delayedMenu();
		logPrint("J;" + self.guid + ";" + self.number + ";" + self.name + "\n");
	}
	level.playerlist[level.playerlist.size]=self;
	self setClientDvars( "cg_drawSpectatorMessages", 1, "ui_hud_hardcore", 1, "player_sprintTime", 4, "ui_uav_client", 0, "g_scriptMainMenu", game["menu_team"] );
}

delayedMenu()
{
	self endon( "disconnect" );
	wait 0.05; //waitillframeend;

	self openMenu( game["menu_team"] );
}

playerDisconnect()
{
	level notify( "disconnected", self );

	if( !isDefined( self.name ) )
		self.name = "no name";
		
	logPrint("Q;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + "\n");

	for (i = 0; i < level.playerlist.size; i++)
	{
		if (level.playerlist[i] == self)
		{
			while (i < level.playerlist.size - 1)
			{
				level.playerlist[i] = level.playerlist[i + 1];
				i++;
			}
			level.playerlist[i] = undefined;
			break;
		}
	}
}

spawnSpectator(origin,angles)
{
	if(!isdefined(origin) || !isdefined(angles))
	{
		origin=(0,0,0);
		angles=(0,0,0);
	}
	self notify( "joined_spectators" );

	self mike\_common::setteam("spectator");

	self.sessionstate="spectator";
	self.spectatorclient=-1;
	self.statusicon="";
	self spawn(origin,angles);

	self mike\_common::spectateperms();
	level notify("player_spectator",self);
}

last_alive_bonus(mode)
{
	if(isdefined(level.last_alive))
		return;

	level.last_alive=true;

	if(mode)
		self mike\_rank::giverankxp("last_hider");

	self thread hud_text("Congratulations, now try to kill Michael!");
	thread announcer(&"MM_LAST_HIDER",self);

	self takeallweapons();
	self giveweapon(self.pers["weapon"]);
	self switchtoweapon(self.pers["weapon"]);
}

announcer(text,who)
{
	while(isdefined(level.announcer_inuse) && level.announcer_inuse)
		wait 0.05;

	level.announcer_inuse=true;

	shader=createhud(level,-300,120,"left","top");
	shader.alpha=0.7;
	shader.hidewheninmenu=true;
	shader setshader("stance_prone",140,30);

	icon=createhud(level,-295,121,"left","top");
	icon.alpha=1;
	icon.hidewheninmenu=true;
	icon setshader(mike\_rank::getRankInfoIcon(who.pers["rank"],0),28,28);

	message=createhud(level,-260,120,"left","top","default",1.4,undefined,(1,0,0));
	message.alpha=1;
	message.hidewheninmenu=true;
	message.label=text;

	name=createhud(level,-260,133,"left","top","default",1.4,undefined,(1,0,0));
	name.alpha=1;
	name.hidewheninmenu=true;
	name settext(who.name);

	// Move in
	shader moveovertime(0.35);
	icon moveovertime(0.35);
	message moveovertime(0.35);
	name moveovertime(0.35);

	shader.x=0; 
	icon.x=10;
	message.x=45;
	name.x=45;

	wait 5;

	// Move out
	shader moveovertime(0.35);
	icon moveovertime(0.35);
	message moveovertime(0.35);
	name moveovertime(0.35);

	shader.x=-300;
	icon.x=-295;
	message.x=-260;
	name.x=-260;

	wait .5;

	shader destroy();
	icon destroy();
	message destroy();
	name destroy();

	level.announcer_inuse=false;
}

playerCount()
{
	level endon("intermission");

	setdvar("round_count",game["rounds"]+"/"+level.dvar["roundLimit"]);
	makedvarserverinfo("round_count",getdvar("round_count"));

	level.hiders = newHudElem();
	level.hiders.foreground = true;
	level.hiders.alignX = "left";
	level.hiders.alignY = "top";
	level.hiders.horzAlign = "left";
	level.hiders.vertAlign = "top";
	level.hiders.x = 57;
	level.hiders.y = 25;
	level.hiders.sort = 0;
	level.hiders.font="default";
	level.hiders.fontScale = 1.4;
	level.hiders.color=(1,0,0);
	level.hiders.alpha=1;
	level.hiders.hidewheninmenu = true;
	level.hiders.archived = 0;

	while(1)
	{
		hiders=level.humans;
		wait .1;

		if(hiders == level.humans)
			continue;
			
		level.hiders setvalue(level.humans);
	}
}

mod_credits()
{
	plr=getentarray("player","classname");
	for(i=0;i<plr.size;i++)
	{
		plr closeingamemenu();
		plr closemenu();

		wait .05;
	}
	
	thread docredit("Mod created by", 2,0, 50 );
	wait .03;
	thread docredit( "Blade", 1.4, 0, 70 );
	wait 1.5;
	thread docredit( "Characters by", 2, 0, 100 );
	wait 0.3;
	thread docredit( "ERIK", 1.4, 0, 120 );
	wait 1.5;
	thread docredit( "Artwork by", 2, 0, 150 );
	wait .3;
	thread docredit( "Niko", 1.4, 0, 170 );
	wait 1.5;
	thread docredit("Thanks for playing Michael Myers 0.3",2.2,0,220);
	wait 7;
}

docredit( text, scale, x, y )
{
	end_text = newHudElem();
	end_text.font = "default";
	end_text.fontScale = scale;
	end_text SetText(text);
	end_text.alignX = "center";
	end_text.alignY = "top";
	end_text.horzAlign = "center";
	end_text.vertAlign = "top";
	end_text.x = x;
	end_text.y = y;
	end_text.sort = -1; 
	end_text.foreground = true;
	end_text.alpha = 0;
	end_text.glowColor = (1,0,0);
	end_text.glowAlpha = 1;
	end_text fadeOverTime(2);
	end_text.alpha = 1;
	wait 5;
	end_text fadeOverTime(2);
	end_text.alpha = 0;
	wait 2;
	end_text destroy();
}