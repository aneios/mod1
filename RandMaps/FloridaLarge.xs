// LARGE FLORIDA 
// designed by Garja
// winter version by dicktator_
// for some reason it is snowing in florida (not unheard of actually)
//Ported by Durokan and Interjection for DE
// February 2021 edited by vividlyplain for DE, updated May 2021
// LARGE version by vividlyplain, July 2021

include "mercenaries.xs";
include "ypAsianInclude.xs";
include "ypKOTHInclude.xs";


// Main entry point for random map script
void main(void)
{

	int TeamNum = cNumberTeams;
	int PlayerNum = cNumberNonGaiaPlayers;
	int numPlayer = cNumberPlayers;

	bool isWinterSeason = false;

	// Text
	// These status text lines are used to manually animate the map generation progress bar
	rmSetStatusText("",0.01); 
	
	// ************************************** GENERAL FEATURES *****************************************
	
	// Picks the map size
	int	playerTiles = 24000;
	int size=2.0*sqrt(PlayerNum*playerTiles); 
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	
	// Make the corners.
	rmSetWorldCircleConstraint(true);
	
	// Picks a default water height
	rmSetSeaLevel(2.0);	// this is height of river surface compared to surrounding land. River depth is in the river XML.

	rmSetMapElevationParameters(cElevTurbulence, 0.045, 3, 0.40, 2.5);  // type, frequency, octaves, persistence, variation 
//	rmSetMapElevationHeightBlend(0.3); //
	
	// Picks default terrain and water
	if (isWinterSeason == true) {
		rmSetBaseTerrainMix("greatlakes_snow");
		rmTerrainInitialize("great_lakes\ground_ice1_gl", 1.0);
		rmSetMapType("caribbean");
		rmSetMapType("snow");
		rmSetMapType("water");
		rmSetLightingSet("Florida_Winter_Skirmish");

		//Weather
		rmSetWindMagnitude(1.0);
		rmSetGlobalSnow( 0.3 );
	} else {
		//rmSetSeaType("caribbean coast"); //
		rmSetBaseTerrainMix("caribbean grass");
		rmTerrainInitialize("caribbean\ground7_crb", 1.5);
		//rmTerrainInitialize("water");
		rmSetMapType("caribbean");
		rmSetMapType("grass");
		rmSetMapType("water");
		rmSetLightingSet("Florida_Skirmish");

		//Weather
		rmSetWindMagnitude(1.0);
		rmSetGlobalRain( 0.3 );
	}
	
	// Choose Mercs
	chooseMercs();
	
	// Text
	rmSetStatusText("",0.10);
	
	// Set up Natives
	int subCiv0 = -1;
	subCiv0 = rmGetCivID("Seminoles");
	rmSetSubCiv(0, "Seminoles");
	int subCiv1 = -1;
	subCiv1 = rmGetCivID("Caribs");
	rmSetSubCiv(1, "Caribs");

	//Define some classes. These are used later for constraints.
	int classPlayer = rmDefineClass("player");
	int classPatch = rmDefineClass("patch");
	int classPatch2 = rmDefineClass("patch2");
	int classPatch3 = rmDefineClass("patch3");
	int classPatch4 = rmDefineClass("patch4");
	int classForest = rmDefineClass("Forest");
	int classNative = rmDefineClass("natives");
	int classGold = rmDefineClass("Gold");
	int classStartingResource = rmDefineClass("startingResource");
	int classSea = rmDefineClass("sea");
	int classSwamp = rmDefineClass("swamp");
	int classIsland=rmDefineClass("island");

	int TRvariation = -1;
//	TRvariation = rmRandInt(1,3);
	if (TeamNum > 2)
		TRvariation = 4;
	int TRADEchooser = rmRandInt (1,2);
	if (TRADEchooser == 1)
		TRvariation = 1;
	else 
		TRvariation = 3;
//	TRvariation = 3; // <--- TEST

	// ******************************************************************************************
	
	// Text
	rmSetStatusText("",0.20);
	
	// ************************************* CONTRAINTS *****************************************
   
	// Cardinal Directions & Map placement
	int avoidEdge = rmCreatePieConstraint("Avoid Edge",0.5,0.5, rmXFractionToMeters(0.0),rmXFractionToMeters(0.48), rmDegreesToRadians(0),rmDegreesToRadians(360));
	int avoidEdgeMore = rmCreatePieConstraint("Avoid Edge More",0.5,0.5, rmXFractionToMeters(0.0),rmXFractionToMeters(0.38), rmDegreesToRadians(0),rmDegreesToRadians(360));
	int avoidCenter = rmCreatePieConstraint("Avoid Center",0.5,0.5,rmXFractionToMeters(0.26), rmXFractionToMeters(0.5), rmDegreesToRadians(0),rmDegreesToRadians(360));
	int stayCenter = rmCreatePieConstraint("Stay Center",0.50,0.50,rmXFractionToMeters(0.0), rmXFractionToMeters(0.28), rmDegreesToRadians(0),rmDegreesToRadians(360));
	int stayCenterMore = rmCreatePieConstraint("Stay Center more",0.5,0.5,rmXFractionToMeters(0.0), rmXFractionToMeters(0.26), rmDegreesToRadians(0),rmDegreesToRadians(360));
	int staySouth = rmCreatePieConstraint("Stay South half",0.3, 0.5, rmXFractionToMeters(0.0), rmXFractionToMeters(0.50), rmDegreesToRadians(180),rmDegreesToRadians(360));
	int stayNorth = rmCreatePieConstraint("Stay North half",0.6, 0.5, rmXFractionToMeters(0.0), rmXFractionToMeters(0.50), rmDegreesToRadians(0),rmDegreesToRadians(180));
		
	// Resource avoidance
	int avoidForestFar=rmCreateClassDistanceConstraint("avoid forest far", rmClassID("Forest"), 26.0); //15.0
	int avoidForest=rmCreateClassDistanceConstraint("avoid forest", rmClassID("Forest"), 24.0+PlayerNum); //15.0
	int avoidForestShort=rmCreateClassDistanceConstraint("avoid forest short", rmClassID("Forest"), 20.0); //15.0
	int avoidForestMin=rmCreateClassDistanceConstraint("avoid forest min", rmClassID("Forest"), 3.0);
	int avoidTurkeyFar = rmCreateTypeDistanceConstraint("avoid Turkey far", "Turkey", 75.0);
	int avoidTurkey = rmCreateTypeDistanceConstraint("avoid Turkey", "Turkey", 44.0);
	int avoidTurkeyShort = rmCreateTypeDistanceConstraint("avoid Turkey short", "Turkey", 25.0);
	int avoidTurkeyMin = rmCreateTypeDistanceConstraint("avoid Turkey min", "Turkey", 5.0);
	int avoidDeerFar = rmCreateTypeDistanceConstraint("avoid Deer far", "Deer", 82.0);
	int avoidDeer = rmCreateTypeDistanceConstraint("avoid  Deer", "Deer", 50.0);
	int avoidDeerShort = rmCreateTypeDistanceConstraint("avoid  Deer short", "Deer", 30.0);
	int avoidDeerMin = rmCreateTypeDistanceConstraint("avoid Deer min", "Deer", 5.0);
	int avoidGoldTypeShort = rmCreateTypeDistanceConstraint("coin avoids coin short", "gold", 8.0);
	int avoidGoldTypeMed = rmCreateTypeDistanceConstraint("coin avoids coin med", "gold", 24.0);
	int avoidGoldType = rmCreateTypeDistanceConstraint("coin avoids coin", "gold", 38.0);
	int avoidGoldTypeFar = rmCreateTypeDistanceConstraint("coin avoids coin far", "gold", 58.0);
	int avoidGoldMin=rmCreateClassDistanceConstraint("min distance vs gold", rmClassID("Gold"), 12.0);
	int avoidGold = rmCreateClassDistanceConstraint ("gold avoid gold med", rmClassID("Gold"), 42.0);
	int avoidGoldFar = rmCreateClassDistanceConstraint ("gold avoid gold far", rmClassID("Gold"), 48.0); // 82
//	int avoidGoldVeryFar = rmCreateClassDistanceConstraint ("gold avoid gold very ", rmClassID("Gold"), 74.0);
	int avoidNuggetMin = rmCreateTypeDistanceConstraint("nugget avoid nugget min", "AbstractNugget", 10.0);
	int avoidNuggetShort = rmCreateTypeDistanceConstraint("nugget avoid nugget short", "AbstractNugget", 30.0);
	int avoidNugget=rmCreateTypeDistanceConstraint("nugget avoid nugget", "AbstractNugget", 34.0);
	int avoidNuggetFar = rmCreateTypeDistanceConstraint("nugget avoid nugget Far", "AbstractNugget", 50.0);
	int avoidTownCenterFar=rmCreateTypeDistanceConstraint("avoid Town Center Far", "townCenter", 52.0);
	int avoidTownCenter=rmCreateTypeDistanceConstraint("avoid Town Center", "townCenter", 46.0);
	int avoidTownCenterMed=rmCreateTypeDistanceConstraint("avoid Town Center med", "townCenter", 48.0);
	int avoidTownCenterShort=rmCreateTypeDistanceConstraint("avoid Town Center short", "townCenter", 28.0);
	int avoidTownCenterMin=rmCreateTypeDistanceConstraint("avoid Town Center min", "townCenter", 18.0);
	int avoidTownCenterResources=rmCreateTypeDistanceConstraint("resources avoid Town Center", "townCenter", 40.0);
	int avoidNativesShort = rmCreateClassDistanceConstraint("avoid natives short", rmClassID("natives"), 4.0);
	int avoidNatives = rmCreateClassDistanceConstraint("avoid natives", rmClassID("natives"), 7.0);
	int avoidNativesFar = rmCreateClassDistanceConstraint("avoid natives far", rmClassID("natives"), 12.0);
	int avoidStartingResources  = rmCreateClassDistanceConstraint("avoid starting resources", rmClassID("startingResource"), 8.0);
	int avoidStartingResourcesShort  = rmCreateClassDistanceConstraint("avoid starting resources short", rmClassID("startingResource"), 4.0);
	int avoidWhale=rmCreateTypeDistanceConstraint("avoid whale", "fish", 44.0);
	int avoidFish=rmCreateTypeDistanceConstraint("avoid fish", "fish", 12.0+cNumberNonGaiaPlayers);
	int avoidSheep=rmCreateTypeDistanceConstraint("sheep avoids sheep", "sheep", 47.0+1.5*PlayerNum);
	int avoidColonyShip=rmCreateTypeDistanceConstraint("avoid colony ship", "HomeCityWaterSpawnFlag", 35.0);
	int avoidColonyShipShort = rmCreateTypeDistanceConstraint("avoid colony ship short", "HomeCityWaterSpawnFlag", 15.0);

   // New extra stuff for water spawn point avoidance.
	int flagLand = rmCreateTerrainDistanceConstraint("flag vs land", "land", true, 20.0);
	int flagVsFlag = rmCreateTypeDistanceConstraint("flag avoid same", "HomeCityWaterSpawnFlag", 15);
	int flagEdgeConstraint = rmCreatePieConstraint("flags stay near edge of map", 0.5, 0.5, rmGetMapXSize()-20, rmGetMapXSize()-10, 0, 0, 0);

	// Avoid impassable land
	int avoidImpassableLand = rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
	int avoidImpassableLandFar = rmCreateTerrainDistanceConstraint("avoid impassable land far", "Land", false, 20.0);
	int avoidImpassableLandMed = rmCreateTerrainDistanceConstraint("avoid impassable land med", "Land", false, 15.0);
	int avoidImpassableLandShort = rmCreateTerrainDistanceConstraint("avoid impassable land short", "Land", false, 5.0);
	int avoidImpassableLandMin = rmCreateTerrainDistanceConstraint("avoid impassable land min", "Land", false, 1.0);
	int stayNearLand = rmCreateTerrainMaxDistanceConstraint("stay near land ", "Land", true, 5.0);
	int avoidLandMin = rmCreateTerrainDistanceConstraint("avoid land min", "Land", true, 1.0);
	int avoidLand = rmCreateTerrainDistanceConstraint("avoid land", "Land", true, 9.0);
	int avoidLandFar = rmCreateTerrainDistanceConstraint("avoid land far", "Land", true, 18+2.0*PlayerNum);
	int stayNearWater = rmCreateTerrainMaxDistanceConstraint("stay near water ", "water", true, 26.0);
	int stayInWater = rmCreateTerrainMaxDistanceConstraint("stay in water ", "water", true, 0.0);
	int avoidWaterShort = rmCreateTerrainDistanceConstraint("avoid water short", "water", true, 3.0);
	int avoidWater = rmCreateTerrainDistanceConstraint("avoid water ", "water", true, 28.0);
	int avoidWaterFar = rmCreateTerrainDistanceConstraint("avoid water far", "water", true, 36.0);
	int avoidPatch = rmCreateClassDistanceConstraint("avoid patch", rmClassID("patch"), 5.0);
	int avoidPatch2 = rmCreateClassDistanceConstraint("avoid patch2", rmClassID("patch2"), 10.0);
	int avoidPatch3 = rmCreateClassDistanceConstraint("avoid patch3", rmClassID("patch3"), 10.0);
	int avoidPatch4 = rmCreateClassDistanceConstraint("avoid patch4", rmClassID("patch4"), 10.0);
	int avoidSea = rmCreateClassDistanceConstraint("avoid sea", rmClassID("sea"), 2.0);
	int avoidIsland=rmCreateClassDistanceConstraint("avoid island", classIsland, 13.0);
	int avoidIslandMin=rmCreateClassDistanceConstraint("avoid island min", classIsland, 3.0);
	int avoidClassPlayer = rmCreateClassDistanceConstraint("avoid class player", rmClassID("player"), 2.0);

	// VP avoidance
	int avoidTradeRouteFar = rmCreateTradeRouteDistanceConstraint("trade route far", 16.0);
	int avoidTradeRoute = rmCreateTradeRouteDistanceConstraint("trade route", 10.0);
	int avoidTradeRouteShort = rmCreateTradeRouteDistanceConstraint("trade route short", 5.0);
	int avoidTradeRouteSocket = rmCreateTypeDistanceConstraint("avoid trade route socket", "socketTradeRoute", 12.0);
	int avoidTradeRouteSocketShort = rmCreateTypeDistanceConstraint("avoid trade route socket short", "socketTradeRoute", 4.0);
   
	
	// ***********************************************************************************************
	
	// **************************************** PLACE PLAYERS ****************************************
	int teamZeroCount = rmGetNumberPlayersOnTeam(0);
	int teamOneCount = rmGetNumberPlayersOnTeam(1);

		if (cNumberTeams <= 2) // 1v1 and TEAM
		{
			if (teamZeroCount == 1 && teamOneCount == 1) // 1v1
			{
				float OneVOnePlacement=rmRandFloat(0.0, 0.9);
				if ( OneVOnePlacement < 0.5)
				{
					rmPlacePlayer(1, 0.80, 0.52);
					rmPlacePlayer(2, 0.20, 0.52);
				}
				else
				{
					rmPlacePlayer(2, 0.80, 0.52);
					rmPlacePlayer(1, 0.20, 0.52);
				}

			}
			else if (teamZeroCount == teamOneCount) // equal N of players per TEAM
			{
				if (teamZeroCount == 2) // 2v2
				{
					if (TRvariation == 1)
					{
						rmSetPlacementTeam(0);
						rmPlacePlayersLine(0.78, 0.48, 0.74, 0.68, 0.00, 0.25);

						rmSetPlacementTeam(1);
						rmPlacePlayersLine(0.22, 0.48, 0.26, 0.68, 0.00, 0.25);
					}
					else if (TRvariation == 2)
					{
						rmSetPlacementTeam(0);
						rmPlacePlayersLine(0.78, 0.48, 0.82, 0.70, 0.00, 0.25);

						rmSetPlacementTeam(1);
						rmPlacePlayersLine(0.22, 0.48, 0.18, 0.70, 0.00, 0.25);
					}
					else
					{
						rmSetPlacementTeam(0);
						rmPlacePlayersLine(0.84, 0.40, 0.80, 0.54, 0.00, 0.25);

						rmSetPlacementTeam(1);
						rmPlacePlayersLine(0.16, 0.40, 0.20, 0.54, 0.00, 0.25);
					}
				}
				else // 3v3, 4v4
				{
					if (TRvariation == 1)
					{
						rmSetPlacementTeam(0);
						rmPlacePlayersLine(0.80, 0.37, 0.74, 0.70, 0.00, 0.25);

						rmSetPlacementTeam(1);
						rmPlacePlayersLine(0.20, 0.37, 0.26, 0.70, 0.00, 0.25);
					}
					else if (TRvariation == 2)
					{
						rmSetPlacementTeam(0);
						rmPlacePlayersLine(0.76, 0.44, 0.86, 0.72, 0.00, 0.25);

						rmSetPlacementTeam(1);
						rmPlacePlayersLine(0.24, 0.44, 0.14, 0.72, 0.00, 0.25);
					}
					else
					{
						rmSetPlacementTeam(0);
						rmPlacePlayersLine(0.84, 0.38, 0.76, 0.72, 0.00, 0.25);

						rmSetPlacementTeam(1);
						rmPlacePlayersLine(0.16, 0.38, 0.24, 0.72, 0.00, 0.25);
					}
				}
			}
			else // unequal N of players per TEAM
			{
				if (teamZeroCount == 1 || teamOneCount == 1) // one team is one player
				{
					if (teamZeroCount < teamOneCount) // 1v2, 1v3, 1v4, etc.
					{
						rmSetPlacementTeam(0);
						rmPlacePlayersLine(0.77, 0.50, 0.78, 0.51, 0.00, 0.20);

						if (teamOneCount == 2)
						{
							if (TRvariation == 1)
							{
								rmSetPlacementTeam(1);
								rmPlacePlayersLine(0.22, 0.48, 0.26, 0.68, 0.00, 0.25);
							}
							else if (TRvariation == 2)
							{
								rmSetPlacementTeam(1);
								rmPlacePlayersLine(0.22, 0.48, 0.18, 0.70, 0.00, 0.25);
							}
							else
							{
								rmSetPlacementTeam(1);
								rmPlacePlayersLine(0.16, 0.40, 0.24, 0.60, 0.00, 0.25);
							}
						}
						else
						{
							if (TRvariation == 1)
							{
								rmSetPlacementTeam(1);
								rmPlacePlayersLine(0.20, 0.37, 0.26, 0.70, 0.00, 0.25);
							}
							else if (TRvariation == 2)
							{
								rmSetPlacementTeam(1);
								rmPlacePlayersLine(0.24, 0.44, 0.14, 0.72, 0.00, 0.25);
							}
							else
							{
								rmSetPlacementTeam(1);
								rmPlacePlayersLine(0.16, 0.38, 0.24, 0.72, 0.00, 0.25);
							}
						}
					}
					else // 2v1, 3v1, 4v1, etc.
					{
						rmSetPlacementTeam(1);
						rmPlacePlayersLine(0.22, 0.50, 0.23, 0.51, 0.00, 0.20);

						if (teamZeroCount == 2)
						{
							if (TRvariation == 1)
							{
								rmSetPlacementTeam(0);
								rmPlacePlayersLine(0.78, 0.48, 0.74, 0.68, 0.00, 0.25);
							}
							else if (TRvariation == 2)
							{
								rmSetPlacementTeam(0);
								rmPlacePlayersLine(0.78, 0.48, 0.82, 0.70, 0.00, 0.25);
							}
							else
							{
								rmSetPlacementTeam(0);
								rmPlacePlayersLine(0.84, 0.40, 0.76, 0.60, 0.00, 0.25);
							}
						}
						else
						{
							if (TRvariation == 1)
							{
								rmSetPlacementTeam(0);
								rmPlacePlayersLine(0.80, 0.37, 0.74, 0.70, 0.00, 0.25);
							}
							else if (TRvariation == 2)
							{
								rmSetPlacementTeam(0);
								rmPlacePlayersLine(0.76, 0.44, 0.86, 0.72, 0.00, 0.25);
							}
							else
							{
								rmSetPlacementTeam(0);
								rmPlacePlayersLine(0.84, 0.38, 0.76, 0.72, 0.00, 0.25);
							}
						}
					}
				}
				else if (teamZeroCount == 2 || teamOneCount == 2) // one team has 2 players
				{
					if (teamZeroCount < teamOneCount) // 2v3, 2v4, etc.
					{
						if (TRvariation == 1)
						{
							rmSetPlacementTeam(0);
							rmPlacePlayersLine(0.22, 0.48, 0.26, 0.68, 0.00, 0.25);
						}
						else if (TRvariation == 2)
						{
							rmSetPlacementTeam(0);
							rmPlacePlayersLine(0.22, 0.48, 0.18, 0.70, 0.00, 0.25);
						}
						else
						{
							rmSetPlacementTeam(0);
							rmPlacePlayersLine(0.16, 0.40, 0.24, 0.60, 0.00, 0.25);
						}

						if (TRvariation == 1)
						{
							rmSetPlacementTeam(1);
							rmPlacePlayersLine(0.80, 0.37, 0.74, 0.70, 0.00, 0.25);
						}
						else if (TRvariation == 2)
						{
							rmSetPlacementTeam(1);
							rmPlacePlayersLine(0.76, 0.44, 0.86, 0.72, 0.00, 0.25);
						}
						else
						{
							rmSetPlacementTeam(1);
							rmPlacePlayersLine(0.84, 0.38, 0.76, 0.72, 0.00, 0.25);
						}
					}
					else // 3v2, 4v2, etc.
					{
						if (TRvariation == 1)
						{
							rmSetPlacementTeam(0);
							rmPlacePlayersLine(0.80, 0.37, 0.74, 0.70, 0.00, 0.25);
						}
						else if (TRvariation == 2)
						{
							rmSetPlacementTeam(0);
							rmPlacePlayersLine(0.76, 0.44, 0.86, 0.72, 0.00, 0.25);
						}
						else
						{
							rmSetPlacementTeam(0);
							rmPlacePlayersLine(0.84, 0.38, 0.76, 0.72, 0.00, 0.25);
						}

						if (TRvariation == 1)
						{
							rmSetPlacementTeam(1);
							rmPlacePlayersLine(0.22, 0.48, 0.26, 0.68, 0.00, 0.25);
						}
						else if (TRvariation == 2)
						{
							rmSetPlacementTeam(1);
							rmPlacePlayersLine(0.22, 0.48, 0.18, 0.70, 0.00, 0.25);
						}
						else
						{
							rmSetPlacementTeam(1);
							rmPlacePlayersLine(0.16, 0.40, 0.24, 0.60, 0.00, 0.25);
						}
					}
				}
				else // 3v4, 4v3, etc.
				{
					if (TRvariation == 1)
					{
						rmSetPlacementTeam(0);
						rmPlacePlayersLine(0.80, 0.37, 0.74, 0.70, 0.00, 0.25);
					}
					else if (TRvariation == 2)
					{
						rmSetPlacementTeam(0);
						rmPlacePlayersLine(0.76, 0.44, 0.86, 0.72, 0.00, 0.25);
					}
					else
					{
						rmSetPlacementTeam(0);
						rmPlacePlayersLine(0.84, 0.38, 0.76, 0.72, 0.00, 0.25);
					}

					if (TRvariation == 1)
					{
						rmSetPlacementTeam(1);
						rmPlacePlayersLine(0.20, 0.37, 0.26, 0.70, 0.00, 0.25);
					}
					else if (TRvariation == 2)
					{
						rmSetPlacementTeam(1);
						rmPlacePlayersLine(0.24, 0.44, 0.14, 0.72, 0.00, 0.25);
					}
					else
					{
						rmSetPlacementTeam(1);
						rmPlacePlayersLine(0.16, 0.38, 0.24, 0.72, 0.00, 0.25);
					}
				}
			}
		}
		else // FFA
		{
			rmSetPlayerPlacementArea(0.03, (0.31-0.01*cNumberNonGaiaPlayers), 0.97, (0.74+0.02*cNumberNonGaiaPlayers));
			rmSetPlacementSection(0.200, 0.800);
		//	rmSetTeamSpacingModifier(0.25);
			rmPlacePlayersCircular(0.40, 0.40, 0.0);
		}
	
	
	// **************************************************************************************************
   
	// Text
	rmSetStatusText("",0.30);
	
	// ******************************************** MAP LAYOUT **************************************************

	//Sea east template
	int TemplateID = rmCreateArea("sea east template");
	rmSetAreaSize(TemplateID, 0.34, 0.34);
	rmSetAreaWarnFailure(TemplateID, false);
//	rmSetAreaMix(TemplateID, "rockies_snow");
	rmSetAreaCoherence(TemplateID, 0.80);
	rmSetAreaSmoothDistance(TemplateID, 12+4*PlayerNum);
	rmSetAreaLocation(TemplateID, 0.50, 0.56);
	rmBuildArea(TemplateID);
	
	int avoidTemplate = rmCreateAreaDistanceConstraint("avoid sea east template", TemplateID, 1.5);

	// Sea east
	int seaEastID = rmCreateArea("sea east");
	rmSetAreaObeyWorldCircleConstraint(seaEastID, false);
	rmSetAreaSize(seaEastID, 0.24, 0.24);
	rmSetAreaLocation(seaEastID, 0.50, 0.00);
	rmAddAreaInfluenceSegment(seaEastID, 1.00, 0.16, 0.50, 0.04);
	rmAddAreaInfluenceSegment(seaEastID, 0.00, 0.16, 0.50, 0.04);
	if (isWinterSeason == true) {
		rmSetAreaWaterType(seaEastID, "great lakes ice");
	} else {
		rmSetAreaWaterType(seaEastID, "caribbean coast");
	}
	rmSetAreaCoherence(seaEastID, 0.75);
	rmSetAreaSmoothDistance(seaEastID, 12+4*PlayerNum);
//	rmSetAreaEdgeFilling(seaEastID, 0.5);
	rmAddAreaConstraint(seaEastID, avoidTemplate);
	rmBuildArea(seaEastID);
	
	int avoidSeaEast = rmCreateAreaDistanceConstraint("avoid sea east", seaEastID, 6.0);
	int avoidSeaEastMed = rmCreateAreaDistanceConstraint("avoid sea east med", seaEastID, 24.0);
	int avoidSeaEastFar = rmCreateAreaDistanceConstraint("avoid sea east far", seaEastID, 40.0);
	int avoidSeaEastCoast = rmCreateAreaDistanceConstraint("avoid sea east coast to coast", seaEastID, (rmZFractionToTiles(0.50)));
	int stayNearSeaEast = rmCreateAreaMaxDistanceConstraint("stay near sea east", seaEastID, 32.0+4*PlayerNum);
	
	// ****************************************** TRADE ROUTE **********************************************
	if (TeamNum == 2)
	{
		int tradeRouteID = rmCreateTradeRoute();
		int socketID=rmCreateObjectDef("sockets to dock Trade Posts");
		rmAddObjectDefItem(socketID, "SocketTradeRoute", 1, 0.0);
	//	rmAddObjectDefConstraint(socketID, avoidImpassableLandShort);
		rmSetObjectDefAllowOverlap(socketID, true);
		if (TRvariation == 3 && PlayerNum == 2)
		{
			rmSetObjectDefMinDistance(socketID, 0.0);
			rmSetObjectDefMaxDistance(socketID, 0.0);
		}
		else
		{
			rmSetObjectDefMinDistance(socketID, 4.0);
			rmSetObjectDefMaxDistance(socketID, 10.0);
		}
	//	rmAddObjectDefConstraint(socketID, avoidPlayerArea1);
	//	rmAddObjectDefConstraint(socketID, avoidPlayerArea2);
	
		if (TRvariation == 1) // along coastline
		{	
			if (PlayerNum == 2) 
			{
				rmAddTradeRouteWaypoint(tradeRouteID, 0.10, 0.415);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.30, 0.40);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.50, 0.425);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.70, 0.40);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.90, 0.415);
			}
			else
			{
				rmAddTradeRouteWaypoint(tradeRouteID, 0.00, 0.48);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.20, 0.40);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.50, 0.35);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.80, 0.40);
				rmAddTradeRouteWaypoint(tradeRouteID, 1.00, 0.48);			
			}
		}
		else if (TRvariation == 2) // mainly along coastline 
		{	
			rmAddTradeRouteWaypoint(tradeRouteID, 0.00, 0.65);
			if (PlayerNum == 2)
				rmAddTradeRouteWaypoint(tradeRouteID, 0.20, 0.365);
			else
				rmAddTradeRouteWaypoint(tradeRouteID, 0.20, 0.33);
			rmAddTradeRouteWaypoint(tradeRouteID, 0.50, 0.30);
			if (PlayerNum == 2)
				rmAddTradeRouteWaypoint(tradeRouteID, 0.80, 0.365);
			else
				rmAddTradeRouteWaypoint(tradeRouteID, 0.80, 0.33);
			rmAddTradeRouteWaypoint(tradeRouteID, 1.00, 0.65);
		}
		else if (TRvariation == 3) // mainly along swamp 
		{	
			if (PlayerNum == 2) 
			{
				rmAddTradeRouteWaypoint(tradeRouteID, 0.10, 0.60);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.30, 0.65);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.50, 0.60);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.70, 0.65);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.90, 0.60);
			}
			else
			{
				rmAddTradeRouteWaypoint(tradeRouteID, 0.00, 0.55);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.20, 0.64);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.50, 0.60);
				rmAddTradeRouteWaypoint(tradeRouteID, 0.80, 0.64);
				rmAddTradeRouteWaypoint(tradeRouteID, 1.00, 0.55);
			}
		}
		else if (TRvariation == 4) // along swamp - FFA only 
		{	
			rmAddTradeRouteWaypoint(tradeRouteID, 0.05, 0.84);
			rmAddTradeRouteWaypoint(tradeRouteID, 0.20, 0.68);
			rmAddTradeRouteWaypoint(tradeRouteID, 0.50, 0.60);
			rmAddTradeRouteWaypoint(tradeRouteID, 0.80, 0.68);
			rmAddTradeRouteWaypoint(tradeRouteID, 0.95, 0.84);
		}
		
		bool placedTradeRoute =	rmBuildTradeRoute(tradeRouteID, "dirt");
		if(placedTradeRoute == false)
		rmEchoError("Failed to place trade route");
		rmSetObjectDefTradeRouteID(socketID, tradeRouteID);
		
		if (PlayerNum <= 2)
		{
			vector socketLoc = rmGetTradeRouteWayPoint(tradeRouteID, 0.03);
			if (TRvariation == 3)
				rmPlaceObjectDefAtLoc(socketID, 0, 0.08, 0.63);
			else
				rmPlaceObjectDefAtPoint(socketID, 0, socketLoc);

			socketLoc = rmGetTradeRouteWayPoint(tradeRouteID, 0.38);
			if (TRvariation == 3)
				rmPlaceObjectDefAtLoc(socketID, 0, 0.40, 0.55);
			else
				rmPlaceObjectDefAtPoint(socketID, 0, socketLoc);

			socketLoc = rmGetTradeRouteWayPoint(tradeRouteID, 0.62);
			if (TRvariation == 3)
				rmPlaceObjectDefAtLoc(socketID, 0, 0.60, 0.55);
			else
				rmPlaceObjectDefAtPoint(socketID, 0, socketLoc);

			socketLoc = rmGetTradeRouteWayPoint(tradeRouteID, 0.97);
			if (TRvariation == 3)
				rmPlaceObjectDefAtLoc(socketID, 0, 0.92, 0.63);
			else
				rmPlaceObjectDefAtPoint(socketID, 0, socketLoc);
		}
		else
		{
			socketLoc = rmGetTradeRouteWayPoint(tradeRouteID, 0.10);
			rmPlaceObjectDefAtPoint(socketID, 0, socketLoc);
			socketLoc = rmGetTradeRouteWayPoint(tradeRouteID, 0.30);
			rmPlaceObjectDefAtPoint(socketID, 0, socketLoc);
			socketLoc = rmGetTradeRouteWayPoint(tradeRouteID, 0.50);
			rmPlaceObjectDefAtPoint(socketID, 0, socketLoc);
			socketLoc = rmGetTradeRouteWayPoint(tradeRouteID, 0.70);
			rmPlaceObjectDefAtPoint(socketID, 0, socketLoc);
			socketLoc = rmGetTradeRouteWayPoint(tradeRouteID, 0.90);
			rmPlaceObjectDefAtPoint(socketID, 0, socketLoc);
		}
	}
	// *********************************************************************************************************

	// Swamp area
	int swampAreaID = rmCreateArea("swamp area");
	rmSetAreaObeyWorldCircleConstraint(swampAreaID, false);
	rmSetAreaSize(swampAreaID, 0.14, 0.14);
	rmSetAreaLocation(swampAreaID, 0.50, 1.00);
	rmAddAreaInfluenceSegment(swampAreaID, 0.22, 1.00, 0.50, 0.85);
	rmAddAreaInfluenceSegment(swampAreaID, 0.78, 1.00, 0.50, 0.85);
	rmSetAreaBaseHeight(swampAreaID, 2.0);
	if (isWinterSeason == true) {
		rmSetAreaMix(swampAreaID, "great_lakes_ice");
		rmSetAreaEdgeFilling(swampAreaID, 0.5);
	} else {
		rmSetAreaWaterType(swampAreaID, "bayou skirmish2");		// bayou 
	}
	rmSetAreaCoherence(swampAreaID, 0.50);
	rmSetAreaSmoothDistance(swampAreaID, 6+2*PlayerNum);
