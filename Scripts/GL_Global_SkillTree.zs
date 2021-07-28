/*
Skill Tree script.
HOW TO USE
Each character's skill tree is represented by a screen on a map. The user places FFCs on this screen which represent the upgrades you can get for this character.
Their data must be set to what they would display on the screen. The FFCs have no script attached to them, but their D Values must be set as the following.
D0 - Coin Price. You need to spend this many coins to buy this skill. For upgrades that are not brought yet, this price is displayed below the node. Currently nonfunctional as of now
D1 - Modifier icon. Tile offset for the little modifier icon that is displayed in the bottom left corner of the node (eg. the + icon for Strong Water). Currently nonfunctional as of now
D4-7 - Unlock nodes. The nodes defined by FFC ID are unlocked when you purchase this node. They are split into two halves to squeeze two args out of each of these. Left corresponds to the number on the left side of the decimal point while right corresponds to the number on the right side of the decimal point. The right side *MUST* always have 4 digits - just add 0s in front of your number until you have 4 digits if you plan on using it.
D4 (Left) Unlock node 1
D5 (Left) Unlock node 2
D6 (Left) Unlock node 3
D7 (Left) Unlock node 4
D4 (Right) Unlock node 5
D5 (Right) Unlock node 6
D6 (Right) Unlock node 7
D7 (Right) Unlock node 8
Set any of these to 0 to disable that half arg. Additionally that half arg is also disabled if it references an invalid node (a node that uses Combo 0 or have 0 listed as their upgrade ID).
The node that the player starts with is always the lowest number valid FFC on the screen. If there are no FFCs on the screen, the game will tell you there are no coin upgrades.
*/

/*
untyped BaseCharacter[] = {
Character ID,
Passive ID,
Signature 1 ID,
Signature 2 ID,
Base Attack,
Base Defense,
Base Speed,
Base Magic,
Upgrade 1,
Upgrade 1 misc.,
...
Final upgrade,
Final upgrade misc.
};
*/

CONFIG CB_SKILLTREE = CB_MAP; //Input for opening the skill tree



enum
{
	//Signature and starting upgrades
	SKILL_STARTING,			//Starting skill. This depends on the character, potentially flipping multiple flags.
	SKILL_SIG1,				//Character signature skill 1.
	SKILL_SIG2,				//Character signature skill 2.
	//Stat upgrades
	SKILL_ATTACKUP,			//Damage +x%. Writes to the damage stat
	SKILL_DEFENSEUP,		//Defense +x%. Writes to the defense stat
	SKILL_SPEEDUP,			//Speed +x%. Writes to the speed stat
	SKILL_MAGICREGEN,		//Magic +x%. Writes to the magic stat
	//Spectral skills
	SKILL_STRONGSPECTRAL,	//+% Damage for Spectral Barrier
	SKILL_CHEAPSPECTRAL,	//-% Magic cost for Spectral Barrier
	//Nature skills
	SKILL_STRONGNATURE,		//+% Damage for Nature
	SKILL_CHEAPNATURE,		//-% Magic cost for Nature
	//Wind skills
	SKILL_STRONGWIND,		//+% Damage for Wind
	SKILL_CHEAPWIND,		//-% Magic cost for Wind
	//Ice skills
	SKILL_STRONGICE,		//+% Damage for Ice
	SKILL_CHEAPICE,			//-% Magic cost for Ice
	//Fire skills
	SKILL_STRONGFIRE,		//+% Damage for Fire
	SKILL_CHEAPFIRE,		//-% Magic cost for Fire
	//Nova skills
	SKILL_STRONGNOVA,		//+% Damage for Nova
	SKILL_CHEAPNOVA,		//-% Magic cost for Nova
	//Technology skills
	SKILL_STRONGTECH,		//+% Damage for Technology
	SKILL_CHEAPTECH,		//-% Magic cost for Technology
	//Astral skills
	SKILL_STRONGASTRAL,		//+% Damage for Astral
	SKILL_CHEAPASTRAL,		//-% Magic cost for Astral
	SKILL_LAST
};

