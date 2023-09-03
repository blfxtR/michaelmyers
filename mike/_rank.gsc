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

#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level.scoreInfo = [];
	level.rankTable = [];

	precacheString( &"MM_STILL_ALIVE" );
	precacheString( &"MM_PROMOTED" );
	precacheString( &"MM_LAST_HIDER" );
	precacheString( &"MP_PLUS" );

	registerscoreinfo("kill",50);
	registerscoreinfo("dead_mike",200);
	registerscoreinfo("still_alive",10);
	registerscoreinfo("last_hider",25);
	registerscoreinfo("battery_pick",5);
	
	registerscoreinfo("win",20);
	registerscoreinfo("loss",10);
	registerscoreinfo("tie",15);

	level.maxRank = int(tableLookup( "mp/rankTable.csv", 0, "maxrank", 1 ));
	level.maxPrestige = int(tableLookup( "mp/rankIconTable.csv", 0, "maxprestige", 1 ));
	
	pId = 0;
	rId = 0;
	for ( pId = 0; pId <= level.maxPrestige; pId++ )
	{
		for ( rId = 0; rId <= level.maxRank; rId++ )
			precacheShader( tableLookup( "mp/rankIconTable.csv", 0, rId, pId+1 ) );
	}

	rankId = 0;
	rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
	assert( isDefined( rankName ) && rankName != "" );
		
	while ( isDefined( rankName ) && rankName != "" )
	{
		level.rankTable[rankId][1] = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
		level.rankTable[rankId][2] = tableLookup( "mp/ranktable.csv", 0, rankId, 2 );
		level.rankTable[rankId][3] = tableLookup( "mp/ranktable.csv", 0, rankId, 3 );
		level.rankTable[rankId][7] = tableLookup( "mp/ranktable.csv", 0, rankId, 7 );

		precacheString( tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 ) );

		rankId++;
		rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );		
	}
	level thread onPlayerConnect();
}


isRegisteredEvent( type )
{
	if ( isDefined( level.scoreInfo[type] ) )
		return true;
	else
		return false;
}

registerScoreInfo( type, value )
{
	level.scoreInfo[type]["value"] = value;
}

getScoreInfoValue( type )
{
	return ( level.scoreInfo[type]["value"] );
}

getScoreInfoLabel( type )
{
	return ( level.scoreInfo[type]["label"] );
}

getRankInfoMinXP( rankId )
{
	return int(level.rankTable[rankId][2]);
}

getRankInfoXPAmt( rankId )
{
	return int(level.rankTable[rankId][3]);
}

getRankInfoMaxXp( rankId )
{
	return int(level.rankTable[rankId][7]);
}

getRankInfoFull( rankId )
{
	return tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 );
}

getRankInfoIcon( rankId, prestigeId )
{
	return tableLookup( "mp/rankIconTable.csv", 0, rankId, prestigeId+1 );
}

getRankInfoUnlockWeapon( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 8 );
}

getRankInfoUnlockPerk( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 9 );
}

getRankInfoUnlockChallenge( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 10 );
}

getRankInfoUnlockFeature( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 15 );
}

getRankInfoUnlockCamo( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 11 );
}

getRankInfoUnlockAttachment( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 12 );
}

getRankInfoLevel( rankId )
{
	return int( tableLookup( "mp/ranktable.csv", 0, rankId, 13 ) );
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		player.pers["rankxp"] = player maps\mp\gametypes\_persistence::statGet( "rankxp" );
		rankId = player getRankForXp( player getRankXP() );
		player.pers["rank"] = rankId;
		player.pers["participation"] = 0;
		
		player.rankUpdateTotal = 0;
		
		// for keeping track of rank through stat#251 used by menu script
		// attempt to move logic out of menus as much as possible
		player.cur_rankNum = rankId;
		assertex( isdefined(player.cur_rankNum), "rank: "+ rankId + " does not have an index, check mp/ranktable.csv" );
		player setStat( 251, player.cur_rankNum );
		
		prestige = 0;
		player setRank( rankId, prestige );
		player.pers["prestige"] = prestige;
		
		player thread onJoinedTeam();
		player thread onJoinedSpectators();

		// TO-DO Anti-Rank-Hack

		updateRankStats( player, rankId );
	}
}

onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		self thread removeRankHUD();
	}
}


onJoinedSpectators()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");
		self thread removeRankHUD();
	}
}

roundUp( floatVal )
{
	if ( int( floatVal ) != floatVal )
		return int( floatVal+1 );
	else
		return int( floatVal );
}

giveRankXP( type, value )
{
	self endon("disconnect");

	if ( !isDefined( value ) )
		value = getScoreInfoValue( type );

	self.score += value;
	self.pers["score"] = self.score;

	score = self maps\mp\gametypes\_persistence::statGet( "score" );
	self maps\mp\gametypes\_persistence::statSet( "score", score+value );
		
	self incRankXP( value );
	self thread updateRankScoreHUD( value );
}

incRankXP( amount )
{
	if ( !level.rankedMatch )
		return;
	
	xp = self getRankXP();
	newXp = (xp + amount);

	if ( self.pers["rank"] == level.maxRank && newXp >= getRankInfoMaxXP( level.maxRank ) )
		newXp = getRankInfoMaxXP( level.maxRank );

	self.pers["rankxp"] = newXp;
	self maps\mp\gametypes\_persistence::statSet( "rankxp", newXp );

	rankId = self getRankForXp( self getRankXP() );
	self updateRank( rankId );
}

updateRank( rankId )
{
	if( getRankInfoMaxXP( self.pers["rank"] ) <= self getRankXP() && self.pers["rank"] < level.maxRank )
	{
		rankId = self getRankForXp( self getRankXP() );
		self setRank( rankId, self.pers["prestige"] );
		self.pers["rank"] = rankId;
		self updateRankAnnounceHUD();
	}
	updateRankStats( self, rankId );
}

updateRankStats( player, rankId )
{
	player setStat( 253, rankId );
	player setStat( 255, player.pers["prestige"] );
	player maps\mp\gametypes\_persistence::statSet( "rank", rankId );
	player maps\mp\gametypes\_persistence::statSet( "minxp", getRankInfoMinXp( rankId ) );
	player maps\mp\gametypes\_persistence::statSet( "maxxp", getRankInfoMaxXp( rankId ) );
	player maps\mp\gametypes\_persistence::statSet( "plevel", player.pers["prestige"] );
	
	if( rankId > level.maxRank )
		player setStat( 252, level.maxRank );
	else
		player setStat( 252, rankId );
}

updateRankAnnounceHUD()
{
	self endon("disconnect");

	self notify("update_rank");
	self endon("update_rank");

	team = self.pers["team"];
	if ( !isdefined( team ) )
		return;	
	
	self notify("reset_outcome");
	newRankName = self getRankInfoFull( self.pers["rank"] );
	
	notifyData = spawnStruct();
	notifyData.titleText = &"MM_PROMOTED";
	notifyData.iconName = self getRankInfoIcon( self.pers["rank"], self.pers["prestige"] );
	notifyData.sound = "mp_level_up";
	notifyData.duration = 4.0;
	notifyData.glowcolor = (1,0,0);
	notifyData.glowalpha = 1;
	
	rank_char = level.rankTable[self.pers["rank"]][1];
	subRank = int(rank_char[rank_char.size-1]);	

	notifyData.notifyText = newRankName;

	thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}