//	rmSetAreaEdgeFilling(swampAreaID, 0.5);
	rmAddAreaConstraint(swampAreaID, avoidSeaEastCoast);
	rmAddAreaConstraint(swampAreaID, avoidClassPlayer);
	rmAddAreaConstraint(swampAreaID, avoidTradeRouteShort);
	rmAddAreaConstraint(swampAreaID, avoidTradeRouteSocket);
	rmBuildArea(swampAreaID);
	
	int avoidswampArea = rmCreateAreaDistanceConstraint("avoid swamp area", swampAreaID, 2.0);
	int stayNearswampArea = rmCreateAreaMaxDistanceConstraint("stay near swamp area", swampAreaID, 20.0+8*PlayerNum);
	int stayNearerswampArea = rmCreateAreaMaxDistanceConstraint("stay nearer swamp area", swampAreaID, 6.0+2*PlayerNum);
	int stayInswampArea = rmCreateAreaMaxDistanceConstraint("stay in swamp area", swampAreaID, 0.0);	

	if (isWinterSeason == false) {
		// caribbean7 terrain
		int crb7ID = rmCreateArea("caribbean ground7 terrain");
		rmSetAreaObeyWorldCircleConstraint(crb7ID, false);
		rmSetAreaSize(crb7ID, 0.42, 0.42);
		rmSetAreaLocation(crb7ID, 0.60, 0.40);
	//	rmSetAreaCoherence(crb7ID, 0.80);
	//	rmSetAreaSmoothDistance(crb7ID, 7+2*PlayerNum);
	//	rmSetAreaMix(crb7ID, "caribbean grass");
		rmSetAreaTerrainType(crb7ID, "caribbean\ground7_crb");
	//	rmAddAreaTerrainLayer(crb7ID, "caribbean\ground7_crb", 0, 10);
		rmAddAreaConstraint(crb7ID, avoidImpassableLandMed);
	//	rmAddAreaConstraint(crb7ID, stayNearSeaEast);
		rmSetAreaWarnFailure(crb7ID, false);
		rmBuildArea(crb7ID);

		int avoidcrb7 = rmCreateAreaDistanceConstraint("avoid crb7", crb7ID, 1.0);
		int StayNearcrb7 = rmCreateAreaMaxDistanceConstraint("stay near crb7", crb7ID, 6.0+2*PlayerNum);
		int StayIncrb7 = rmCreateAreaMaxDistanceConstraint("stay in crb7", crb7ID, 0.0);


		// caribbean7 patches
		for (i=0; < 5+8*PlayerNum)
		{
			int patchID = rmCreateArea("caribbean ground1 patch"+i);
			rmSetAreaObeyWorldCircleConstraint(patchID, false);
			rmSetAreaWarnFailure(patchID, false);
			rmSetAreaSize(patchID, rmAreaTilesToFraction(70), rmAreaTilesToFraction(90));
			rmSetAreaTerrainType(patchID, "bayou\ground1_bay"); //caribbean\ground6_crb
			rmAddAreaToClass(patchID, rmClassID("patch"));
			rmSetAreaMinBlobs(patchID, 1);
			rmSetAreaMaxBlobs(patchID, 5);
			rmSetAreaMinBlobDistance(patchID, 16.0);
			rmSetAreaMaxBlobDistance(patchID, 30.0);
			rmSetAreaCoherence(patchID, 0.0);
			rmSetAreaSmoothDistance(patchID, 1);
			rmAddAreaConstraint(patchID, StayIncrb7);
			rmAddAreaConstraint(patchID, avoidPatch);
			rmAddAreaConstraint(patchID, avoidWaterFar);
			rmBuildArea(patchID);
		}


		// caribbean2 patches
		for (i=0; < 5+5*PlayerNum)
		{
			int patch2ID = rmCreateArea("caribbean ground2 patch"+i);
			rmSetAreaObeyWorldCircleConstraint(patch2ID, false);
			rmSetAreaWarnFailure(patch2ID, false);
			rmSetAreaSize(patch2ID, rmAreaTilesToFraction(35), rmAreaTilesToFraction(50));
			rmSetAreaTerrainType(patch2ID, "caribbean\ground2_crb");
			rmAddAreaToClass(patch2ID, rmClassID("patch2"));
			rmSetAreaMinBlobs(patch2ID, 1);
			rmSetAreaMaxBlobs(patch2ID, 4);
			rmSetAreaMinBlobDistance(patch2ID, 10.0);
			rmSetAreaMaxBlobDistance(patch2ID, 20.0);
			rmSetAreaCoherence(patch2ID, 0.0);
			rmSetAreaSmoothDistance(patch2ID, 1);
			rmAddAreaConstraint(patch2ID, StayNearcrb7);
			rmAddAreaConstraint(patch2ID, stayNearWater);
			rmAddAreaConstraint(patch2ID, avoidPatch2);
			rmBuildArea(patch2ID);
		}


		// bayou1 terrain
		int bay1ID = rmCreateArea("bayou ground1 terrain");
		rmSetAreaObeyWorldCircleConstraint(bay1ID, false);
		rmSetAreaSize(bay1ID, 0.30, 0.30);
	//	rmSetAreaCoherence(bay1ID, 0.70);
		rmSetAreaSmoothDistance(bay1ID, 1);
		rmSetAreaTerrainType(bay1ID, "bayou\ground1_bay");
	//	rmAddAreaTerrainLayer(bay1ID, "caribbean\ground7_crb", 0, 10);
		rmAddAreaConstraint(bay1ID, avoidImpassableLandMin);
		rmAddAreaConstraint(bay1ID, stayNearswampArea);
		rmSetAreaWarnFailure(bay1ID, false);
		rmBuildArea(bay1ID);

		int avoidbay1 = rmCreateAreaDistanceConstraint("avoid bay1", bay1ID, 1.0);
		int avoidbay1Short = rmCreateAreaDistanceConstraint("avoid bay1 short", bay1ID, 5.0);
		int avoidbay1Far = rmCreateAreaDistanceConstraint("avoid bay1 far", bay1ID, 8.0);
		int StayNearbay1 = rmCreateAreaMaxDistanceConstraint("stay near bay1", bay1ID, 8.0+2*PlayerNum);
		int StayNearbay1loose = rmCreateAreaMaxDistanceConstraint("stay near bay1 loose", bay1ID, 16.0+2*PlayerNum);
		int StayInbay1 = rmCreateAreaMaxDistanceConstraint("stay in bay1", bay1ID, 0.0);


		// bayou1 patches
		for (i=0; < 4+4*PlayerNum)
		{
			int patch3ID = rmCreateArea("bayou ground1 patch"+i);
			rmSetAreaObeyWorldCircleConstraint(patch3ID, false);
			rmSetAreaWarnFailure(patch3ID, false);
			rmSetAreaSize(patch3ID, rmAreaTilesToFraction(70), rmAreaTilesToFraction(100));
			rmSetAreaTerrainType(patch3ID, "bayou\ground1_bay");
			rmAddAreaToClass(patch3ID, rmClassID("patch3"));
			rmSetAreaMinBlobs(patch3ID, 1);
			rmSetAreaMaxBlobs(patch3ID, 4);
			rmSetAreaMinBlobDistance(patch3ID, 8.0);
			rmSetAreaMaxBlobDistance(patch3ID, 26.0);
			rmSetAreaCoherence(patch3ID, 0.0);
			rmSetAreaSmoothDistance(patch3ID, 2);
			rmAddAreaConstraint(patch3ID, StayNearcrb7);
			rmAddAreaConstraint(patch3ID, StayNearbay1);
			rmAddAreaConstraint(patch3ID, avoidPatch3);
			rmBuildArea(patch3ID);
		}

		// bayou1 patches more
		for (i=0; < 3+3*PlayerNum)
		{
			int patch3bID = rmCreateArea("bayou ground1 patch more"+i);
			rmSetAreaObeyWorldCircleConstraint(patch3bID, false);
			rmSetAreaWarnFailure(patch3bID, false);
			rmSetAreaSize(patch3bID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(55));
			rmSetAreaTerrainType(patch3bID, "bayou\ground1_bay");
			rmAddAreaToClass(patch3bID, rmClassID("patch3"));
			rmSetAreaMinBlobs(patch3bID, 1);
			rmSetAreaMaxBlobs(patch3bID, 4);
			rmSetAreaMinBlobDistance(patch3bID, 8.0);
			rmSetAreaMaxBlobDistance(patch3bID, 26.0);
			rmSetAreaCoherence(patch3bID, 0.0);
			rmSetAreaSmoothDistance(patch3bID, 2);
			rmAddAreaConstraint(patch3bID, StayIncrb7);
			rmAddAreaConstraint(patch3bID, StayNearbay1loose);
			rmAddAreaConstraint(patch3bID, avoidPatch3);
			rmBuildArea(patch3bID);
		}


		// caribbean7 patches
		for (i=0; < 4+4*PlayerNum)
		{
			int patch4ID = rmCreateArea("caribbean ground7 muddy patch"+i);
			rmSetAreaObeyWorldCircleConstraint(patch4ID, false);
			rmSetAreaWarnFailure(patch4ID, false);
			rmSetAreaSize(patch4ID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(70));
			rmSetAreaTerrainType(patch4ID, "caribbean\ground7_crb"); // ground7_crb
			rmAddAreaToClass(patch4ID, rmClassID("patch4"));
			rmSetAreaMinBlobs(patch4ID, 1);
			rmSetAreaMaxBlobs(patch4ID, 5);
			rmSetAreaMinBlobDistance(patch4ID, 16.0);
			rmSetAreaMaxBlobDistance(patch4ID, 28.0);
			rmSetAreaCoherence(patch4ID, 0.0);
	//		rmSetAreaSmoothDistance(patch4ID, 1);
			rmAddAreaConstraint(patch4ID, StayNearbay1);
			rmAddAreaConstraint(patch4ID, StayNearcrb7);
			rmAddAreaConstraint(patch4ID, avoidPatch4);
			rmAddAreaConstraint(patch4ID, avoidImpassableLand);
			rmBuildArea(patch4ID);
		}
	}
	
		
	//Everglade islands
	int islandcount = 3+3*PlayerNum;
	
	for (i=0; < islandcount)
	{
		int islandID=rmCreateArea("everglade island"+i);
		rmSetAreaObeyWorldCircleConstraint(islandID, false);
		rmSetAreaSize(islandID, rmAreaTilesToFraction(250+5*PlayerNum));
		if (isWinterSeason == true) {
			rmSetAreaTerrainType(islandID, "yukon\ground2_yuk");
		} else {
			rmSetAreaMix(islandID, "bayou_grass_skirmish");
//			rmSetAreaTerrainType(islandID, "bayou\ground1_bay");
		}
		rmAddAreaToClass(islandID, classIsland);
		rmSetAreaBaseHeight(islandID, 3.0);
//		rmSetAreaHeightBlend(islandID, 1.0);
		rmSetAreaCoherence(islandID, 0.01);
		rmSetAreaSmoothDistance(islandID, 8);   
		rmAddAreaConstraint(islandID, avoidIsland);
		rmAddAreaConstraint(islandID, avoidSeaEast);
		rmAddAreaConstraint(islandID, avoidLand);
		if (isWinterSeason == false) {
			rmAddAreaConstraint(islandID, avoidbay1Far);
			rmAddAreaConstraint(islandID, avoidcrb7);
		}
//		rmAddAreaConstraint(islandID, avoidEdge);
        rmSetAreaWarnFailure(islandID, false);
		rmBuildArea(islandID);
	
	}

	
	// Players area
	for (i=1; < numPlayer)
	{
		int playerareaID = rmCreateArea("playerarea"+i);
		rmSetPlayerArea(i, playerareaID);
		rmSetAreaSize(playerareaID,rmAreaTilesToFraction(400), rmAreaTilesToFraction(400));
		rmSetAreaCoherence(playerareaID, 1.0);
		rmSetAreaWarnFailure(playerareaID, false);
//		rmSetAreaTerrainType(playerareaID, "new_england\ground2_cliff_ne"); // for testing
		rmSetAreaLocPlayer(playerareaID, i);
		rmSetAreaObeyWorldCircleConstraint(playerareaID, false);
		rmAddAreaToClass(playerareaID, rmClassID("player"));
		rmBuildArea(playerareaID);
		int avoidPlayerArea = rmCreateAreaDistanceConstraint("avoid player area "+i, playerareaID, 2.0);
		int stayPlayerArea = rmCreateAreaMaxDistanceConstraint("stay in player area "+i, playerareaID, 0.0);
	}
	
	int avoidPlayerArea1 = rmConstraintID("avoid player area 1");
	int avoidPlayerArea2 = rmConstraintID("avoid player area 2");
	int stayInPlayerArea1 = rmConstraintID("stay in player area 1");
	int stayInPlayerArea2 = rmConstraintID("stay in player area 2");	
	
	// *****************************************************************************************************
	
	// Text
	rmSetStatusText("",0.40);

	// ------------------------------------------------------ KOTH ---------------------------------------------------------------------
	if (rmGetIsKOTH() == true) {

		int randLoc = rmRandInt(1,3);
		float xLoc = 0.5;
		float yLoc = 0.5;
		float walk = 0.0;

		if (randLoc == 2) {
			xLoc = 0.5;
			yLoc = 0.85;
			ypKingsHillLandfill(xLoc, yLoc, 0.02, 2.0, "bayou_grass_skirmish", 0);
		} else if (randLoc == 3) {
			xLoc = 0.5;
			yLoc = 0.08;
			ypKingsHillLandfill(xLoc, yLoc, 0.007, 2.0, "caribbean grass", 0);
		}

		ypKingsHillPlacer(xLoc, yLoc, walk, 0);
		rmEchoInfo("XLOC = "+xLoc);
		rmEchoInfo("XLOC = "+yLoc);
	}

		int avoidKOTH = rmCreateTypeDistanceConstraint("avoid koth", "ypKingsHill", 16.0);
		int avoidKOTHLand = rmCreateTypeDistanceConstraint("avoid koth land", "ypKingsHill", 4.0);

	// ****************************************************************************************************
	// Text
	rmSetStatusText("",0.50);
	
	// ******************************************** NATIVES *************************************************
	
    int nativeID1 = -1;
	int nativeID2 = -1;
    int nativeID3 = -1;
	int nativeID4 = -1;	
	int nativeID5 = -1;	
	
	int natArea1 = -1;
	int natArea2 = -1;
	int natArea3 = -1;
	int natArea4 = -1;
	int natArea5 = -1;
	
	nativeID1 = rmCreateGrouping("Seminole village A", "native seminole village "+3); // 2
    rmSetGroupingMinDistance(nativeID1, 0.00);
    rmSetGroupingMaxDistance(nativeID1, 0.00);
