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
	SKILL_SPECIAL,			//Unique character skill.
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
	//Metal skills
	SKILL_STRONGMETAL,		//+% Damage for Metal
	SKILL_CHEAPMETAL,		//-% Magic cost for Metal
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
		NODE_MODICON,		//Int: The modifier icon on the FFC. D0 on its corresponding FFC.
		NODE_UNLOCK1 = 13,	//Int: Unlocks connection 1 when purchased. Integer side of D4 on its corresponding FFC
		NODE_UNLOCK1_BEND,	//Int: Position on the X axis where it bends (if it bends). Decimal side of D4 on its corresponding FFC.
		NODE_UNLOCK2,		//Ditto, for connection 2. D5 on its corresponding FFC
		NODE_UNLOCK2_BEND,	//"" ""
		NODE_UNLOCK3,		//Ditto, for connection 3. D6 on its corresponding FFC
		NODE_UNLOCK3_BEND,	//"" ""
		NODE_UNLOCK4,		//Ditto, for connection 4. D7 on its corresponding FFC
		NODE_UNLOCK4_BEND,	//"" ""
		NODE_CENTERX,		//Int: CenterX position. Used for connecting nodes.
		NODE_CENTERY,		//Int: CenterY position. Used for connecting nodes.
		NODE_CANREACH,		//Bool: Can this node be reached?
		NODE_END
	};
	CONFIG UPGRADE_BUFFER = 1024; //How big the buffer for the upgrade text needs to be
	CONFIG LINE_THICKNESS = 2; //How thick the lines are
	
	
	//Parameters for the box showing controls. Coordinates are on bitmap, add SUBSCREEN_TOP the Y coordinates to get the correct position on screen
	CONFIG CONTROL_BOX_HEIGHT = 9;
	CONFIG CONTROL_ICON = 41763; //
	CONFIG CONTROL_START_X = 2; //X position of the control icons
	
	//Parameters for the boxes. Coordinates are on bitmap, add SUBSCREEN_TOP the Y coordinates to get the correct position on screen.
	//Description box
	CONFIG DESCBOX_TILE = 42003;	//First tile used
	CONFIG DESCBOX_X = 33;			//X position on bitmap
	CONFIG DESCBOX_Y = 176-CONTROL_BOX_HEIGHT;			//Y position on bitmap
	CONFIG DESCBOX_WIDTH = 223;		//Box width
	CONFIG DESCBOX_HEIGHT = 48; 	//Box height
	CONFIG DESCBOX_CSET = 6;		//CSet
	//Stat box
	CONFIG STATBOX_TILE = 42023;	//Ditto
	CONFIG STATBOX_X = 0;			
	CONFIG STATBOX_Y = 176-CONTROL_BOX_HEIGHT;			
	CONFIG STATBOX_WIDTH = 32;		
	CONFIG STATBOX_HEIGHT = 48; 	
	CONFIG STATBOX_CSET = 6;
	CONFIG STATBOX_TILE_X = STATBOX_X+5; //Offsets for the tiles
	CONFIG STATBOX_TILE_Y = STATBOX_Y+5;
	//Dialogue box
	CONFIG DIALOGUE_TILE = 42003;	//Also Ditto		
	CONFIG DIALOGUE_ARROW_COMBO = 6400;	//Combo used by the dialogue arrow			
	CONFIG DIALOGUE_WIDTH = 88;		
	CONFIG DIALOGUE_HEIGHT = 34;
	CONFIG DIALOGUE_X = SCREEN_CENTER_X;			
	CONFIG DIALOGUE_Y = (SCREEN_BOTTOM+SUBSCREEN_TOP*-1)/2+SUBSCREEN_TOP; //Centered on the middle of the screen after accounting for the top of the subscreen.
	CONFIG DIALOGUE_TEXT_XOFF = 5;
	CONFIG DIALOGUE_TEXT_YOFF = 5;
	CONFIG DIALOGUE_CSET = 6;
	CONFIG DIALOGUE_EXTIME = 20; //Time it takes for the box to expand.
	//Character name.
	CONFIG CHARNAME_X = SCREEN_CENTER_X;
	CONFIG CHARNAME_Y = 0;
	CONFIG CURSOR_TILE = 41804;
	
	//Runs the selection and activation part of the skill tree.
	//I feel like I should rewrite this at some point to be way cleaner.
	void Operate(int map, int screen) //SkillTree::Operate start
	{
		//Set up the skill tree screen.
		mapdata TreeScreen = Game->LoadMapData(map, screen);
		bitmap SkillTree = Game->CreateBitmap(256, 256);
		untyped node[MAX_FFC*NODE_END];
		PopulateNodes(node, TreeScreen);
		//Draw the tree.
		SetBitmap(SkillTree, node);
		TangoEXVars[TANGOEX_FORCELAYER] = 7;
		//Operate cursor
		enum
		{
			CSR_X,			//X position of cursor
			CSR_Y,			//Y position of cursor
			CSR_MX,			//Last mouse X
			CSR_MY,			//Last mouse Y
			CSR_END
		};
		//Check for last node validity
		G[G_LASTNODE] = G[G_LASTNODE] > 1 && G[G_LASTNODE] <= 32 ? G[G_LASTNODE] : 1;
		int cursor[CSR_END] = {node[GetNode(G[G_LASTNODE],NODE_CENTERX)], node[GetNode(G[G_LASTNODE],NODE_CENTERY)]+SUBSCREEN_TOP, Input->Mouse[MOUSE_X], Input->Mouse[MOUSE_Y]};
		int curnode = 0; //Current node highlighted
		do
		{
			//Put here because by golly Tango loves to eat A inputs.
			bool apress = Input->Press[CB_A];
			//Run Tango here because Global Script does not run here.
			Tango_Update1();
			
			//Declare early so it can remain in scope when needed
			bool canbuy = false;
			Game->ClickToFreezeEnabled = false; //The game does not freeze when you click here
			bool kbmove = InputStickX() != 0 || InputStickY() != 0;
			bool mousemove = cursor[CSR_MX] != Input->Mouse[MOUSE_X] || cursor[CSR_MY] != Input->Mouse[MOUSE_Y];
			int prevnode = curnode; //Node the player touched last frame
			//Search for the a node that the cursor is over.
			for(int pos = MIN_FFC; pos <= MAX_FFC; pos ++)
			{
				//Node found.
				if(cursor[CSR_X] >= node[GetNode(pos, NODE_X)] && cursor[CSR_Y] >= node[GetNode(pos, NODE_Y)]+SUBSCREEN_TOP && cursor[CSR_X] < node[GetNode(pos, NODE_X)]+node[GetNode(pos, NODE_EFFECTWIDTH)] && cursor[CSR_Y] < node[GetNode(pos, NODE_Y)]+node[GetNode(pos, NODE_EFFECTHEIGHT)]+SUBSCREEN_TOP)
				{
					curnode = pos;
					G[G_LASTNODE] = pos; //Write to the last node index in the global array.
					break;
				}
				//Node not found.
				if(pos == MAX_FFC)
					curnode = 0;
			}
			//The cursor is freeform and can be moved with either mouse or keyboard. In the case of keyboard the cursor snaps to position if the player ends input while on a node. When the cursor is pointing to a node it is highlighted, showing its information to you.
			//Press the A button or Left Click on a node you can buy (have sufficient coins or can reach) to select it. When selected you are given a prompt to accept or decline the purchase. You can navigate between the options through using the arrow keys (up or down) or by mousing over.
			//Keyboard movement
			cursor[CSR_X] += InputStickX()*1.5;
			cursor[CSR_Y] += InputStickY()*1.5;
			//Mouse moved, use the mouse's position.
			if(mousemove)
			{
				cursor[CSR_X] = Input->Mouse[MOUSE_X];
				cursor[CSR_Y] = Input->Mouse[MOUSE_Y];
			}
			if(curnode > 0) 
			{
				//Check to see if the node can be brought ahead of time.
				canbuy = UpgradeCanBuy(curnode, node);
				if(curnode != prevnode)
				{
					Audio->PlaySound(SFX_CURSOR);
					//Display upgrade text
					char32 upgtext[UPGRADE_BUFFER];
					GetUpgradeText(upgtext, Character::GetCharArrayIndex(G[G_CHARID], Character::UpgVar(curnode-1, Character::UPGRADE_ID)), Character::GetCharArrayIndex(G[G_CHARID], Character::UpgVar(curnode-1, Character::UPGRADE_MISC)));
					ShowItemString(upgtext, DESCBOX_X+4, DESCBOX_Y+4+SUBSCREEN_TOP);
				}
				//Select node and do purchase prompt if can be brought.
				if((apress || Input->Mouse[MOUSE_LEFT]) && canbuy)
				{
					Audio->PlaySound(SFX_PLACE);
					//Ask the player if they want to confirm the purchase.
					if(ConfirmPurchase(SkillTree))
						PurchaseUpgrade(curnode-1, SkillTree, node, TreeScreen);
				}
				//Ring the buzzer.
				else if((apress || Input->Mouse[MOUSE_LEFT]))
				{
					Audio->PlaySound(SFX_ERROR);
				}
				//No movement from either keyboard or mouse while hovering over a node, snap to node.
				if(!kbmove && !mousemove)
				{
					cursor[CSR_X] = node[GetNode(curnode, NODE_CENTERX)];
					cursor[CSR_Y] = node[GetNode(curnode, NODE_CENTERY)]+SUBSCREEN_TOP;
				}
			}
			//Clear the textbox if moved off a node
			else if(curnode != prevnode)
			{
				Tango_ClearSlot(TANGO_SLOT_TEXTBOX);
			}
			
			//Clamp cursor position.
			cursor[CSR_X] = Clamp(cursor[CSR_X], SCREEN_LEFT, SCREEN_RIGHT);
			cursor[CSR_Y] = Clamp(cursor[CSR_Y], SUBSCREEN_TOP, SCREEN_BOTTOM);
			
			SkillTree->Blit(7, RT_SCREEN, 0, 0, 256, 256, 0, SUBSCREEN_TOP, 256, 256, 0, 0, 0, BITDX_NORMAL, 0,  false);
			//Draw cursor tile
			Screen->FastTile(7, cursor[CSR_X], cursor[CSR_Y], CURSOR_TILE+(curnode>0&&canbuy?1:0), 7, OP_OPAQUE);
			
			Waitdraw();
			//Record the mouse's position this frame for the next frame
			cursor[CSR_MX] = Input->Mouse[MOUSE_X];
			cursor[CSR_MY] = Input->Mouse[MOUSE_Y];
			Tango_Update2();
			Waitframe();
		}
		until(Input->Press[CB_B] || Input->Press[CB_START]); //Return to the subscreen when you press *start*
		TangoEXVars[TANGOEX_FORCELAYER] = -1; //Disable the forced layer.
		Tango_ClearSlot(TANGO_SLOT_TEXTBOX); //Clear the textbox slot
		Game->ClickToFreezeEnabled = true; //Reenable ClickToFreeze
		//Unpress these buttons
		Input->Press[CB_B] = false;
		Input->Press[CB_START] = false;
	} //SkillTree::Operate end
	//Draws the elements to the bitmap.
	void SetBitmap(bitmap bmp, int node) //SkillTree::SetBitmap start
	{
		//Tile offsets for the icons
		enum
		{
			CTRL_DPAD,
			CTRL_MOUSE,
			CTRL_DRAG,
			CTRL_ABTN = 20,
			CTRL_BBTN,
			CTRL_SBTN,
			CTRL_LCLK = 40,
			CTRL_COIN = 60
		};
		//Draw the character's tile, name and coin counter
		char32 charbuff[20];
		enum
		{
			CHEX_COLOUR, //Text colour
			CHEX_COLOR = 0,	//Different spelling
			CHEX_FONT,	//Because Reikon also did this with the character names.
			CHEX_END	//End of array
		};
		int charexdata[CHEX_END]; //Extra character data 
		switch (G[G_CHARID])
		{
			case Character::CHAR_LUANJA:
			{
				strcat(charbuff, "Luanja");
				charexdata[CHEX_COLOUR] = C_WHITE;	//Placeholder, until Ether decides on a colour
				charexdata[CHEX_FONT] = FONT_Z3; //Placeholder until Ether decides on a font
				break;
			}
			case Character::CHAR_HELENA:
			{
				strcat(charbuff, "Helena");
				charexdata[CHEX_COLOUR] = 0x64;
				charexdata[CHEX_FONT] = FONT_SHERWOOD;
				break;
			}
		}
		bmp->DrawString(2, CHARNAME_X, CHARNAME_Y, charexdata[CHEX_FONT], charexdata[CHEX_COLOUR], -1, TF_RIGHT, charbuff, OP_OPAQUE, SHD_OUTLINEDPLUS, C_BLACK); //Name is drawn
		bmp->FastTile(2, CHARNAME_X, CHARNAME_Y, TILE_HERO_WALK+Character::GetCharArrayIndex(G[G_CHARID], Character::CHARACTER_TILEOFF)+3, 6, OP_OPAQUE); //Tile is drawn
		itemdata coindat = Game->LoadItemData(I_COIN);
		bmp->FastTile(2, CHARNAME_X+20, CHARNAME_Y, coindat->Tile, coindat->CSet, OP_OPAQUE); //Coin counter tile drawn.
		bmp->DrawInteger(2, CHARNAME_X+38, CHARNAME_Y+6, FONT_Z3SMALL, C_WHITE, -1, -1, -1, Game->Counter[CR_COINS], 0, OP_OPAQUE); //Coin counter
		for(int fcmb = 1; fcmb <= 32; fcmb ++)
		{
			bool brought = Character::GetCharArrayIndex(G[G_CHARID], Character::UpgVar(fcmb-1, Character::UPGRADE_BROUGHT)); //Has the upgrade been brought yet?
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
						//Right now this code is real ugly. Might stuff this into a function call later.
						//Draw the first line.
						//To fix later - A bug that causes the line to freak out and begin drawing from X=0 under certain circumstances. Right now it can be worked around by adding a bend position to the FFC metadata but it will be fixed later.
						bmp->Rectangle(brought ? 1 : 0, node[GetNode(fcmb,NODE_CENTERX)], node[GetNode(fcmb,NODE_CENTERY)]-Floor(LINE_THICKNESS/2), (ydif == 0 ? node[GetNode(refval,NODE_CENTERX)] : node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)])-LINE_THICKNESS, node[GetNode(fcmb,NODE_CENTERY)]+Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0), brought ? C_WHITE : C_GREY, 1, 0, 0, 0, true, OP_OPAQUE);
						//The source and target combo's centers are not on the same Y axis, draw the bend.
						if(ydif != 0)
						{
							//Draw the first corner bit.
							SafeArc(bmp, brought ? 1 : 0, node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)]-LINE_THICKNESS, node[GetNode(fcmb,NODE_CENTERY)]+(ydif<0 ? Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0) : -(Floor(LINE_THICKNESS/2))), LINE_THICKNESS-1, 0, (ydif<0?90:-90), brought ? C_WHITE : C_GREY, 1, 0, 0, 0, true, true, OP_OPAQUE);
							//Draw the vertical line
							bmp->Rectangle(brought ? 1 : 0, node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)]-LINE_THICKNESS, node[GetNode(fcmb,NODE_CENTERY)]+(ydif<0 ? Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0) : -(Floor(LINE_THICKNESS/2))), node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)]-1, node[GetNode(refval,NODE_CENTERY)]+(ydif<0 ? -(Floor(LINE_THICKNESS/2)) : Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0)), brought ? C_WHITE : C_GREY, 1, 0, 0, 0, true, OP_OPAQUE);
							//Draw the second corner bit.
							SafeArc(bmp, brought ? 1 : 0, node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)]-1, node[GetNode(refval,NODE_CENTERY)]+(ydif<0 ? -(Floor(LINE_THICKNESS/2)) : Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0)), LINE_THICKNESS-1, 180, (ydif<0?270:90), brought ? C_WHITE : C_GREY, 1, 0, 0, 0, true, true, OP_OPAQUE);
							//Draw the final horizontal line.
							bmp->Rectangle(brought ? 1 : 0, node[GetNode(fcmb,NODE_UNLOCK1_BEND+unlock*2)], node[GetNode(refval,NODE_CENTERY)]-Floor(LINE_THICKNESS/2), node[GetNode(refval,NODE_CENTERX)], node[GetNode(refval,NODE_CENTERY)]+Floor(LINE_THICKNESS/2)-(LINE_THICKNESS%2==0?1:0), brought ? C_WHITE : C_GREY, 1, 0, 0, 0, true, OP_OPAQUE);
						}
					}
				}
				//Draw the combo
				bmp->DrawCombo(2, node[GetNode(fcmb, NODE_X)], node[GetNode(fcmb, NODE_Y)], node[GetNode(fcmb, NODE_DATA)]+(brought?1:0), node[GetNode(fcmb, NODE_TILEWIDTH)], node[GetNode(fcmb, NODE_TILEHEIGHT)], 0, -1, -1, 0, 0, 0, 0, 0, true, OP_OPAQUE);
				//Draw the upgrade type icon in front of it
				int upgradeicon = Character::GetUpgradeIcon(Character::GetCharArrayIndex(G[G_CHARID], Character::UpgVar(fcmb-1, Character::UPGRADE_ID)));
				if(upgradeicon > 0)
					bmp->FastTile(2, node[GetNode(fcmb, NODE_X)]+node[GetNode(fcmb, NODE_EFFECTWIDTH)]-12, node[GetNode(fcmb, NODE_Y)]+node[GetNode(fcmb, NODE_EFFECTHEIGHT)]-14, upgradeicon, 0, OP_OPAQUE);
				//GetUpgradeIcon(int id)
				if(!brought) //Not brought, display price tag.
				{
					char32 price[] = "%i";
					char32 buff[4];
					sprintf(buff, price, Character::GetCharArrayIndex(G[G_CHARID], Character::UpgVar(fcmb-1, Character::UPGRADE_PRICE)));
					bmp->DrawString(2, node[GetNode(fcmb, NODE_X)]+node[GetNode(fcmb, NODE_EFFECTWIDTH)]/2, node[GetNode(fcmb, NODE_Y)]+node[GetNode(fcmb, NODE_EFFECTHEIGHT)]+2, FONT_Z3SMALL, C_WHITE, -1, TF_NORMAL, buff, OP_OPAQUE, SHD_OUTLINEDPLUS, C_BLACK);
					bmp->FastTile(2, node[GetNode(fcmb, NODE_X)]+node[GetNode(fcmb, NODE_EFFECTWIDTH)]/2-8, node[GetNode(fcmb, NODE_Y)]+node[GetNode(fcmb, NODE_EFFECTHEIGHT)], CONTROL_ICON+CTRL_COIN, 7, OP_OPAQUE); //Coin icon
				}
			}
		}
		//Stat block draws.
		bmp->FastTile(2, STATBOX_TILE_X, STATBOX_TILE_Y, TILE_STAT_ATTACK, 7, OP_OPAQUE);
		bmp->DrawInteger(2, STATBOX_TILE_X+10, STATBOX_TILE_Y+2, FONT_Z3SMALL, C_WHITE, -1, -1, -1, G[G_ATTACK], 0, OP_OPAQUE);
		bmp->FastTile(2, STATBOX_TILE_X, STATBOX_TILE_Y+10, TILE_STAT_DEFENSE, 7, OP_OPAQUE);
		bmp->DrawInteger(2, STATBOX_TILE_X+10, STATBOX_TILE_Y+12, FONT_Z3SMALL, C_WHITE, -1, -1, -1, G[G_DEFENSE], 0, OP_OPAQUE);
		bmp->FastTile(2, STATBOX_TILE_X, STATBOX_TILE_Y+20, TILE_STAT_SPEED, 7, OP_OPAQUE);
		bmp->DrawInteger(2, STATBOX_TILE_X+10, STATBOX_TILE_Y+22, FONT_Z3SMALL, C_WHITE, -1, -1, -1, G[G_SPEED], 0, OP_OPAQUE);
		bmp->FastTile(2, STATBOX_TILE_X, STATBOX_TILE_Y+30, TILE_STAT_MAGIC, 9, OP_OPAQUE);
		bmp->DrawInteger(2, STATBOX_TILE_X+10, STATBOX_TILE_Y+32, FONT_Z3SMALL, C_WHITE, -1, -1, -1, G[G_MAGIC], 0, OP_OPAQUE);
		//Incoming icon and string draws
		//bmp->Rectangle(0, 0, 224-CONTROL_BOX_HEIGHT, bmp->Width, 224, C_BLACK, 1, 0, 0, 0, true, OP_OPAQUE);
		//Icon and strings
		bmp->FastTile(0, CONTROL_START_X, 224-CONTROL_BOX_HEIGHT+1, CONTROL_ICON+CTRL_DPAD, 11, OP_OPAQUE);	//DPad
		bmp->DrawString(0, CONTROL_START_X+8, 224-CONTROL_BOX_HEIGHT+2, FONT_Z3SMALL, C_WHITE, -1, TF_NORMAL, "/", OP_OPAQUE, SHD_NORMAL, C_BLACK); //Proceeding slash.
		bmp->FastTile(0, CONTROL_START_X+11, 224-CONTROL_BOX_HEIGHT, CONTROL_ICON+CTRL_MOUSE, 11, OP_OPAQUE);	//Mouse
		bmp->FastTile(0, CONTROL_START_X+18, 224-CONTROL_BOX_HEIGHT, CONTROL_ICON+CTRL_DRAG, 11, OP_OPAQUE);	//Drag
		bmp->DrawString(0, CONTROL_START_X+29, 224-CONTROL_BOX_HEIGHT+2, FONT_Z3SMALL, C_WHITE, -1, TF_NORMAL, ": Move cursor.", OP_OPAQUE, SHD_NORMAL, C_BLACK); //Move cursor.
		
		bmp->FastTile(0, CONTROL_START_X+100, 224-CONTROL_BOX_HEIGHT+1, CONTROL_ICON+CTRL_ABTN, 8, OP_OPAQUE); //A Button
		bmp->DrawString(0, CONTROL_START_X+108, 224-CONTROL_BOX_HEIGHT+2, FONT_Z3SMALL, C_WHITE, -1, TF_NORMAL, "/", OP_OPAQUE, SHD_NORMAL, C_BLACK); //Proceeding slash
		bmp->FastTile(0, CONTROL_START_X+111, 224-CONTROL_BOX_HEIGHT, CONTROL_ICON+CTRL_LCLK, 11, OP_OPAQUE); //Left click
		bmp->DrawString(0, CONTROL_START_X+118, 224-CONTROL_BOX_HEIGHT+2, FONT_Z3SMALL, C_WHITE, -1, TF_NORMAL, ": Select.", OP_OPAQUE, SHD_NORMAL, C_BLACK); //Select.
		
		bmp->FastTile(0, CONTROL_START_X+158, 224-CONTROL_BOX_HEIGHT+1, CONTROL_ICON+CTRL_BBTN, 9, OP_OPAQUE); //B Button
		bmp->DrawString(0, CONTROL_START_X+166, 224-CONTROL_BOX_HEIGHT+2, FONT_Z3SMALL, C_WHITE, -1, TF_NORMAL, "/", OP_OPAQUE, SHD_NORMAL, C_BLACK); //Proceeding slash
		bmp->FastTile(0, CONTROL_START_X+169, 224-CONTROL_BOX_HEIGHT+1, CONTROL_ICON+CTRL_SBTN, 11, OP_OPAQUE); //Start
		bmp->DrawString(0, CONTROL_START_X+177, 224-CONTROL_BOX_HEIGHT+2, FONT_Z3SMALL, C_WHITE, -1, TF_NORMAL, ": Cancel.", OP_OPAQUE, SHD_NORMAL, C_BLACK); //Cancel.
		
		//Draw the boxes below the skill tree.
		DrawBoxScale(0, bmp, {DESCBOX_TILE, 3, 3}, 6, C_BLACK, DESCBOX_X, DESCBOX_Y, DESCBOX_WIDTH, DESCBOX_HEIGHT, {OP_OPAQUE, OP_OPAQUE});
		DrawBoxScale(0, bmp, {STATBOX_TILE, 3, 3}, 6, C_BLACK, STATBOX_X, STATBOX_Y, STATBOX_WIDTH, STATBOX_HEIGHT, {OP_OPAQUE, OP_OPAQUE});
		//DrawBoxScale(0, bmp, {NAMEBOX_TILE, 3, 3}, 6, C_BLACK, NAMEBOX_X, NAMEBOX_Y, NAMEBOX_WIDTH, NAMEBOX_HEIGHT, {OP_OPAQUE, OP_OPAQUE});
		//DrawBoxScale(0, bmp, {COINBOX_TILE, 3, 3}, 6, C_BLACK, COINBOX_X, COINBOX_Y, COINBOX_WIDTH, COINBOX_HEIGHT, {OP_OPAQUE, OP_OPAQUE});
	} //SkillTree::SetBitmap end
	//Gets the upgrade text for the currently highlighted node.
	void GetUpgradeText(char32 buff, int upgrade, int misc) //SkillTree::GetUpgradeText start
	{
		//String of the correct size
		if(IsValidArray(buff) && SizeOfArray(buff) >= UPGRADE_BUFFER)
		{
			switch(upgrade)
			{
				//Character's Special upgrade.
				case SKILL_SPECIAL:
				{
					//Different strings for every character.
					switch(G[G_CHARID])
					{
						case Character::CHAR_HELENA:
						{
							strcat(buff, "((Duelist))@26Signatures induce fewer invulnerability frames if a single enemy is on screen.");
							return;
						}
					}
				}
				case SKILL_ATTACKUP:
				{
					char32 upatk = "((Attack +%d))@26Your Attack stat is raised by %d.";
					sprintf(buff, upatk, misc, misc);
					return;
				}
				case SKILL_DEFENSEUP:
				{
					char32 updef = "((Defense +%d))@26Your Defense stat is raised by %d.";
					sprintf(buff, updef, misc, misc);
					return;
				}
				case SKILL_SPEEDUP:
				{
					char32 upspd = "((Speed +%d))@26Your Movement Speed is raised by %d.";
					sprintf(buff, upspd, misc, misc);
					return;
				}
				case SKILL_MAGICREGEN:
				{
					char32 upmag = "((Magic Regen +%d))@26Your Magic Regen speed is raised by %d.";
					sprintf(buff, upmag, misc, misc);
					return;
				}
				case SKILL_STRONGTECH:
				{
					char32 stech = "((Strong Technology %i%%))@26Technology attacks do %i%% more damage.";
					sprintf(buff, stech, misc, misc);
					return;
				}
				case SKILL_CHEAPTECH:
				{
					char32 ctech = "((Cheap Technology %i%%))@26Technology spells cost %i%% less magic.";
					sprintf(buff, ctech, misc, misc);
					return;
				}
				case SKILL_STRONGMETAL:
				{
					char32 smet = "((Strong Metal %i%%))@26Metal attacks do %i%% more damage.";
					sprintf(buff, smet, misc, misc);
					return;
				}
				case SKILL_CHEAPMETAL:
				{
					char32 cmet = "((Cheap Metal %i%%))@26Metal spells cost %i%% less magic.";
					sprintf(buff, cmet, misc, misc);
					return;
				}
			}
		}
	}//SkillTree::GetUpgradeText end
	//Populates (and revalidates) the node array
	void PopulateNodes(untyped node, mapdata TreeScreen) //SkillTree::PopulateNodes start
	{
		//Validate the array as the node array.
		if(IsValidArray(node) && SizeOfArray(node) == MAX_FFC*NODE_END)
		{
			//Cycle through the FFCs and populate the data array.
			for(int fcmb = MIN_FFC; fcmb <= MAX_FFC; fcmb ++)
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
					node[(fcmb-1)*NODE_END+NODE_MODICON] = TreeScreen->GetFFCInitD(fcmb, 0);
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
					//This is a bit more involved. The game checks to see if the node has been brought and then unlocks the nodes connected. Node 1 is always available for purchase.
					if(fcmb == 1)
					{
						node[(fcmb-1)*NODE_END+NODE_CANREACH] = true;
					}
					//Node purchased
					if(Character::GetCharArrayIndex(G[G_CHARID], Character::UpgVar(fcmb-1, Character::UPGRADE_BROUGHT)))
					{
						//Examine the unlocks.
						for(int unlock = 0; unlock < 4; unlock ++)
						{
							int refval = node[GetNode(fcmb, NODE_UNLOCK1+unlock*2)];
							if(refval > 0) //Unlock points to a valid node, unlock it.
							{
								node[GetNode(refval, NODE_CANREACH)] = true;
							}
						}
					}
				}
			}
		}
	}
	//SkillTree::PopulateNodes end
	//Runs the dialogue prompt to ask the player if they want to confirm their purchase. This will need to be optimized later.
	bool ConfirmPurchase(bitmap SkillTree) //SkillTree::ConfirmPurchase start
	{
		int timer = 0; //Continually counts up or down.
		int confirm = 0; //If set to above 0, choice is confirmed and menu is closed. 1 = No, 2 = Yes
		//Set up the menu elements
		Tango_InitializeMenu();
		Tango_AddMenuChoice(1, DIALOGUE_X-DIALOGUE_WIDTH/2+DIALOGUE_TEXT_XOFF+5, DIALOGUE_Y-DIALOGUE_HEIGHT/2+DIALOGUE_TEXT_YOFF+15); //No
		Tango_AddMenuChoice(2, DIALOGUE_X-DIALOGUE_WIDTH/2+DIALOGUE_TEXT_XOFF+52, DIALOGUE_Y-DIALOGUE_HEIGHT/2+DIALOGUE_TEXT_YOFF+15); //Yes
		Tango_SetMenuCursor(DIALOGUE_ARROW_COMBO, 7); //Set the menu cursor
		Tango_SetMenuSFX(SFX_CURSOR, SFX_PLACE, 0); //Set its sound effects
		Tango_SetMenuFlags(TANGO_MENU_CAN_CANCEL); //Can cancel the menu
		//Press redirects.
		enum
		{
			PSR_MX,			//Int: Last mouse X
			PSR_MY,			//Int: Last mouse Y
			PSR_TIMER,		//Int: Mouse active timer
			PSR_CD,			//Int: Mouse cooldown timer
			PSR_END
		};
		untyped pressredirect[PSR_END];
		do
		{
			int xorigin = DIALOGUE_X-(DIALOGUE_WIDTH/DIALOGUE_EXTIME*Min(timer, 20))/2;
			int yorigin = DIALOGUE_Y-(DIALOGUE_HEIGHT/DIALOGUE_EXTIME*Min(timer, 20))/2;
			CONFIG MSA_TIME = 60; //Mouse stays active for 20 frames after losing movement
			CONFIG MSA_CDTIME = 10; //Mouse enters 5 frame cooldown.
			if(Tango_MenuIsActive() && Input->Press[CB_START]) //Pressing Start presses the B button as well
				Input->Press[CB_B] = true;
			//Mouse moved, is now active
			if(Tango_MenuIsActive() && pressredirect[PSR_MX] != Input->Mouse[MOUSE_X] || pressredirect[PSR_MY] != Input->Mouse[MOUSE_Y])
				pressredirect[PSR_TIMER] = MSA_TIME;
			if(Tango_MenuIsActive() && Input->Mouse[MOUSE_LEFT] && pressredirect[PSR_TIMER] > 0 && pressredirect[PSR_CD] <= 0) //Clicking left 
			{
				//This is hardcoded. If we wind up doing more menus that use mouse movement I'ma build a proper system for this. Seems fairly feasible in Tango.
				//No
				if(Input->Mouse[MOUSE_X] >= xorigin+DIALOGUE_TEXT_XOFF+9 && Input->Mouse[MOUSE_Y] >= yorigin+DIALOGUE_TEXT_YOFF+15 && Input->Mouse[MOUSE_X] < xorigin+DIALOGUE_TEXT_XOFF+18 && Input->Mouse[MOUSE_Y] < yorigin+DIALOGUE_TEXT_XOFF+20)
				{
					if(Tango_GetCurrentMenuChoice() != 1) //Set the menu choice appropriately
					{
						Tango_SetMenuCursorPosition(0);
						pressredirect[PSR_CD] = MSA_CDTIME;
					}
					else
						Input->Press[CB_A] = true; //Press the button.
				}
				//Yes
				else if(Input->Mouse[MOUSE_X] >= xorigin+DIALOGUE_TEXT_XOFF+56 && Input->Mouse[MOUSE_Y] >= yorigin+DIALOGUE_TEXT_YOFF+15 && Input->Mouse[MOUSE_X] < xorigin+DIALOGUE_TEXT_XOFF+67 && Input->Mouse[MOUSE_Y] < yorigin+DIALOGUE_TEXT_XOFF+20)
				{
					if(Tango_GetCurrentMenuChoice() != 2) //Set the menu choice appropriately
					{
						Tango_SetMenuCursorPosition(1);
						pressredirect[PSR_CD] = MSA_CDTIME;
					}
					else
						Input->Press[CB_A] = true; //Press the button.
				}
			}
			//Tango_SetMenuCursorPosition(int pos)
			
			//Loop runs all the Tango updates while the dialogue is active
			Tango_Update1();
			SkillTree->Blit(7, RT_SCREEN, 0, 0, 256, 256, 0, SUBSCREEN_TOP, 256, 256, 0, 0, 0, BITDX_NORMAL, 0,  false);
			//Draw the enlarging box
			DrawBoxScale(7, {DIALOGUE_TILE, 3, 3}, 6, C_BLACK, xorigin, yorigin, DIALOGUE_WIDTH/DIALOGUE_EXTIME*Min(timer, 20), DIALOGUE_HEIGHT/DIALOGUE_EXTIME*Min(timer, 20), {OP_OPAQUE, OP_OPAQUE});
			if(timer >= DIALOGUE_EXTIME) //Activate the menu and draw the strings.
			{
				if(timer == DIALOGUE_EXTIME)
					Tango_ActivateMenu(); //Activate the menu
				
				//Draw strings
				Screen->DrawString(7, xorigin+DIALOGUE_TEXT_XOFF, yorigin+DIALOGUE_TEXT_YOFF, FONT_Z3SMALL, C_WHITE, -1, TF_NORMAL, "Purchase upgrade?", OP_OPAQUE, SHD_OUTLINEDPLUS, C_BLACK);
				Screen->DrawString(7, xorigin+DIALOGUE_TEXT_XOFF+9, yorigin+DIALOGUE_TEXT_YOFF+15, FONT_Z3SMALL, C_WHITE, -1, TF_NORMAL, "No", OP_OPAQUE, SHD_OUTLINEDPLUS, C_BLACK);
				Screen->DrawString(7, xorigin+DIALOGUE_TEXT_XOFF+56, yorigin+DIALOGUE_TEXT_YOFF+15, FONT_Z3SMALL, C_WHITE, -1, TF_NORMAL, "Yes", OP_OPAQUE, SHD_OUTLINEDPLUS, C_BLACK);
				//
				if(!Tango_MenuIsActive() && confirm == 0) //Menu exited
				{
					timer = DIALOGUE_EXTIME;
					confirm = Tango_GetLastMenuChoice(); //Escapes the menu selection
				}
			}
			//Mouse active, display the cursor
			if(Tango_MenuIsActive() && pressredirect[PSR_TIMER] > 0)
				Screen->FastTile(7, Input->Mouse[MOUSE_X], Input->Mouse[MOUSE_Y], CURSOR_TILE, 7, OP_OPAQUE);
			Waitdraw();
			//Record the mouse's position this frame for the next frame
			pressredirect[PSR_MX] = Input->Mouse[MOUSE_X];
			pressredirect[PSR_MY] = Input->Mouse[MOUSE_Y];
			Tango_Update2();
			if(confirm == 0)
				timer ++; //Increment timer.
			else
				timer -= timer>=0?1:0; //Decrement timer.
			pressredirect[PSR_TIMER] -= pressredirect[PSR_TIMER]>0?1:0; //Decrement mouse active timer.
			pressredirect[PSR_CD] -= pressredirect[PSR_CD]>0?1:0; //Decrement mouse cooldown timer.
			Waitframe();
		}
		until(confirm > 0 && timer <= 0);
		Tango_DeactivateMenu();
		Tango_InitializeMenu();
		return confirm == 2 ? true : false;
	}
	//SkillTree::ConfirmPurchase end
	//Returns a pointer to somewhere within the node array.
	//fcmb = FFC referenced
	//offset = Offset from the base index to read the pointer from
	int GetNode(int fcmb, int offset)
	{
		return ((fcmb-1)*NODE_END+offset);
	}
	//Returns true if you can buy the upgrade
	bool UpgradeCanBuy(int id, int node)
	{
		using namespace Character;
		return node[GetNode(id, NODE_CANREACH)] && !GetCharArrayIndex(G[G_CHARID], UpgVar(id-1, UPGRADE_BROUGHT)) && Game->Counter[CR_COINS] >= GetCharArrayIndex(G[G_CHARID], UpgVar(id-1, UPGRADE_PRICE));
	}
	//Purchase an upgrade.
	void PurchaseUpgrade(int id, bitmap bit, int node, mapdata TreeScreen)
	{
		if(Game->Counter[CR_COINS] >= Character::GetCharArrayIndex(G[G_CHARID], Character::UpgVar(id, Character::UPGRADE_PRICE)))
		{
			//Register upgrade as brought
			Character::SetCharArrayIndex(G[G_CHARID], Character::UpgVar(id, Character::UPGRADE_BROUGHT), true);
			Audio->PlaySound(SFX_SECRET);
			Game->Counter[CR_COINS] -= Character::GetCharArrayIndex(G[G_CHARID], Character::UpgVar(id, Character::UPGRADE_PRICE)); //Spend the coins
			Character::UpdateStats(Character::ReturnCharacterArray(G[G_CHARID])); //Update stats
			PopulateNodes(node, TreeScreen); //Update the nodes.
			ClearBitmap(bit);
			SetBitmap(bit, node);
		}
		//Insufficent coins.
		else
			Game->PlaySound(SFX_ERROR);
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
	SKILL_SWIFTSWIM,		//+xx% Speed in water
	SKILL_HYDROPHILE,		//Can attack from water. Naiya's passive in Yuurand
	SKILL_WATERSILVER2,		//Second Water Silver passive
	//Ice skills
	SKILL_CRYOKINETIC,		//Immunity to Ice terrain. Mato's passive in Yuurand
	SKILL_FREEZE,			//Ice projectiles freeze weak enemies. Trait of Emily's ice Bow, Eli's Ice Gun and IIRC B.B.'s Arctic Wind attack from Yuurand. Property of Holm's upgraded Ice Conduit in Reikon.
	SKILL_ICESHIELD,		//Ice projectiles can block projectiles. One of Hera's skills in Yuurand and replicates the original Flake Shield behaviour in Yuurei. 
	//Astral skills
	SKILL_ASTRALBRONZE,		//Astral Bronze passive
	SKILL_RETRIBUTION,		//The next cast of Purge targets the last enemy to hit you with +xx damage on its next beam. Astral signatures interact differently with this skill.
	SKILL_ASTRALSILVER2,	//Second Astral Silver passive.
*/