namespace SkillTree
{
	enum
	{
		NODE_DATA,			//Int: Combo ID of the node. This uses combo+1 if the node is purchased
		NODE_X,				//Int: Center X coordinate of the node
		NODE_Y,				//Int: Center Y coordinate of the node
		NODE_EFFECTWIDTH,	//Int: Width of the node
		NODE_EFFECTHEIGHT,	//Int: Height of the node
		NODE_TILEWIDTH,		//Int: Node's tile width
		NODE_TILEHEIGHT,	//Int: Node's tile height
		NODE_PRICE,			//Int: The coin price of the node. D0 on its corresponding FFC.
		NODE_MODICON,		//Int: The modifier icon on the FFC. D1 on its corresponding FFC.
		NODE_UNLOCK1 = 13,	//Int: Unlocks connection 1 when purchased. Integer side of D4 on its corresponding FFC
		NODE_UNLOCK1_BEND,	//Int: Position on the X axis where it bends (if it bends). Decimal side of D4 on its corresponding FFC.
		NODE_UNLOCK2,		//Ditto, for connection 2. D5 on its corresponding FFC
		NODE_UNLOCK2_BEND,	//"" ""
		NODE_UNLOCK3,		//Ditto, for connection 3. D6 on its corresponding FFC
		NODE_UNLOCK3_BEND,	//"" ""
		NODE_UNLOCK4,		//Ditto, for connection 4. D7 on its corresponding FFC
		NODE_UNLOCK4_BEND,	//"" ""
		NODE_BROUGHT,		//Bool: Wherever the player has brought the node or not
		NODE_CENTERX,		//Int: CenterX position. Used for connecting nodes.
		NODE_CENTERY,		//Int: CenterY position. Used for connecting nodes.
		NODE_END
	};
	CONFIG LINE_THICKNESS = 2; //How thick the lines are
	void Operate(int map, int screen)
	{
		//Set up the skill tree screen.
		mapdata TreeScreen = Game->LoadMapData(map, screen);
		bitmap SkillTree = Game->CreateBitmap(256, 256);
		untyped node[32*NODE_END];
		//Cycle through the FFCs and populate the data array.
		for(int fcmb = 1; fcmb <= 32; fcmb ++)
		{
			if(TreeScreen->NumFFCs[fcmb]) //Valid FFC
			{
				node[(fcmb-1)*NODE_END+NODE_DATA] = TreeScreen->FFCData[fcmb];
				node[(fcmb-1)*NODE_END+NODE_X] = TreeScreen->FFCX[fcmb];
				node[(fcmb-1)*NODE_END+NODE_Y] = TreeScreen->FFCY[fcmb];
				node[(fcmb-1)*NODE_END+NODE_EFFECTWIDTH] = TreeScreen->FFCEffectWidth[fcmb];
				node[(fcmb-1)*NODE_END+NODE_EFFECTHEIGHT] = TreeScreen->FFCEffectHeight[fcmb];
				node[(fcmb-1)*NODE_END+NODE_TILEWIDTH] = TreeScreen->FFCTileWidth[fcmb];
				node[(fcmb-1)*NODE_END+NODE_TILEHEIGHT] = TreeScreen->FFCTileHeight[fcmb];
				node[(fcmb-1)*NODE_END+NODE_PRICE] = TreeScreen->GetFFCInitD(fcmb, 0);
				node[(fcmb-1)*NODE_END+NODE_MODICON] = TreeScreen->GetFFCInitD(fcmb, 1);
				node[(fcmb-1)*NODE_END+NODE_UNLOCK1] = TreeScreen->GetFFCInitD(fcmb, 4)>>0;
				node[(fcmb-1)*NODE_END+NODE_UNLOCK1_BEND] = DecimalToInt(TreeScreen->GetFFCInitD(fcmb, 4));
				node[(fcmb-1)*NODE_END+NODE_UNLOCK2] = TreeScreen->GetFFCInitD(fcmb, 5)>>0;
				node[(fcmb-1)*NODE_END+NODE_UNLOCK2_BEND] = DecimalToInt(TreeScreen->GetFFCInitD(fcmb, 5));
				node[(fcmb-1)*NODE_END+NODE_UNLOCK3] = TreeScreen->GetFFCInitD(fcmb, 6)>>0;
				node[(fcmb-1)*NODE_END+NODE_UNLOCK3_BEND] = DecimalToInt(TreeScreen->GetFFCInitD(fcmb, 6));
				node[(fcmb-1)*NODE_END+NODE_UNLOCK4] = TreeScreen->GetFFCInitD(fcmb, 7)>>0;
				node[(fcmb-1)*NODE_END+NODE_UNLOCK4_BEND] = DecimalToInt(TreeScreen->GetFFCInitD(fcmb, 7));
				node[(fcmb-1)*NODE_END+NODE_CENTERX] = TreeScreen->FFCX[fcmb]+TreeScreen->FFCEffectWidth[fcmb]/2;
				node[(fcmb-1)*NODE_END+NODE_CENTERY] = TreeScreen->FFCY[fcmb]+TreeScreen->FFCEffectHeight[fcmb]/2;
			}
		}
		//Draw the tree.
		SetBitmap(SkillTree, node);
		do
		{
			SkillTree->Blit(7, RT_SCREEN, 0, 0, 256, 256, 0, SUBSCREEN_TOP, 256, 256, 0, 0, 0, BITDX_NORMAL, 0,  false);
			Waitframe();
		}
		until(Input->Press[CB_START]); //Return to the subscreen when you press *start*
	}
	//Draws the elements to the bitmap.
	void SetBitmap(bitmap bmp, int node)
	{
		//Screen->SetRenderTarget(bmp);
		for(int fcmb = 1; fcmb <= 32; fcmb ++)
		{
			if(node[(fcmb-1)*NODE_END+NODE_DATA] > 0)
			{
				//The lines are drawn behind everything else
				for(int unlock = 0; unlock < 4; unlock ++)
				{
					//The code looks a bit hard to parse but its mostly functions, which are more readable than a mass of calculations strewn about.
					//This references the unlocks.
					int refval = node[GetNode(fcmb, NODE_UNLOCK1+unlock*2)];
					if(refval > 0)
					{
						int ydif = node[GetNode(fcmb,NODE_CENTERY)] - node[GetNode(refval,NODE_CENTERY)];
						bool brought = node[GetNode(fcmb,NODE_BROUGHT)];
						//Right now this code is real ugly. Might stuff this into a function call later.
						//Draw the first line.
						bmp->Rectangle(brought ? 0 : 1, node[GetNode(fcmb,NODE_CENTERX)], node[GetNode(fcmb,NODE_CENTERY)]-Floor(LINE_THICKNESS/2), (ydif == 0 ? node[GetNode(refval,NODE_CENTERX)] : node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)])-LINE_THICKNESS, node[GetNode(fcmb,NODE_CENTERY)]+Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0), brought ? C_WHITE : C_GREY, 1, 0, 0, 0, true, OP_OPAQUE);
						//The source and target combo's centers are not on the same Y axis, draw the bend.
						if(ydif != 0)
						{
							//Draw the first corner bit.
							SafeArc(bmp, brought ? 0 : 1, node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)]-LINE_THICKNESS, node[GetNode(fcmb,NODE_CENTERY)]+(ydif<0 ? Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0) : -(Floor(LINE_THICKNESS/2))), LINE_THICKNESS-1, 0, (ydif<0?90:-90), brought ? C_WHITE : C_GREY, 1, 0, 0, 0, true, true, OP_OPAQUE);
							//Draw the vertical line
							bmp->Rectangle(brought ? 0 : 1, node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)]-LINE_THICKNESS, node[GetNode(fcmb,NODE_CENTERY)]+(ydif<0 ? Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0) : -(Floor(LINE_THICKNESS/2))), node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)]-1, node[GetNode(refval,NODE_CENTERY)]+(ydif<0 ? -(Floor(LINE_THICKNESS/2)) : Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0)), brought ? C_WHITE : C_GREY, 1, 0, 0, 0, true, OP_OPAQUE);
							//Draw the second corner bit.
							SafeArc(bmp, brought ? 0 : 1, node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)]-1, node[GetNode(refval,NODE_CENTERY)]+(ydif<0 ? -(Floor(LINE_THICKNESS/2)) : Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0)), LINE_THICKNESS-1, 180, (ydif<0?270:90), brought ? C_WHITE : C_GREY, 1, 0, 0, 0, true, true, OP_OPAQUE);
							//Draw the final horizontal line.
							bmp->Rectangle(brought ? 0 : 1, node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)], node[GetNode(refval,NODE_CENTERY)]-Floor(LINE_THICKNESS/2), node[GetNode(refval,NODE_CENTERX)], node[GetNode(refval,NODE_CENTERY)]+Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0), brought ? C_WHITE : C_GREY, 1, 0, 0, 0, true, OP_OPAQUE);
						}
						//printf("Third line of source node %i to target node %i. X1 = %i, Y1 = %i, X2 = %i, Y2 = %i.", fcmb, refval, node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)]-LINE_THICKNESS, node[GetNode(fcmb,NODE_CENTERY)]+(ydif<0 ? Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0) : -(Floor(LINE_THICKNESS/2))), node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)], node[GetNode(fcmb,NODE_CENTERY)]+(ydif<0 ? -(Floor(LINE_THICKNESS/2)) : Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0))); TraceNL();
						//bmp->Line(0, node[GetNode(fcmb,NODE_X)] + node[GetNode(fcmb,NODE_EFFECTWIDTH)]/2, node[GetNode(fcmb,NODE_Y)] + node[GetNode(fcmb,NODE_EFFECTHEIGHT)]/2, node[GetNode(refval,NODE_X)] + node[GetNode(refval,NODE_EFFECTWIDTH)]/2, node[GetNode(refval,NODE_Y)] + node[GetNode(refval,NODE_EFFECTHEIGHT)]/2, node[GetNode(fcmb,NODE_BROUGHT)] ? C_WHITE : C_GREY, LINE_THICKNESS, 0, 0, 0, OP_OPAQUE);
					}
				}
				//Draw the combo
				bmp->DrawCombo(2, node[GetNode(fcmb, NODE_X)], node[GetNode(fcmb, NODE_Y)], node[GetNode(fcmb, NODE_DATA)], node[GetNode(fcmb, NODE_TILEWIDTH)], node[GetNode(fcmb, NODE_TILEHEIGHT)], 0, -1, -1, 0, 0, 0, 0, 0, true, OP_OPAQUE);
			}
		}
		//Draw the box below the skill tree. Parameters are as follow:
		//Description box
		CONFIG DESCBOX_TILE = 42003;	//First tile used
		CONFIG DESCBOX_X = 33;			//X position on bitmap
		CONFIG DESCBOX_Y = 176;			//Y position on bitmap
		CONFIG DESCBOX_WIDTH = 223;		//Box width
		CONFIG DESCBOX_HEIGHT = 48; 	//Box height
		CONFIG DESCBOX_CSET = 6;		//CSet
		//Stat box
		CONFIG STATBOX_TILE = 42023;	//Ditto
		CONFIG STATBOX_X = 0;			
		CONFIG STATBOX_Y = 176;			
		CONFIG STATBOX_WIDTH = 32;		
		CONFIG STATBOX_HEIGHT = 48; 	
		CONFIG STATBOX_CSET = 6;		
		//Name box
		CONFIG NAMEBOX_TILE = 42003;	//Also Ditto
		CONFIG NAMEBOX_X = 33;			
		CONFIG NAMEBOX_Y = 161;			
		CONFIG NAMEBOX_WIDTH = 64;		
		CONFIG NAMEBOX_HEIGHT = 14; 	
		CONFIG NAMEBOX_CSET = 6;				
		//Coin box
		CONFIG COINBOX_TILE = 42003;	//Also Ditto
		CONFIG COINBOX_X = 98;			
		CONFIG COINBOX_Y = 161;			
		CONFIG COINBOX_WIDTH = 24;		
		CONFIG COINBOX_HEIGHT = 14; 	
		CONFIG COINBOX_CSET = 6;	
		DrawBoxScale(0, bmp, {DESCBOX_TILE, 3, 3}, 6, C_BLACK, DESCBOX_X, DESCBOX_Y, DESCBOX_WIDTH, DESCBOX_HEIGHT, {OP_OPAQUE, OP_OPAQUE});
		DrawBoxScale(0, bmp, {STATBOX_TILE, 3, 3}, 6, C_BLACK, STATBOX_X, STATBOX_Y, STATBOX_WIDTH, STATBOX_HEIGHT, {OP_OPAQUE, OP_OPAQUE});
		DrawBoxScale(0, bmp, {NAMEBOX_TILE, 3, 3}, 6, C_BLACK, NAMEBOX_X, NAMEBOX_Y, NAMEBOX_WIDTH, NAMEBOX_HEIGHT, {OP_OPAQUE, OP_OPAQUE});
		DrawBoxScale(0, bmp, {COINBOX_TILE, 3, 3}, 6, C_BLACK, COINBOX_X, COINBOX_Y, COINBOX_WIDTH, COINBOX_HEIGHT, {OP_OPAQUE, OP_OPAQUE});
		//bmp->DrawTile(0, DESCBOX_X,  DESCBOX_Y, DESCBOX_TILE, DESCBOX_WIDTH, DESCBOX_HEIGHT, DESCBOX_CSET, -1, -1, 0, 0, 0, 0, true, OP_OPAQUE);
		//Screen->SetRenderTarget(RT_SCREEN);
	}
	//Returns a pointer to somewhere within the node array.
	//fcmb = FFC referenced
	//offset = Offset from the base index to read the pointer from
	int GetNode(int fcmb, int offset)
	{
		return ((fcmb-1)*NODE_END+offset);
	}
}