//	rmAddGroupingConstraint(nativeID1, avoidImpassableLand);
	rmAddGroupingToClass(nativeID1, rmClassID("natives"));
		
	nativeID2 = rmCreateGrouping("Seminole village B", "native seminole village "+3); // 3
    rmSetGroupingMinDistance(nativeID2, 0.00);
    rmSetGroupingMaxDistance(nativeID2, 0.00);
//	rmAddGroupingConstraint(nativeID2, avoidImpassableLand);
	rmAddGroupingToClass(nativeID2, rmClassID("natives"));
	
	nativeID3 = rmCreateGrouping("carib village A", "native carib village 0"+3); //5
    rmSetGroupingMinDistance(nativeID3, 0.00);
    rmSetGroupingMaxDistance(nativeID3, 0.00);
//	rmAddGroupingConstraint(nativeID3, avoidImpassableLand);
	rmAddGroupingToClass(nativeID3, rmClassID("natives"));
	
	nativeID4 = rmCreateGrouping("carib village B", "native carib village 0"+3); //4
    rmSetGroupingMinDistance(nativeID4, 0.00);
    rmSetGroupingMaxDistance(nativeID4, 0.00);
//	rmAddGroupingConstraint(nativeID4, avoidImpassableLand);
	rmAddGroupingToClass(nativeID4, rmClassID("natives"));
	
	nativeID5 = rmCreateGrouping("carib village C", "native carib village "+3); //4
    rmSetGroupingMinDistance(nativeID5, 0.00);
    rmSetGroupingMaxDistance(nativeID5, 0.00);