updateRankScoreHUD( amount )
{
	if(!isdefined(amount) || amount == 0)
		return;

	self endon("disconnect");
	self notify("update_score");
	wait .05;

	self.rankUpdateTotal += amount;

	if(!isdefined(self.hud_rankscroreupdate))
	{
		self.hud_rankscroreupdate = newClientHudElem(self);
		self.hud_rankscroreupdate.horzAlign = "center";
		self.hud_rankscroreupdate.vertAlign = "middle";
		self.hud_rankscroreupdate.alignX = "center";
		self.hud_rankscroreupdate.alignY = "middle";
	 	self.hud_rankscroreupdate.x = 0;
		self.hud_rankscroreupdate.y = -30;
		self.hud_rankscroreupdate.font = "default";
		self.hud_rankscroreupdate.fontscale = 1.8;
		self.hud_rankscroreupdate.archived = false;
		self.hud_rankscroreupdate.glowalpha = 1;
		self.hud_rankscroreupdate.glowcolor = (1,0,0);
		self.hud_rankscroreupdate maps\mp\gametypes\_hud::fontPulseInit();

		self.hud_rankscroreaddition = newclienthudelem(self);
		self.hud_rankscroreaddition.horzAlign = "center";
		self.hud_rankscroreaddition.vertAlign = "middle";
		self.hud_rankscroreaddition.alignX = "center";
		self.hud_rankscroreaddition.alignY = "middle";
	 	self.hud_rankscroreaddition.x = -20;
		self.hud_rankscroreaddition.y = -50;
		self.hud_rankscroreaddition.font = "default";
		self.hud_rankscroreaddition.fontscale = 1.4;
		self.hud_rankscroreaddition.archived = false;
		self.hud_rankscroreaddition.glowalpha = 1;
		self.hud_rankscroreaddition.glowcolor = (1,0,0);
		self.hud_rankscroreaddition.alpha = 0;
		self.hud_rankscroreaddition maps\mp\gametypes\_hud::fontPulseInit();
	}

	if( isDefined( self.hud_rankscroreupdate ) )
	{			
		if ( self.rankUpdateTotal < 0 )
			self.hud_rankscroreupdate.label = &"";
		else
			self.hud_rankscroreupdate.label = &"MP_PLUS";

		if(self.rankupdatetotal == getscoreinfovalue("still_alive"))
			self thread addition(&"MM_STILL_ALIVE");

		if(self.rankupdatetotal == getscoreinfovalue("battery_pick"))
			self thread addition(&"MM_BATTERY");

		self.hud_rankscroreupdate setValue(self.rankUpdateTotal);
		self.hud_rankscroreupdate.alpha = 1;
		self.hud_rankscroreupdate thread maps\mp\gametypes\_hud::fontPulse( self );

		wait 1.2;
		self.hud_rankscroreupdate fadeovertime(0.75);
		self.hud_rankscroreupdate.alpha = 0;
		
		self.rankUpdateTotal = 0;
	}
}

addition(text)
{
	self.hud_rankscroreaddition.label=text;
	self.hud_rankscroreaddition.alpha = 1;
	self.hud_rankscroreaddition thread maps\mp\gametypes\_hud::fontPulse( self );

	wait 1.2;
	self.hud_rankscroreaddition fadeovertime(0.75);
	self.hud_rankscroreaddition.alpha = 0;
	self.hud_rankscroreaddition settext("");
}

removeRankHUD()
{
	if(isDefined(self.hud_rankscroreupdate))
		self.hud_rankscroreupdate.alpha = 0;
}

getRank()
{	
	rankXp = self.pers["rankxp"];
	rankId = self.pers["rank"];
	
	if ( rankXp < (getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId )) )
		return rankId;
	else
		return self getRankForXp( rankXp );
}

getRankForXp( xpVal )
{
	rankId = 0;
	rankName = level.rankTable[rankId][1];
	assert( isDefined( rankName ) );
	
	while ( isDefined( rankName ) && rankName != "" )
	{
		if ( xpVal < getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId ) )
			return rankId;

		rankId++;
		if ( isDefined( level.rankTable[rankId] ) )
			rankName = level.rankTable[rankId][1];
		else
			rankName = undefined;
	}
	
	rankId--;
	return rankId;
}

getSPM()
{
	rankLevel = (self getRank() % 61) + 1;
	return 3 + (rankLevel * 0.5);
}

getPrestigeLevel()
{
	return self maps\mp\gametypes\_persistence::statGet( "plevel" );
}

getRankXP()
{
	return self.pers["rankxp"];
}