//This script grabs the data for an FFC from another screen and traces it
ffc script MapdataTest
{
	void run(int map, int screen, int ffcmb)
	{
		mapdata ripscreen = Game->LoadMapData(map, screen);
		//Printf()
/*		while(true)
		{
			if(ripscreen->NumFFCs[ffcmb])
				Screen->FastCombo(7, ripscreen->FFCX[ffcmb], ripscreen->FFCY[ffcmb], ripscreen->FFCData[ffcmb], ripscreen->FFCCSet[ffcmb], OP_OPAQUE);
			Waitframe();
		}*/
	}
}

/*
Skill ideas that are currently not being added yet
	SKILL_ADRENALINE,		//Speed +xxx% for 1 sec after taking damage. Writes to the speed stat during this time.
	SKILL_LIVELY,			//Gradual life regen. One of Mirr's upgrades in Reikon
	SKILL_RESILIENT,		//Immunity to knockback. Will be moved to Earth if it exists here. Part of Rhone's signature and Sylvia's Earth passive as well as a property of Earth Buff in Yuurand. One of Holm's upgrades in Reikon.
	SKILL_FLAMEWALK,		//No knockback from Fire-based attacks
	SKILL_BURN,				//Fire projectiles set enemies on fire for damage over time. Part of Horizon's passive and inflicted by Pyron's flame aura in Yuurand. Property of Hart's upgraded Fire Conduit in Reikon.
	SKILL_SPARK,			//Fire projectiles spawn smaller sparks of fire which dissappear shortly afterwards.
	//Water skills
	SKILL_STRONGWATER,		//+% Damage for Water
	SKILL_80MPWATER,		//Water consumes 4/5 MP
	SKILL_75MPWATER,		//Water consumes 3/4 MP
	SKILL_50MPWATER,		//Water consumes 1/2 MP
	SKILL_SWIFTSWIM,		//+xx% Speed in water
	SKILL_HYDROPHILE,		//Can attack from water. Naiya's passive in Yuurand
	SKILL_WATERSILVER2,		//Second Water Silver passive
	//Ice skills
	SKILL_STRONGICE,		//+% Damage for Ice
	SKILL_80MPICE,			//Ice consumes 4/5 MP
	SKILL_75MPICE,			//Ice consumes 3/4 MP
	SKILL_50MPICE,			//Ice consumes 1/2 MP
	SKILL_CRYOKINETIC,		//Immunity to Ice terrain. Mato's passive in Yuurand
	SKILL_FREEZE,			//Ice projectiles freeze weak enemies. Trait of Emily's ice Bow, Eli's Ice Gun and IIRC B.B.'s Arctic Wind attack from Yuurand. Property of Holm's upgraded Ice Conduit in Reikon.
	SKILL_ICESHIELD,		//Ice projectiles can block projectiles. One of Hera's skills in Yuurand and replicates the original Flake Shield behaviour in Yuurei. 
	//Astral skills
	SKILL_STRONGASTRAL,		//+% Damage for Astral
	SKILL_80MPASTRAL,		//Astral consumes 4/5 MP
	SKILL_75MPASTRAL,		//Astral consumes 3/4 MP
	SKILL_67MPASTRAL,		//Astral consumes 2/3 MP
	SKILL_ASTRALBRONZE,		//Astral Bronze passive
	SKILL_RETRIBUTION,		//The next cast of Purge targets the last enemy to hit you with +xx damage on its next beam. Astral signatures interact differently with this skill.
	SKILL_ASTRALSILVER2,	//Second Astral Silver passive.
*/