//	rmAddGroupingConstraint(nativeID5, avoidImpassableLand);
	rmAddGroupingToClass(nativeID5, rmClassID("natives"));
	
	natArea1 = rmCreateArea("native area 1");
	rmSetAreaSize(natArea1,rmAreaTilesToFraction(270), rmAreaTilesToFraction(270));
	rmSetAreaCoherence(natArea1, 0.75);
	rmSetAreaWarnFailure(natArea1, false);
	if (isWinterSeason == true) {
		rmSetAreaTerrainType(natArea1, "yukon\ground2_yuk");
	} else {
		rmSetAreaTerrainType(natArea1, "bayou\ground3_bay");
		rmAddAreaTerrainLayer(natArea1, "bayou\ground1_bay", 0, 1);
		rmAddAreaTerrainLayer(natArea1, "bayou\ground2_bay", 2, 4);
	}
	rmSetAreaObeyWorldCircleConstraint(natArea1, false);
	
	natArea2 = rmCreateArea("native area 2");
	rmSetAreaSize(natArea2,rmAreaTilesToFraction(270), rmAreaTilesToFraction(270));
	rmSetAreaCoherence(natArea2, 0.75);
	rmSetAreaWarnFailure(natArea2, false);
	if (isWinterSeason == true) {
		rmSetAreaTerrainType(natArea2, "yukon\ground2_yuk");
	} else {
		rmSetAreaTerrainType(natArea2, "bayou\ground3_bay");
		rmAddAreaTerrainLayer(natArea2, "bayou\ground1_bay", 0, 1);
		rmAddAreaTerrainLayer(natArea2, "bayou\ground2_bay", 2, 4);
	}
	rmSetAreaObeyWorldCircleConstraint(natArea2, false);
	
	natArea3 = rmCreateArea("native area 3");
	rmSetAreaSize(natArea3,rmAreaTilesToFraction(260), rmAreaTilesToFraction(260));
	rmSetAreaCoherence(natArea3, 0.75);
	rmSetAreaWarnFailure(natArea3, false);
	if (isWinterSeason == true) {
		rmSetAreaTerrainType(natArea3, "yukon\ground2_yuk");
	} else {
		rmSetAreaTerrainType(natArea3, "caribbean\ground3_crb");
		rmAddAreaTerrainLayer(natArea3, "caribbean\ground2_crb", 0, 2);
	}
	rmSetAreaObeyWorldCircleConstraint(natArea3, false);
	
	natArea4 = rmCreateArea("native area 4");
	rmSetAreaSize(natArea4,rmAreaTilesToFraction(260), rmAreaTilesToFraction(260));
	rmSetAreaCoherence(natArea4, 0.75);
	rmSetAreaWarnFailure(natArea4, false);
	if (isWinterSeason == true) {
		rmSetAreaTerrainType(natArea4, "yukon\ground2_yuk");
	} else {
		rmSetAreaTerrainType(natArea4, "caribbean\ground3_crb");
		rmAddAreaTerrainLayer(natArea4, "caribbean\ground2_crb", 0, 2);
	}
	rmSetAreaObeyWorldCircleConstraint(natArea4, false);
	
	natArea5 = rmCreateArea("native area 5");
	rmSetAreaSize(natArea5,rmAreaTilesToFraction(270), rmAreaTilesToFraction(270));
	rmSetAreaCoherence(natArea5, 0.75);
	rmSetAreaWarnFailure(natArea5, false);
	if (isWinterSeason == true) {
		rmSetAreaTerrainType(natArea5, "yukon\ground2_yuk");
	} else {
		rmSetAreaTerrainType(natArea5, "bayou\ground3_bay");
		rmAddAreaTerrainLayer(natArea5, "bayou\ground1_bay", 0, 1);
		rmAddAreaTerrainLayer(natArea5, "bayou\ground2_bay", 2, 4);
	}
	rmSetAreaObeyWorldCircleConstraint(natArea5, false);
	
		
	if (TeamNum <= 2)
	{
		if (PlayerNum <= 2)
		{
			if (TRvariation == 1)
			{
				rmPlaceGroupingAtLoc(nativeID1, 0, 0.14, 0.72);
				rmPlaceGroupingAtLoc(nativeID2, 0, 0.86, 0.72);
				rmPlaceGroupingAtLoc(nativeID5, 0, 0.50, 0.60);
				rmSetAreaLocation(natArea1, 0.14, 0.72);
				rmBuildArea(natArea1);
				rmSetAreaLocation(natArea2, 0.86, 0.72);
				rmBuildArea(natArea2);
				rmSetAreaLocation(natArea5, 0.50, 0.60);
				rmBuildArea(natArea5);
			}	
			else if (TRvariation == 2)
			{	
				rmPlaceGroupingAtLoc(nativeID3, 0, 0.10, 0.40);
				rmPlaceGroupingAtLoc(nativeID4, 0, 0.90, 0.40);
				rmPlaceGroupingAtLoc(nativeID1, 0, 0.50, 0.62);
				rmSetAreaLocation(natArea3, 0.10, 0.40);
				rmBuildArea(natArea3);
				rmSetAreaLocation(natArea4, 0.90, 0.40);
				rmBuildArea(natArea4);
				rmSetAreaLocation(natArea1, 0.50, 0.62);
				rmBuildArea(natArea1);
			}	
			else
			{	
				rmPlaceGroupingAtLoc(nativeID1, 0, 0.14, 0.74);
				rmPlaceGroupingAtLoc(nativeID2, 0, 0.86, 0.74);
				rmPlaceGroupingAtLoc(nativeID3, 0, 0.50, 0.34);
				rmSetAreaLocation(natArea1,  0.14, 0.74);
				rmBuildArea(natArea1);
				rmSetAreaLocation(natArea2,  0.86, 0.74);
				rmBuildArea(natArea2);
				rmSetAreaLocation(natArea3,  0.50, 0.34);
				rmBuildArea(natArea3);
			}	
		}	
		else
		{	
			if (TRvariation == 1) 
			{	
				rmPlaceGroupingAtLoc(nativeID1, 0, 0.14, 0.72);
				rmPlaceGroupingAtLoc(nativeID2, 0, 0.86, 0.72);
				rmPlaceGroupingAtLoc(nativeID3, 0, 0.40, 0.30);
				rmPlaceGroupingAtLoc(nativeID4, 0, 0.60, 0.30);
				rmSetAreaLocation(natArea1, 0.14, 0.72);
				rmBuildArea(natArea1);
				rmSetAreaLocation(natArea2, 0.86, 0.72);
				rmBuildArea(natArea2);
				rmSetAreaLocation(natArea3, 0.40, 0.30);
				rmBuildArea(natArea3);
				rmSetAreaLocation(natArea4, 0.60, 0.30);
				rmBuildArea(natArea4);
			}	
			else if (TRvariation == 2)
			{	
				rmPlaceGroupingAtLoc(nativeID3, 0, 0.10, 0.40);
				rmPlaceGroupingAtLoc(nativeID4, 0, 0.90, 0.40);
				rmPlaceGroupingAtLoc(nativeID1, 0, 0.40, 0.62);
				rmPlaceGroupingAtLoc(nativeID2, 0, 0.60, 0.62);
				rmSetAreaLocation(natArea3, 0.10, 0.40);
				rmBuildArea(natArea3);
				rmSetAreaLocation(natArea4, 0.90, 0.40);
				rmBuildArea(natArea4);
				rmSetAreaLocation(natArea1, 0.40, 0.62);
				rmBuildArea(natArea1);
				rmSetAreaLocation(natArea2, 0.60, 0.62);
				rmBuildArea(natArea2);
			}	
			else
			{	
				rmPlaceGroupingAtLoc(nativeID1, 0, 0.14, 0.72);
				rmPlaceGroupingAtLoc(nativeID2, 0, 0.86, 0.72);
				rmPlaceGroupingAtLoc(nativeID3, 0, 0.40, 0.34);
				rmPlaceGroupingAtLoc(nativeID4, 0, 0.60, 0.34);
				rmSetAreaLocation(natArea1,  0.14, 0.72);
				rmBuildArea(natArea1);
				rmSetAreaLocation(natArea2,  0.86, 0.72);
				rmBuildArea(natArea2);
				rmSetAreaLocation(natArea3,  0.40, 0.34);
				rmBuildArea(natArea3);
				rmSetAreaLocation(natArea4,  0.60, 0.34);
				rmBuildArea(natArea4);
			}	
		}	
	}
	else if (PlayerNum <= 3)
	{
		rmPlaceGroupingAtLoc(nativeID3, 0, 0.10, 0.40);
		rmPlaceGroupingAtLoc(nativeID4, 0, 0.90, 0.40);
		rmPlaceGroupingAtLoc(nativeID1, 0, 0.50, 0.50);
		rmSetAreaLocation(natArea3, 0.10, 0.40);
		rmBuildArea(natArea3);
		rmSetAreaLocation(natArea4, 0.90, 0.40);
		rmBuildArea(natArea4);
		rmSetAreaLocation(natArea1, 0.50, 0.50);
		rmBuildArea(natArea1);
	}	
	else
	{	
		rmPlaceGroupingAtLoc(nativeID3, 0, 0.10, 0.38);
		rmPlaceGroupingAtLoc(nativeID4, 0, 0.90, 0.38);
		rmPlaceGroupingAtLoc(nativeID1, 0, 0.38, 0.50);
		rmPlaceGroupingAtLoc(nativeID2, 0, 0.62, 0.50);
		rmSetAreaLocation(natArea3, 0.10, 0.38);
		rmBuildArea(natArea3);
		rmSetAreaLocation(natArea4, 0.90, 0.38);
		rmBuildArea(natArea4);
		rmSetAreaLocation(natArea1, 0.36, 0.50);
		rmBuildArea(natArea1);
		rmSetAreaLocation(natArea2, 0.64, 0.50);
		rmBuildArea(natArea2);
	}	
	
	// ******************************************************************************************************

	// Text
	rmSetStatusText("",0.55);
	
	// ************************************ PLAYER STARTING RESOURCES ***************************************

	// ******** Define ********

	// Town center & units
	int TCID = rmCreateObjectDef("player TC");
	int startingUnits = rmCreateStartingUnitsObjectDef(5.0);
	if (rmGetNomadStart())
	{
		rmAddObjectDefItem(TCID, "CoveredWagon", 1, 0.0);
	}
	else
	{
	rmAddObjectDefItem(TCID, "TownCenter", 1, 0.0);
	}
	rmAddObjectDefToClass(TCID, classStartingResource);
	rmSetObjectDefMinDistance(TCID, 0.0);
	rmSetObjectDefMaxDistance(TCID, 0.0);
    
