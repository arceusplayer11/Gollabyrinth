/*
Skill Tree script.
HOW THIS WORKS
Each character's skill tree is represented by a screen on a map. The user places FFCs on this screen which represent the upgrades you can get for this character.
*/

//This script grabs the data for an FFC from another screen and traces it
ffc script MapdataTest
{
	void run(, int map, int screen, int ffcmb)
	{
		mapdata ripscreen = LoadMapData(map, screen);
		while(true)
		{
			if(ripscreen->NumFFCs[ffcmb+1])
				Screen->FastCombo(7, ripscreen->FFCX[ffcmb], ripscreen->FFCY[ffcmb], ripscreen->FFCData[ffcmb], ripscreen->FFCCSet[ffcmb], OP_OPAQUE);
			Waitframe();
		}
	}
}