//    if(cNumberNonGaiaPlayers>4){
//       rmSetObjectDefMaxDistance(TCID, 14.0);
//   }
    int teamZeroCount_dk = rmGetNumberPlayersOnTeam(0);
    int teamOneCount_dk = rmGetNumberPlayersOnTeam(1);
    if((cNumberTeams == 2) && (teamZeroCount_dk != teamOneCount_dk)){
        rmSetObjectDefMaxDistance(TCID, 10.0);
    }

if (rmGetNomadStart() == false) {
	if (TeamNum == 2 && teamZeroCount_dk <= 3 && teamOneCount_dk <= 3) {	
		// Starting asian market
		int startingAsianMarketFairLocID = -1;
			startingAsianMarketFairLocID = rmAddFairLoc("starting asian market", true, false, 22, 22, 0, 0);
		if(rmPlaceFairLocs()){
		int playerAsianMarketID=rmCreateObjectDef("starting asian market");
		rmAddObjectDefItem(playerAsianMarketID, "ypTradeMarketAsian", 1, 0.0);
		rmAddObjectDefToClass(playerAsianMarketID, classStartingResource);
		rmAddObjectDefConstraint(playerAsianMarketID, avoidStartingResources);
		rmAddObjectDefConstraint(playerAsianMarketID, avoidTradeRoute);
		for(i=1; <cNumberPlayers){
				for(j=0; <rmGetNumberFairLocs(i)){
					if (rmGetPlayerCiv(i) == rmGetCivID("Chinese") || rmGetPlayerCiv(i) == rmGetCivID("Japanese") || rmGetPlayerCiv(i) == rmGetCivID("Indians")) 
						rmPlaceObjectDefAtLoc(playerAsianMarketID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				}
			}
		}
		rmResetFairLocs();

		// Starting african market
		int startingAfricanMarketFairLocID = -1;
			startingAfricanMarketFairLocID = rmAddFairLoc("starting african market", true, false, 22, 22, 0, 0);
		if(rmPlaceFairLocs()){
		int playerAfricanMarketID=rmCreateObjectDef("starting african market");
		rmAddObjectDefItem(playerAfricanMarketID, "deLivestockMarket", 1, 0.0);
		rmAddObjectDefToClass(playerAfricanMarketID, classStartingResource);
		rmAddObjectDefConstraint(playerAfricanMarketID, avoidStartingResources);
		rmAddObjectDefConstraint(playerAfricanMarketID, avoidTradeRoute);
		for(i=1; <cNumberPlayers){
				for(j=0; <rmGetNumberFairLocs(i)){
					if (rmGetPlayerCiv(i) == rmGetCivID("DEEthiopians") || rmGetPlayerCiv(i) == rmGetCivID("DEHausa")) 
						rmPlaceObjectDefAtLoc(playerAfricanMarketID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				}
			}
		}
		rmResetFairLocs();

		// Starting market
		int startingMarketFairLocID = -1;
			startingMarketFairLocID = rmAddFairLoc("starting market", true, false, 22, 22, 0, 0);
		if(rmPlaceFairLocs()){
		int playerMarketID=rmCreateObjectDef("starting market");
		rmAddObjectDefItem(playerMarketID, "Market", 1, 0.0);
		rmAddObjectDefToClass(playerMarketID, classStartingResource);
		rmAddObjectDefConstraint(playerMarketID, avoidStartingResources);
		rmAddObjectDefConstraint(playerMarketID, avoidTradeRoute);
		for(i=1; <cNumberPlayers){
				for(j=0; <rmGetNumberFairLocs(i)){
					if (rmGetPlayerCiv(i) == rmGetCivID("DEMexicans") || rmGetPlayerCiv(i) == rmGetCivID("DEAmericans") || rmGetPlayerCiv(i) == rmGetCivID("British") || rmGetPlayerCiv(i) == rmGetCivID("Spanish") || rmGetPlayerCiv(i) == rmGetCivID("French") || rmGetPlayerCiv(i) == rmGetCivID("Germans") || rmGetPlayerCiv(i) == rmGetCivID("DESwedish") || rmGetPlayerCiv(i) == rmGetCivID("Russians") || rmGetPlayerCiv(i) == rmGetCivID("Portuguese") || rmGetPlayerCiv(i) == rmGetCivID("Dutch") || rmGetPlayerCiv(i) == rmGetCivID("Ottomans") || rmGetPlayerCiv(i) == rmGetCivID("XPIroquois") || rmGetPlayerCiv(i) == rmGetCivID("XPSioux") || rmGetPlayerCiv(i) == rmGetCivID("XPAztec") || rmGetPlayerCiv(i) == rmGetCivID("DEInca") || rmGetPlayerCiv(i) == rmGetCivID("DEItalians") || rmGetPlayerCiv(i) == rmGetCivID("DEMaltese")) 
						rmPlaceObjectDefAtLoc(playerMarketID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				}
			}
		}
		rmResetFairLocs();
	}
	else {
		// Starting market
		int playerMarket2ID=rmCreateObjectDef("starting market2");
		rmAddObjectDefItem(playerMarket2ID, "Market", 1, 1.0);
		rmSetObjectDefMinDistance(playerMarket2ID, 18.0);
		rmSetObjectDefMaxDistance(playerMarket2ID, 24.0);
		rmAddObjectDefConstraint(playerMarket2ID, avoidTradeRoute);
		rmAddObjectDefConstraint(playerMarket2ID, avoidTradeRouteSocket);
		rmAddObjectDefConstraint(playerMarket2ID, avoidImpassableLand);
		rmAddObjectDefConstraint(playerMarket2ID, avoidStartingResources);
		
		// Starting asian market
		int playerAsianMarket2ID=rmCreateObjectDef("starting asian market2");
		rmAddObjectDefItem(playerAsianMarket2ID, "ypTradeMarketAsian", 1, 1.0);
		rmSetObjectDefMinDistance(playerAsianMarket2ID, 18.0);
		rmSetObjectDefMaxDistance(playerAsianMarket2ID, 24.0);
		rmAddObjectDefConstraint(playerAsianMarket2ID, avoidTradeRoute);
		rmAddObjectDefConstraint(playerAsianMarket2ID, avoidTradeRouteSocket);
		rmAddObjectDefConstraint(playerAsianMarket2ID, avoidImpassableLand);
		rmAddObjectDefConstraint(playerAsianMarket2ID, avoidStartingResources);

		// Starting african market
		int playerAfricanMarket2ID=rmCreateObjectDef("starting african market2");
		rmAddObjectDefItem(playerAfricanMarket2ID, "deLivestockMarket", 1, 1.0);
		rmSetObjectDefMinDistance(playerAfricanMarket2ID, 18.0);
		rmSetObjectDefMaxDistance(playerAfricanMarket2ID, 24.0);
		rmAddObjectDefConstraint(playerAfricanMarket2ID, avoidTradeRoute);
		rmAddObjectDefConstraint(playerAfricanMarket2ID, avoidTradeRouteSocket);
		rmAddObjectDefConstraint(playerAfricanMarket2ID, avoidImpassableLand);
		rmAddObjectDefConstraint(playerAfricanMarket2ID, avoidStartingResources);
	}
}

	// Starting mine
	int playergoldID = rmCreateObjectDef("player mine");
	rmAddObjectDefItem(playergoldID, "mine", 1, 0);
	rmSetObjectDefMinDistance(playergoldID, 14.0);
	rmSetObjectDefMaxDistance(playergoldID, 14.0);
	rmAddObjectDefToClass(playergoldID, classStartingResource);
	rmAddObjectDefToClass(playergoldID, classGold);
	rmAddObjectDefConstraint(playergoldID, avoidTradeRouteShort);
	rmAddObjectDefConstraint(playergoldID, avoidTradeRouteSocketShort);
	rmAddObjectDefConstraint(playergoldID, avoidWater);
	rmAddObjectDefConstraint(playergoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(playergoldID, avoidNatives);
	rmAddObjectDefConstraint(playergoldID, avoidGoldTypeMed);
	rmAddObjectDefConstraint(playergoldID, avoidStartingResources);
	
	// 2nd mine
	int playergold2ID = rmCreateObjectDef("player second mine");
	rmAddObjectDefItem(playergold2ID, "minetin", 1, 0);
	rmSetObjectDefMinDistance(playergold2ID, 24.0); //58
	rmSetObjectDefMaxDistance(playergold2ID, 26.0); //62
//	rmAddObjectDefToClass(playergold2ID, classStartingResource);
	rmAddObjectDefToClass(playergold2ID, classGold);
	rmAddObjectDefConstraint(playergold2ID, avoidTradeRouteShort);
	rmAddObjectDefConstraint(playergold2ID, avoidTradeRouteSocketShort);
	rmAddObjectDefConstraint(playergold2ID, avoidImpassableLandMed);
	rmAddObjectDefConstraint(playergold2ID, avoidWater);
	rmAddObjectDefConstraint(playergold2ID, avoidNatives);
	rmAddObjectDefConstraint(playergold2ID, avoidGoldType);
	rmAddObjectDefConstraint(playergold2ID, avoidStartingResources);
	rmAddObjectDefConstraint(playergold2ID, avoidEdge);
		
	// Starting trees
	int playerTreeID = rmCreateObjectDef("player trees");
	if (isWinterSeason == true) {
		rmAddObjectDefItem(playerTreeID, "TreeGreatLakesSnow", rmRandInt(1,1), 0.0);
	} else {
		rmAddObjectDefItem(playerTreeID, "TreeCarolinaGrass", rmRandInt(1,1), 0.0);
	}
    rmSetObjectDefMinDistance(playerTreeID, 14);
    rmSetObjectDefMaxDistance(playerTreeID, 18);
	rmAddObjectDefToClass(playerTreeID, classStartingResource);
	rmAddObjectDefToClass(playerTreeID, classForest);
	rmAddObjectDefConstraint(playerTreeID, avoidTradeRouteShort);
	rmAddObjectDefConstraint(playerTreeID, avoidTradeRouteSocketShort);
    rmAddObjectDefConstraint(playerTreeID, avoidImpassableLand);
	rmAddObjectDefConstraint(playerTreeID, avoidStartingResourcesShort);
	
	// Starting trees2
	int playerTree2ID = rmCreateObjectDef("player trees 2");
	if (isWinterSeason == true) {
		rmAddObjectDefItem(playerTree2ID, "TreeGreatLakesSnow", rmRandInt(2,2), 2.0);
	} else {
		rmAddObjectDefItem(playerTree2ID, "TreeCarolinaGrass", rmRandInt(2,2), 2.0);
	}
    rmSetObjectDefMinDistance(playerTree2ID, 14);
    rmSetObjectDefMaxDistance(playerTree2ID, 18);
	rmAddObjectDefToClass(playerTree2ID, classStartingResource);
	rmAddObjectDefToClass(playerTree2ID, classForest);
	rmAddObjectDefConstraint(playerTree2ID, avoidTradeRouteShort);
	rmAddObjectDefConstraint(playerTree2ID, avoidTradeRouteSocketShort);
    rmAddObjectDefConstraint(playerTree2ID, avoidImpassableLand);
	rmAddObjectDefConstraint(playerTree2ID, avoidStartingResourcesShort);
	
	// Starting herd
	int playerherdID = rmCreateObjectDef("starting turkey");
	rmAddObjectDefItem(playerherdID, "turkey", rmRandInt(8,8), 3.0);
	rmSetObjectDefMinDistance(playerherdID, 12.0);
	rmSetObjectDefMaxDistance(playerherdID, 12.0);
	rmSetObjectDefCreateHerd(playerherdID, true);
	rmAddObjectDefToClass(playerherdID, classStartingResource);
	rmAddObjectDefConstraint(playerherdID, avoidTradeRouteSocketShort);
	rmAddObjectDefConstraint(playerherdID, avoidImpassableLandMed);
	rmAddObjectDefConstraint(playerherdID, avoidNatives);
	rmAddObjectDefConstraint(playerherdID, avoidStartingResourcesShort);
		
	// 2nd herd
	int player2ndherdID = rmCreateObjectDef("starting deer");
	rmAddObjectDefItem(player2ndherdID, "Deer", rmRandInt(10,10), 7.0);
    rmSetObjectDefMinDistance(player2ndherdID, 34);
    rmSetObjectDefMaxDistance(player2ndherdID, 36);
	rmAddObjectDefToClass(player2ndherdID, classStartingResource);
	rmSetObjectDefCreateHerd(player2ndherdID, true);
	rmAddObjectDefConstraint(player2ndherdID, avoidStartingResources);
	rmAddObjectDefConstraint(player2ndherdID, avoidTurkey); 
	rmAddObjectDefConstraint(player2ndherdID, avoidTradeRouteSocketShort);
	rmAddObjectDefConstraint(player2ndherdID, avoidImpassableLandMed);
	rmAddObjectDefConstraint(player2ndherdID, avoidNatives);
		
	// Starting treasures
	int playerNuggetID = rmCreateObjectDef("player nugget"); 
	rmAddObjectDefItem(playerNuggetID, "Nugget", 1, 0.0);
	rmSetNuggetDifficulty(1, 1);
	rmSetObjectDefMinDistance(playerNuggetID, 26.0);
	rmSetObjectDefMaxDistance(playerNuggetID, 28.0);
	rmAddObjectDefToClass(playerNuggetID, classStartingResource);
	rmAddObjectDefConstraint(playerNuggetID, avoidTradeRouteShort);
	rmAddObjectDefConstraint(playerNuggetID, avoidTradeRouteSocketShort);
	rmAddObjectDefConstraint(playerNuggetID, avoidImpassableLandMed);
	rmAddObjectDefConstraint(playerNuggetID, avoidNatives);
	rmAddObjectDefConstraint(playerNuggetID, avoidStartingResourcesShort);
	rmAddObjectDefConstraint(playerNuggetID, avoidNuggetShort); //Short
	rmAddObjectDefConstraint(playerNuggetID, avoidEdge);
	
	// Starting sheep
	int playerSheepID = rmCreateObjectDef("player sheep");
	rmAddObjectDefItem(playerSheepID, "sheep", rmRandInt(1,1), 2.0);
    rmSetObjectDefMinDistance(playerSheepID, 16);
    rmSetObjectDefMaxDistance(playerSheepID, 18);
	rmAddObjectDefConstraint(playerSheepID, avoidTradeRouteSocketShort);
    rmAddObjectDefConstraint(playerSheepID, avoidImpassableLand);
	rmAddObjectDefConstraint(playerSheepID, avoidStartingResourcesShort);
	
/*	// Water spawn flag
	int colonyShipID = 0;
	colonyShipID=rmCreateObjectDef("colony ship "+i);
	rmAddObjectDefItem(colonyShipID, "HomeCityWaterSpawnFlag", 1, 1.0);
	rmSetObjectDefMinDistance(colonyShipID, rmXFractionToMeters(0.0));
	rmSetObjectDefMaxDistance(colonyShipID, rmXFractionToMeters(0.25+0.05*PlayerNum));
	rmAddObjectDefConstraint(colonyShipID, avoidColonyShip);
	rmAddObjectDefConstraint(colonyShipID, avoidLand);
	rmAddObjectDefConstraint(colonyShipID, avoidEdge);
//  vector colonyShipLocation=rmGetUnitPosition(rmGetUnitPlacedOfPlayer(colonyShipID, i));
//  rmSetHomeCityWaterSpawnPoint(i, colonyShipLocation);
      
*/		
	// ******** Place ********
	
	int waterFlagID=-1;

	for(i=1; <numPlayer)
	{
		rmPlaceObjectDefAtLoc(TCID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
		vector TCLoc = rmGetUnitPosition(rmGetUnitPlacedOfPlayer(TCID, i));

		rmPlaceObjectDefAtLoc(startingUnits, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));	
	if (TeamNum == 2 && teamZeroCount_dk <= 3 && teamOneCount_dk <= 3) {	
		if(rmGetNomadStart() == false && rmGetPlayerCiv(i) ==  rmGetCivID("Japanese")) {
				rmPlaceObjectDefAtLoc(ypMonasteryBuilder(i, 1), i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
				}
		}
	else {
		if(rmGetNomadStart() == false) {
			if (rmGetPlayerCiv(i) ==  rmGetCivID("Chinese") || rmGetPlayerCiv(i) == rmGetCivID("Indians"))
				rmPlaceObjectDefAtLoc(playerAsianMarket2ID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
			else if(rmGetPlayerCiv(i) ==  rmGetCivID("Japanese"))
			{
				rmPlaceObjectDefAtLoc(ypMonasteryBuilder(i, 1), i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
				rmPlaceObjectDefAtLoc(playerAsianMarket2ID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));  
			}
			else if(rmGetPlayerCiv(i) ==  rmGetCivID("DEEthiopians") || rmGetPlayerCiv(i) ==  rmGetCivID("DEHausa"))
				rmPlaceObjectDefAtLoc(playerAfricanMarket2ID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
			else 
				rmPlaceObjectDefAtLoc(playerMarket2ID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
			}
		}
		rmPlaceObjectDefAtLoc(playergoldID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
//		rmPlaceObjectDefAtLoc(playergold2ID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
		rmPlaceObjectDefAtLoc(playerherdID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
		rmPlaceObjectDefAtLoc(player2ndherdID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
		rmPlaceObjectDefAtLoc(playerTreeID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
		rmPlaceObjectDefAtLoc(playerTreeID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
		rmPlaceObjectDefAtLoc(playerTree2ID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
		rmPlaceObjectDefAtLoc(playerTreeID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
		rmPlaceObjectDefAtLoc(playerTreeID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
		rmPlaceObjectDefAtLoc(playerTree2ID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
		rmPlaceObjectDefAtLoc(playerNuggetID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
		rmPlaceObjectDefAtLoc(playerSheepID, i, rmXMetersToFraction(xsVectorGetX(TCLoc)), rmZMetersToFraction(xsVectorGetZ(TCLoc)));
		
		// Water flag
		waterFlagID=rmCreateObjectDef("HC water flag "+i);
		rmAddObjectDefItem(waterFlagID, "HomeCityWaterSpawnFlag", 1, 0.0);
		rmAddClosestPointConstraint(flagEdgeConstraint);
		rmAddClosestPointConstraint(flagVsFlag);
		rmAddClosestPointConstraint(flagLand);
        vector closestPoint = rmFindClosestPointVector(TCLoc, rmXFractionToMeters(1.0));

		rmPlaceObjectDefAtLoc(waterFlagID, i, rmXMetersToFraction(xsVectorGetX(closestPoint)), rmZMetersToFraction(xsVectorGetZ(closestPoint)));
		rmClearClosestPointConstraints();
	}

	// ************************************************************************************************
	
	// Text
	rmSetStatusText("",0.60);
	
	// ************************************** COMMON RESOURCES ****************************************
     
	// ************* Mines **************
		
	// Silver mines
	int silverminecount = 3+3*PlayerNum; 
	
	for(i=0; < silverminecount)
	{
		int silvermineID = rmCreateObjectDef("silver mine"+i);
		rmAddObjectDefItem(silvermineID, "mine", 1, 0.0);
		rmSetObjectDefMinDistance(silvermineID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(silvermineID, rmXFractionToMeters(0.5));
		rmAddObjectDefToClass(silvermineID, classGold);
		rmAddObjectDefConstraint(silvermineID, avoidTradeRoute);
		rmAddObjectDefConstraint(silvermineID, avoidImpassableLand);
		rmAddObjectDefConstraint(silvermineID, avoidswampArea);
		rmAddObjectDefConstraint(silvermineID, avoidSeaEastFar);
		rmAddObjectDefConstraint(silvermineID, avoidNatives);
		rmAddObjectDefConstraint(silvermineID, avoidTradeRouteSocket);
		rmAddObjectDefConstraint(silvermineID, avoidGold);
		rmAddObjectDefConstraint(silvermineID, avoidTownCenter);
		rmAddObjectDefConstraint(silvermineID, avoidStartingResourcesShort);
		rmAddObjectDefConstraint(silvermineID, avoidEdge);
		if (rmGetIsKOTH() == true) {
			rmAddObjectDefConstraint(silvermineID, avoidKOTH);
			rmAddObjectDefConstraint(silvermineID, avoidKOTHLand);
			}
		if (TeamNum <= 2 && teamZeroCount == teamOneCount)
		{
			if (i < 1)
				rmAddObjectDefConstraint(silvermineID, stayNorth);
			else if (i < 2)
				rmAddObjectDefConstraint(silvermineID, staySouth);
		}		
		rmPlaceObjectDefAtLoc(silvermineID, 0, 0.50, 0.50);
	}
	
	// Tin mines
	int tinminecount = 1+2*PlayerNum; 
		
	for(i=0; < tinminecount)
	{
		int tinmineID = rmCreateObjectDef("tin mine"+i);
		rmAddObjectDefItem(tinmineID, "minetin", 1, 0.0);
		rmSetObjectDefMinDistance(tinmineID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(tinmineID, rmXFractionToMeters(0.5));
		rmAddObjectDefToClass(tinmineID, classGold);
		rmAddObjectDefConstraint(tinmineID, avoidImpassableLandShort);
		rmAddObjectDefConstraint(tinmineID, stayInswampArea);
		rmAddObjectDefConstraint(tinmineID, avoidNatives);
		rmAddObjectDefConstraint(tinmineID, avoidGold);
		rmAddObjectDefConstraint(tinmineID, avoidTradeRouteSocket);	
		rmAddObjectDefConstraint(tinmineID, avoidEdge);	
		if (rmGetIsKOTH() == true) {
			rmAddObjectDefConstraint(tinmineID, avoidKOTH);	
			rmAddObjectDefConstraint(tinmineID, avoidKOTHLand);	
			}
		rmPlaceObjectDefAtLoc(tinmineID, 0, 0.50, 0.50);
	}
		
	// *********************************
		
	// Text
	rmSetStatusText("",0.65);	
		
	// ************ Forests *************
	
	// Coastal forest
	int coastalforestcount = 1+2*PlayerNum;
	int stayInCoastalForest = -1;
	
	for (i=0; < coastalforestcount)
	{
		int coastalforestID = rmCreateArea("coastal forest"+i);
		rmSetAreaWarnFailure(coastalforestID, false);
//		rmSetAreaObeyWorldCircleConstraint(coastalforestID, false);
		rmSetAreaSize(coastalforestID, rmAreaTilesToFraction(190), rmAreaTilesToFraction(210));
		if (isWinterSeason == true) {
			rmSetAreaTerrainType(coastalforestID, "yukon\ground2_yuk");
		} else {
			rmSetAreaTerrainType(coastalforestID, "caribbean\ground2_crb");
		}
//		rmSetAreaMinBlobs(coastalforestID, 2);
//		rmSetAreaMaxBlobs(coastalforestID, 4);
//		rmSetAreaMinBlobDistance(coastalforestID, 10.0);
//		rmSetAreaMaxBlobDistance(coastalforestID, 30.0);
		rmSetAreaCoherence(coastalforestID, 0.1);
		rmSetAreaSmoothDistance(coastalforestID, 5);
//		rmAddAreaToClass(coastalforestID, classForest);
		rmAddAreaConstraint(coastalforestID, avoidImpassableLand);
		rmAddAreaConstraint(coastalforestID, stayNearSeaEast);
		rmAddAreaConstraint(coastalforestID, avoidGoldTypeShort);
		rmAddAreaConstraint(coastalforestID, avoidForest);
		rmAddAreaConstraint(coastalforestID, avoidTradeRouteShort);
		rmAddAreaConstraint(coastalforestID, avoidTradeRouteSocket);
		rmAddAreaConstraint(coastalforestID, avoidNatives);
		rmAddAreaConstraint(coastalforestID, avoidTownCenterShort);
		rmAddAreaConstraint(coastalforestID, avoidStartingResourcesShort);
		if (rmGetIsKOTH() == true) {
			rmAddAreaConstraint(coastalforestID, avoidKOTH);
			rmAddAreaConstraint(coastalforestID, avoidKOTHLand);
			}
		rmBuildArea(coastalforestID);
		
		stayInCoastalForest = rmCreateAreaMaxDistanceConstraint("stay in coastal forest"+i, coastalforestID, 0);
	
		for (j=0; < rmRandInt(13,15)) 
		{
			int coastaltreeID = rmCreateObjectDef("coastal tree"+i+" "+j);
			if (isWinterSeason == true) {
				rmAddObjectDefItem(coastaltreeID, "TreeGreatLakesSnow", rmRandInt(1,3), 3.0); // 1,2
			} else {
				rmAddObjectDefItem(coastaltreeID, "OpenbrushAmazon", rmRandInt(2,3), 3.0);
				rmAddObjectDefItem(coastaltreeID, "TreeCaribbean", rmRandInt(1,3), 3.0); // 1,2
				rmAddObjectDefItem(coastaltreeID, "OpenbrushAmazon", rmRandInt(1,1), 1.0);
			}
			rmSetObjectDefMinDistance(coastaltreeID, 0);
			rmSetObjectDefMaxDistance(coastaltreeID, rmXFractionToMeters(0.5));
			rmAddObjectDefToClass(coastaltreeID, classForest);
			rmAddObjectDefConstraint(coastaltreeID, avoidTradeRouteSocket);	
			rmAddObjectDefConstraint(coastaltreeID, stayInCoastalForest);	
		//	rmAddObjectDefConstraint(coastaltreeID, avoidImpassableLandShort);	
			rmPlaceObjectDefAtLoc(coastaltreeID, 0, 0.50, 0.50);
		}
	}
	
	// Land forest
	int landforestcount = 3+3*PlayerNum;
	int stayInLandForest = -1;
	
	for (i=0; < landforestcount)
	{
		int landforestID = rmCreateArea("land forest"+i);
		rmSetAreaWarnFailure(landforestID, false);
//		rmSetAreaObeyWorldCircleConstraint(landforestID, false);
		rmSetAreaSize(landforestID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(220));
		if (isWinterSeason == true) {
			rmSetAreaTerrainType(landforestID, "yukon\ground2_yuk");
		} else {
			rmSetAreaTerrainType(landforestID, "bayou\ground1_bay");
		}
//		rmSetAreaMinBlobs(landforestID, 2);
//		rmSetAreaMaxBlobs(landforestID, 4);
//		rmSetAreaMinBlobDistance(landforestID, 10.0);
//		rmSetAreaMaxBlobDistance(landforestID, 30.0);
		rmSetAreaCoherence(landforestID, 0.1);
		rmSetAreaSmoothDistance(landforestID, 5);
//		rmAddAreaToClass(landforestID, classForest);
		rmAddAreaConstraint(landforestID, avoidImpassableLandFar);
		rmAddAreaConstraint(landforestID, avoidswampArea);
		rmAddAreaConstraint(landforestID, avoidGoldTypeShort);
		rmAddAreaConstraint(landforestID, avoidForest);
		rmAddAreaConstraint(landforestID, avoidTradeRouteShort);
		rmAddAreaConstraint(landforestID, avoidTradeRouteSocket);
		rmAddAreaConstraint(landforestID, avoidNatives);
		rmAddAreaConstraint(landforestID, avoidTownCenterShort);
		rmAddAreaConstraint(landforestID, avoidStartingResourcesShort);
		if (rmGetIsKOTH() == true) {
			rmAddAreaConstraint(landforestID, avoidKOTH);
			rmAddAreaConstraint(landforestID, avoidKOTHLand);
			}
		rmBuildArea(landforestID);
		
		stayInLandForest = rmCreateAreaMaxDistanceConstraint("stay in land forest"+i, landforestID, 0);
	
		for (j=0; < rmRandInt(13,15)) 
		{
			int landtreeID = rmCreateObjectDef("land tree"+i+" "+j);
			if (isWinterSeason == true) {
				rmAddObjectDefItem(landtreeID, "TreeGreatLakesSnow", rmRandInt(1,3), 3.0); // 1,2
			} else {
				rmAddObjectDefItem(landtreeID, "UnderbrushBorneo", rmRandInt(2,3), 3.0);
				rmAddObjectDefItem(landtreeID, "TreeCarolinaGrass", rmRandInt(1,3), 3.0); // 1,2
				rmAddObjectDefItem(landtreeID, "UnderbrushBorneo", rmRandInt(1,1), 1.0);
			}
			rmSetObjectDefMinDistance(landtreeID, 0);
			rmSetObjectDefMaxDistance(landtreeID, rmXFractionToMeters(0.5));
			rmAddObjectDefToClass(landtreeID, classForest);
			rmAddObjectDefConstraint(landtreeID, avoidTradeRouteSocket);	
			rmAddObjectDefConstraint(landtreeID, stayInLandForest);	
		//	rmAddObjectDefConstraint(landtreeID, avoidImpassableLandShort);	
			rmPlaceObjectDefAtLoc(landtreeID, 0, 0.50, 0.50);
		}
	}
		
	// Swamp forest
	int swampforestcount = 1+2*PlayerNum;
	int stayInSwampForest = -1;
	
	for (i=0; < swampforestcount)
	{
		int swampforestID = rmCreateArea("swamp forest"+i);
		rmSetAreaWarnFailure(swampforestID, false);
//		rmSetAreaObeyWorldCircleConstraint(swampforestID, false);
		rmSetAreaSize(swampforestID, rmAreaTilesToFraction(170), rmAreaTilesToFraction(190));
//		rmSetAreaTerrainType(swampforestID, "carolina\cliff_top1_car");
//		rmSetAreaMinBlobs(swampforestID, 2);
//		rmSetAreaMaxBlobs(swampforestID, 4);
//		rmSetAreaMinBlobDistance(swampforestID, 10.0);
//		rmSetAreaMaxBlobDistance(swampforestID, 30.0);
		rmSetAreaCoherence(swampforestID, 0.1);
		rmSetAreaSmoothDistance(swampforestID, 5);
//		rmAddAreaToClass(swampforestID, classForest);
//		rmAddAreaConstraint(swampforestID, avoidImpassableLandFar);
		rmAddAreaConstraint(swampforestID, stayNearerswampArea);
		rmAddAreaConstraint(swampforestID, avoidGoldTypeShort);
		rmAddAreaConstraint(swampforestID, avoidForest);
		rmAddAreaConstraint(swampforestID, avoidTradeRouteShort);
		rmAddAreaConstraint(swampforestID, avoidTradeRouteSocket);
		rmAddAreaConstraint(swampforestID, avoidNatives);
		rmAddAreaConstraint(swampforestID, avoidTownCenterShort);
		rmAddAreaConstraint(swampforestID, avoidStartingResourcesShort);
		if (rmGetIsKOTH() == true) {
			rmAddAreaConstraint(swampforestID, avoidKOTH);
			rmAddAreaConstraint(swampforestID, avoidKOTHLand);
			}
		rmBuildArea(swampforestID);
		
		stayInSwampForest = rmCreateAreaMaxDistanceConstraint("stay in swamp forest"+i, swampforestID, 0);
	
		for (j=0; < rmRandInt(8,10)) 
		{
			int swamptreeID = rmCreateObjectDef("swamp tree"+i+j);
			if (isWinterSeason == true) {
				rmAddObjectDefItem(swamptreeID, "TreeGreatLakesSnow", rmRandInt(1,2), 3.0); // 1,2
			} else {
				rmAddObjectDefItem(swamptreeID, "UnderbrushCarolinasMarsh", rmRandInt(1,2), 3.0);
				rmAddObjectDefItem(swamptreeID, "treebayou", rmRandInt(1,2), 3.0); // 1,2
				rmAddObjectDefItem(swamptreeID, "UnderbrushCarolinasMarsh", rmRandInt(1,1), 1.0);
			}
			rmSetObjectDefMinDistance(swamptreeID, 0);
			rmSetObjectDefMaxDistance(swamptreeID, rmXFractionToMeters(0.5));
			rmAddObjectDefToClass(swamptreeID, classForest);
			rmAddObjectDefConstraint(swamptreeID, avoidTradeRouteSocket);	
			rmAddObjectDefConstraint(swamptreeID, stayInSwampForest);	
		//	rmAddObjectDefConstraint(swamptreeID, avoidImpassableLandShort);	
			rmPlaceObjectDefAtLoc(swamptreeID, 0, 0.50, 0.50);
		}
	}
	
	// Text
	rmSetStatusText("",0.75);

	// ********************************

	// Random Trees
	int randomtreeID = rmCreateObjectDef("random tree");
		rmAddObjectDefItem(randomtreeID, "treebayou", 3, 6.0);
		rmSetObjectDefMinDistance(randomtreeID,  rmXFractionToMeters(0.00));
		rmSetObjectDefMaxDistance(randomtreeID,  rmXFractionToMeters(0.50));
		rmAddObjectDefToClass(randomtreeID, classForest);
		rmAddObjectDefConstraint(randomtreeID, avoidTradeRouteSocket);
		rmAddObjectDefConstraint(randomtreeID, avoidForestShort);
		rmAddObjectDefConstraint(randomtreeID, avoidGoldMin);
		rmAddObjectDefConstraint(randomtreeID, stayInswampArea);
		rmPlaceObjectDefAtLoc(randomtreeID, 0, 0.50, 0.50, 10+4*PlayerNum);

	// ************ Herds *************
	
	//Deer herds
	int Deercount = 2+3*PlayerNum;
	
	for (i=0; < Deercount)
	{
		int DeerherdID = rmCreateObjectDef("Deer herd"+i);
		rmAddObjectDefItem(DeerherdID, "Deer", rmRandInt(10,10), 7.0);
		rmSetObjectDefMinDistance(DeerherdID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(DeerherdID, rmXFractionToMeters(0.5));
		rmSetObjectDefCreateHerd(DeerherdID, true);
//		rmAddObjectDefConstraint(DeerherdID, avoidImpassableLandShort);
		rmAddObjectDefConstraint(DeerherdID, avoidSeaEast);
		rmAddObjectDefConstraint(DeerherdID, avoidNatives);
		rmAddObjectDefConstraint(DeerherdID, avoidTradeRouteSocket);
		rmAddObjectDefConstraint(DeerherdID, avoidForestMin);
		rmAddObjectDefConstraint(DeerherdID, avoidGoldTypeShort);
		rmAddObjectDefConstraint(DeerherdID, avoidTurkey);
		rmAddObjectDefConstraint(DeerherdID, avoidDeerFar);
		rmAddObjectDefConstraint(DeerherdID, avoidStartingResourcesShort);
		rmAddObjectDefConstraint(DeerherdID, avoidTownCenter);
		rmAddObjectDefConstraint(DeerherdID, avoidEdge);
		if (rmGetIsKOTH() == true) {
			rmAddObjectDefConstraint(DeerherdID, avoidKOTH);
			rmAddObjectDefConstraint(DeerherdID, avoidKOTHLand);
			}
		if (TeamNum <= 2 && teamZeroCount == teamOneCount)
		{
			if (i < 2)
				rmAddObjectDefConstraint(DeerherdID, stayNorth);
			else if (i < 4)
				rmAddObjectDefConstraint(DeerherdID, staySouth);
		}
		rmPlaceObjectDefAtLoc(DeerherdID, 0, 0.50, 0.50);
	}

	//Turkey herds
	int Turkeycount = 1+2*PlayerNum;
	
	for (i=0; < Turkeycount)
	{
		int TurkeyherdID = rmCreateObjectDef("Turkey herd"+i);
		rmAddObjectDefItem(TurkeyherdID, "Turkey", rmRandInt(6,6), 5.0);
		rmSetObjectDefMinDistance(TurkeyherdID, 0.0);
		rmSetObjectDefMaxDistance(TurkeyherdID, rmXFractionToMeters(0.5));
		rmSetObjectDefCreateHerd(TurkeyherdID, true);
//		rmAddObjectDefConstraint(TurkeyherdID, avoidImpassableLandShort);
		rmAddObjectDefConstraint(TurkeyherdID, avoidSeaEast);
		rmAddObjectDefConstraint(TurkeyherdID, avoidNatives);
		rmAddObjectDefConstraint(TurkeyherdID, avoidTradeRouteSocket);
		rmAddObjectDefConstraint(TurkeyherdID, avoidForestMin);
		rmAddObjectDefConstraint(TurkeyherdID, avoidGoldTypeShort);
		rmAddObjectDefConstraint(TurkeyherdID, avoidTurkeyFar);
		rmAddObjectDefConstraint(TurkeyherdID, avoidDeer);
		rmAddObjectDefConstraint(TurkeyherdID, avoidTownCenter);
		rmAddObjectDefConstraint(TurkeyherdID, avoidStartingResourcesShort);
		rmAddObjectDefConstraint(TurkeyherdID, avoidEdge);
		if (rmGetIsKOTH() == true) {
			rmAddObjectDefConstraint(TurkeyherdID, avoidKOTH);
			rmAddObjectDefConstraint(TurkeyherdID, avoidKOTHLand);
			}
		rmPlaceObjectDefAtLoc(TurkeyherdID, 0, 0.50, 0.50);
	}
		
	// ************************************
	
	// Text
	rmSetStatusText("",0.80);
		
	// ************** Treasures ***************
	
	int treasure4count = 1*TeamNum;
	int treasure3count = PlayerNum/TeamNum;
	int treasure2count = 6+1*PlayerNum;
	int treasure1count = 2+1*PlayerNum;

	// Treasures lvl 4	
	for (i=1; < treasure4count+1)
	{
		int Nugget4ID = rmCreateObjectDef("nugget lvl4 "+i); 
		rmAddObjectDefItem(Nugget4ID, "Nugget", 1, 0.0);
		rmSetObjectDefMinDistance(Nugget4ID, 0);
		rmSetObjectDefMaxDistance(Nugget4ID, rmXFractionToMeters(0.25));
        if(PlayerNum==2 || rmGetIsTreaty() == true){
            rmSetNuggetDifficulty(3,3);
        }else{
            rmSetNuggetDifficulty(4,4);
        }
		rmAddObjectDefConstraint(Nugget4ID, avoidNuggetFar);
		rmAddObjectDefConstraint(Nugget4ID, avoidNatives);
		rmAddObjectDefConstraint(Nugget4ID, avoidTradeRoute);
		rmAddObjectDefConstraint(Nugget4ID, avoidTradeRouteSocket);
		rmAddObjectDefConstraint(Nugget4ID, avoidImpassableLandShort);
		rmAddObjectDefConstraint(Nugget4ID, avoidSeaEastMed);
		rmAddObjectDefConstraint(Nugget4ID, avoidGoldMin);
		rmAddObjectDefConstraint(Nugget4ID, avoidTownCenterFar);
		rmAddObjectDefConstraint(Nugget4ID, avoidStartingResourcesShort);
		rmAddObjectDefConstraint(Nugget4ID, avoidTurkeyMin); 
		rmAddObjectDefConstraint(Nugget4ID, avoidDeerMin);
		rmAddObjectDefConstraint(Nugget4ID, avoidForestMin);
		rmAddObjectDefConstraint(Nugget4ID, avoidEdge); 
		if (rmGetIsKOTH() == true) {
			rmAddObjectDefConstraint(Nugget4ID, avoidKOTH); 
			rmAddObjectDefConstraint(Nugget4ID, avoidKOTHLand); 
			}
		if (TeamNum > 2 && PlayerNum >= 4)
			rmPlaceObjectDefAtLoc(Nugget4ID, 0, 0.50, 0.50);
	}

	// Treasures lvl 3	
	for (i=1; < treasure3count+1)
	{
		int Nugget3ID = rmCreateObjectDef("nugget lvl3 "+i); 
		rmAddObjectDefItem(Nugget3ID, "Nugget", 1, 0.0);
		rmSetObjectDefMinDistance(Nugget3ID, 0);
		rmSetObjectDefMaxDistance(Nugget3ID, rmXFractionToMeters(0.35));
		rmSetNuggetDifficulty(3,3);
		rmAddObjectDefConstraint(Nugget3ID, avoidNuggetFar);
		rmAddObjectDefConstraint(Nugget3ID, avoidNatives);
		rmAddObjectDefConstraint(Nugget3ID, avoidTradeRoute);
		rmAddObjectDefConstraint(Nugget3ID, avoidTradeRouteSocket);
		rmAddObjectDefConstraint(Nugget3ID, avoidImpassableLandShort);
		rmAddObjectDefConstraint(Nugget3ID, avoidSeaEastMed);
		rmAddObjectDefConstraint(Nugget3ID, avoidGoldMin);
		rmAddObjectDefConstraint(Nugget3ID, avoidTownCenterFar);
		rmAddObjectDefConstraint(Nugget3ID, avoidStartingResourcesShort);
		rmAddObjectDefConstraint(Nugget3ID, avoidTurkeyMin); 
		rmAddObjectDefConstraint(Nugget3ID, avoidDeerMin);
		rmAddObjectDefConstraint(Nugget3ID, avoidForestMin);
		rmAddObjectDefConstraint(Nugget3ID, avoidEdge); 
		if (rmGetIsKOTH() == true) {
			rmAddObjectDefConstraint(Nugget3ID, avoidKOTH); 
			rmAddObjectDefConstraint(Nugget3ID, avoidKOTHLand); 
			}
		if (PlayerNum >= 3)
			rmPlaceObjectDefAtLoc(Nugget3ID, 0, 0.50, 0.50);
	}
	
	// Treasures lvl 2	
	for (i=1; < treasure2count+1)
	{
		int Nugget2ID = rmCreateObjectDef("nugget lvl2 "+i); 
		rmAddObjectDefItem(Nugget2ID, "Nugget", 1, 0.0);
		rmSetObjectDefMinDistance(Nugget2ID, 0);
		rmSetObjectDefMaxDistance(Nugget2ID, rmXFractionToMeters(0.5));
		rmSetNuggetDifficulty(2,2);
		rmAddObjectDefConstraint(Nugget2ID, avoidNuggetFar);
		rmAddObjectDefConstraint(Nugget2ID, avoidNatives);
		rmAddObjectDefConstraint(Nugget2ID, avoidTradeRouteShort);
		rmAddObjectDefConstraint(Nugget2ID, avoidTradeRouteSocket);
		rmAddObjectDefConstraint(Nugget2ID, avoidImpassableLandShort);
		rmAddObjectDefConstraint(Nugget2ID, avoidSeaEastMed);
		rmAddObjectDefConstraint(Nugget2ID, avoidGoldTypeShort);
		rmAddObjectDefConstraint(Nugget2ID, avoidTownCenterFar);
		rmAddObjectDefConstraint(Nugget2ID, avoidStartingResourcesShort);
		rmAddObjectDefConstraint(Nugget2ID, avoidTurkeyMin); 
		rmAddObjectDefConstraint(Nugget2ID, avoidDeerMin);
		rmAddObjectDefConstraint(Nugget2ID, avoidForestMin);
		rmAddObjectDefConstraint(Nugget2ID, avoidEdge); 
		if (rmGetIsKOTH() == true) {
			rmAddObjectDefConstraint(Nugget2ID, avoidKOTH); 
			rmAddObjectDefConstraint(Nugget2ID, avoidKOTHLand); 
			}
		rmPlaceObjectDefAtLoc(Nugget2ID, 0, 0.50, 0.50);
	}
	
	// Treasures lvl 1	
	for (i=1; < treasure1count+1)
	{
		int Nugget1ID = rmCreateObjectDef("nugget lvl1 "+i); 
		rmAddObjectDefItem(Nugget1ID, "Nugget", 1, 0.0);
		rmSetObjectDefMinDistance(Nugget1ID, 0);
		rmSetObjectDefMaxDistance(Nugget1ID, rmXFractionToMeters(0.5));
		rmSetNuggetDifficulty(1,1);
		rmAddObjectDefConstraint(Nugget1ID, avoidNuggetFar);
		rmAddObjectDefConstraint(Nugget1ID, avoidNatives);
		rmAddObjectDefConstraint(Nugget1ID, avoidTradeRouteShort);
		rmAddObjectDefConstraint(Nugget1ID, avoidTradeRouteSocket);
		rmAddObjectDefConstraint(Nugget1ID, avoidImpassableLandShort);
		rmAddObjectDefConstraint(Nugget1ID, avoidSeaEastMed);
		rmAddObjectDefConstraint(Nugget1ID, avoidGoldTypeShort);
		rmAddObjectDefConstraint(Nugget1ID, avoidTownCenter);
		rmAddObjectDefConstraint(Nugget1ID, avoidStartingResourcesShort);
		rmAddObjectDefConstraint(Nugget1ID, avoidTurkeyMin); 
		rmAddObjectDefConstraint(Nugget1ID, avoidDeerMin);
		rmAddObjectDefConstraint(Nugget1ID, avoidForestMin);
		rmAddObjectDefConstraint(Nugget1ID, avoidEdge); 
		if (rmGetIsKOTH() == true) {
			rmAddObjectDefConstraint(Nugget1ID, avoidKOTH); 
			rmAddObjectDefConstraint(Nugget1ID, avoidKOTHLand); 
			}
		rmPlaceObjectDefAtLoc(Nugget1ID, 0, 0.50, 0.50);
	}
	
	// ****************************************
		
	// Text
	rmSetStatusText("",0.85);
	
	// **************** Sheeps *****************
	
	int sheepcount = 2+3*PlayerNum;
	
	for (i=0; < sheepcount)
	{
		int sheepID=rmCreateObjectDef("sheep"+i);
		rmAddObjectDefItem(sheepID, "sheep", 1, 1.0);
		rmSetObjectDefMinDistance(sheepID, 0.0);
		rmSetObjectDefMaxDistance(sheepID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(sheepID, avoidTradeRouteSocket);
		rmAddObjectDefConstraint(sheepID, avoidSheep);
		rmAddObjectDefConstraint(sheepID, avoidForestMin);
		rmAddObjectDefConstraint(sheepID, avoidTownCenterFar);
		rmAddObjectDefConstraint(sheepID, avoidStartingResourcesShort);
		rmAddObjectDefConstraint(sheepID, avoidswampArea);
		rmAddObjectDefConstraint(sheepID, avoidImpassableLandFar);
		rmAddObjectDefConstraint(sheepID, avoidEdge);
		if (rmGetIsKOTH() == true) {
			rmAddObjectDefConstraint(sheepID, avoidKOTH);
			rmAddObjectDefConstraint(sheepID, avoidKOTHLand);
			}
		rmPlaceObjectDefAtLoc(sheepID, 0, 0.50, 0.50);
	}
	
	
	// ****************************************
	
	// Text
	rmSetStatusText("",0.90);
	
	// ************ Sea resources *************

	int fishcount = 3+3*PlayerNum;
	int whalecount = 1+2*PlayerNum;
	
		
	int whaleID=rmCreateObjectDef("whale");
	rmAddObjectDefItem(whaleID, "MinkeWhale", 1, 3.0);
	rmSetObjectDefMinDistance(whaleID, 0.0);
	rmSetObjectDefMaxDistance(whaleID, rmXFractionToMeters(0.50));
	rmAddObjectDefConstraint(whaleID, avoidWhale);
	rmAddObjectDefConstraint(whaleID, avoidLandFar);
	rmAddObjectDefConstraint(whaleID, avoidColonyShipShort);
	rmAddObjectDefConstraint(whaleID, avoidEdge);	
	if (rmGetIsKOTH() == true)
		rmAddObjectDefConstraint(whaleID, avoidKOTH);	
	for (i=0; < whalecount)
	{
		rmPlaceObjectDefAtLoc(whaleID, 0, 0.50, 0.15);	
	}
	
	int fishID = rmCreateObjectDef("fish");
	rmAddObjectDefItem(fishID, "FishTarpon", rmRandInt(2,2), 7.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(fishID, avoidFish);
	rmAddObjectDefConstraint(fishID, avoidLand);
	rmAddObjectDefConstraint(fishID, avoidColonyShipShort);
	rmAddObjectDefConstraint(fishID, avoidEdge);	
	if (rmGetIsKOTH() == true)
		rmAddObjectDefConstraint(fishID, avoidKOTH);	
	for (i=0; < fishcount)
	{
		rmPlaceObjectDefAtLoc(fishID, 0,  0.50, 0.15);
	}
	
	// ****************************************
	
	// Text
	rmSetStatusText("",1.00);

	
} // END
	
	
