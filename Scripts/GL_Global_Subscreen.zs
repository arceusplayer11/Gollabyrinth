/*
Okay, so the way the subscreen works:

Positions are based on both an X and Y value. These correspond to the position x and y on the subscreen; so the first slot of row 1 would be 0,0;
the first slot of row 2 would be 0, 1, etc. You assign items to these slots via "AssignSlot(int item, int x, int y);",
For example, if I want to assign item 24 to the 4th item of row 3, I would use "AssignSlot(24, 3, 2);".

All the assigning of items should happen in the AssignItems() function.

Note that "Items" in this sense aren't actual real ZC items; they are fake items. Please see GL_ItemButtons for further information on how they work.

These subscreen scripts need to be assigned to each and every DMap. Yes, it's dumb, I told Zoria and Rob they should have an auto assign, etc.
I might go and set all the dmaps in advance at some point in dev whenever I have free time just so nobody has to worry about it.

"Why a dmap script", you ask? Because they are hands down the best way of handling crap, despite the setup. They automatically freeze the screen when the subscreen
would normally be opened and unfreeze it as soon as they are done. They are actually really powerful, and it saves us a headache having to add in exceptions to stuff
when stuff should run and etc.

By freeze the screen, I mean freeze *everything*. Including the global. They are incredibly useful and powerful.
*/

const int SUBSCREEN_WIDTH = 8;
const int SUBSCREEN_HEIGHT = 4;
const int SUBSCREEN_CENTERX = 120;
const int SUBSCREEN_CENTERY = 72;

/*
These constants allow for complete control over how wide and tall the subscreen is. 
The subscreen will change automatically based on these constants.
CenterX and CenterY point to the center of the subscreen. It might be offset by -8 because tiles.
Account for them depending on the width and height we choose, or else the subscreen might be weird.
*/

const int SFX_SUBSCREEN_ASSIGN = 21;
const int SFX_SUBSCREEN_SELECT = 5;

dmapdata script ActiveSubscreen
{
	void run()
	{
		AssignItems();
		int subscreenx = SUBSCREEN_CENTERX+8-(SUBSCREEN_WIDTH*8);
		int subscreeny = SUBSCREEN_CENTERY+8-(SUBSCREEN_HEIGHT*8);
		
		//Create a fade-to-black effect as the subscreen opens by stacking translucent black box draws
		repeat(2)
		{
			Screen->Rectangle(7, 0, 0, 255, 176, C_BLACK, 1, 0, 0, 0, true, OP_TRANS);
			Waitframe();
		}
		repeat(2)
		{
			Screen->Rectangle(7, 0, 0, 255, 176, C_BLACK, 1, 0, 0, 0, true, OP_TRANS);
			Screen->Rectangle(7, 0, 0, 255, 176, C_BLACK, 1, 0, 0, 0, true, OP_TRANS);
			Waitframe();
		}
		do
		{
			//Open Skill Tree
			if(Input->Press[CB_SKILLTREE])
			{
				SkillTree::Operate(1, 0x71);
			}
			
			//Process cursor movement inputs.
			if (Input->Press[CB_UP]) {--G[G_ACTIVE_POSY]; Audio->PlaySound(SFX_SUBSCREEN_SELECT);}
			else if (Input->Press[CB_DOWN]) {++G[G_ACTIVE_POSY]; Audio->PlaySound(SFX_SUBSCREEN_SELECT);}
			if (Input->Press[CB_LEFT]) {--G[G_ACTIVE_POSX]; Audio->PlaySound(SFX_SUBSCREEN_SELECT);}
			else if (Input->Press[CB_RIGHT]) {++G[G_ACTIVE_POSX]; Audio->PlaySound(SFX_SUBSCREEN_SELECT);}
			
			//Bound the cursor to the subscreen box
			if (G[G_ACTIVE_POSX] < 0) G[G_ACTIVE_POSX]+=SUBSCREEN_WIDTH;
			if (G[G_ACTIVE_POSY] < 0) G[G_ACTIVE_POSY]+=SUBSCREEN_HEIGHT;
			G[G_ACTIVE_POSX]%=SUBSCREEN_WIDTH;
			G[G_ACTIVE_POSY]%=SUBSCREEN_HEIGHT;
			
			//Subscreen backdrop
			Screen->Rectangle(7, 0, 0, 255, 176, C_BLACK, 1, 0, 0, 0, true, OP_OPAQUE);
			//Screen->DrawScreen(7, 1, 0x70, 0, 0, 0);
			DrawBox(7, 36400, 0, subscreenx-16, subscreeny-16, SUBSCREEN_WIDTH+2, SUBSCREEN_HEIGHT+2, OP_OPAQUE);
			
			//Process item selection. This makes sure that item slots are swapped if you would assign a button to an item that is already selected.
			if (Input->Press[CB_A]) 
			{
				Audio->PlaySound(SFX_SUBSCREEN_ASSIGN);
				int temp = G[G_MENUARRAY+G[G_ACTIVE_POSX]+(G[G_ACTIVE_POSY]*32)];
				if (G[G_BUTTON_B] == temp) G[G_BUTTON_B] = G[G_BUTTON_A];
				else if (G[G_BUTTON_L] == temp) G[G_BUTTON_L] = G[G_BUTTON_A];
				else if (G[G_BUTTON_R] == temp) G[G_BUTTON_R] = G[G_BUTTON_A];
				G[G_BUTTON_A] = temp;
			}
			else if (Input->Press[CB_B]) 
			{
				Audio->PlaySound(SFX_SUBSCREEN_ASSIGN);
				int temp = G[G_MENUARRAY+G[G_ACTIVE_POSX]+(G[G_ACTIVE_POSY]*32)];
				if (G[G_BUTTON_A] == temp) G[G_BUTTON_A] = G[G_BUTTON_B];
				else if (G[G_BUTTON_L] == temp) G[G_BUTTON_L] = G[G_BUTTON_B];
				else if (G[G_BUTTON_R] == temp) G[G_BUTTON_R] = G[G_BUTTON_B];
				G[G_BUTTON_B] = temp;
			}
			else if (Input->Press[CB_L]) 
			{
				Audio->PlaySound(SFX_SUBSCREEN_ASSIGN);
				int temp = G[G_MENUARRAY+G[G_ACTIVE_POSX]+(G[G_ACTIVE_POSY]*32)];
				if (G[G_BUTTON_A] == temp) G[G_BUTTON_A] = G[G_BUTTON_L];
				else if (G[G_BUTTON_B] == temp) G[G_BUTTON_B] = G[G_BUTTON_L];
				else if (G[G_BUTTON_R] == temp) G[G_BUTTON_R] = G[G_BUTTON_L];
				G[G_BUTTON_L] = temp;
			}
			else if (Input->Press[CB_R]) 
			{
				Audio->PlaySound(SFX_SUBSCREEN_ASSIGN);
				int temp = G[G_MENUARRAY+G[G_ACTIVE_POSX]+(G[G_ACTIVE_POSY]*32)];
				if (G[G_BUTTON_A] == temp) G[G_BUTTON_A] = G[G_BUTTON_R];
				else if (G[G_BUTTON_B] == temp) G[G_BUTTON_B] = G[G_BUTTON_R];
				else if (G[G_BUTTON_L] == temp) G[G_BUTTON_L] = G[G_BUTTON_R];
				G[G_BUTTON_R] = temp;
			}
			
			//Draw item icons on the subscreen
			for(int x = 0; x < SUBSCREEN_WIDTH; ++x)
			{
				for(int y = 0; y < SUBSCREEN_HEIGHT; ++y)
				{
					Screen->FastTile(7, subscreenx + (x*16), subscreeny + (y*16), 39001+GetSlot(x, y), 0, OP_OPAQUE);
				}
			}
			
			//Cursor is drawn.
			Screen->FastCombo(7, subscreenx + (G[G_ACTIVE_POSX]*16), subscreeny + (G[G_ACTIVE_POSY]*16), 5123, 0, OP_OPAQUE);
			Waitframe();
		}
		until(Input->Press[CB_START]);
		
		//Fade the subscreen out
		repeat(2)
		{
			Screen->Rectangle(7, 0, 0, 255, 176, C_BLACK, 1, 0, 0, 0, true, OP_TRANS);
			Screen->Rectangle(7, 0, 0, 255, 176, C_BLACK, 1, 0, 0, 0, true, OP_TRANS);
			Waitframe();
		}
		repeat(2)
		{
			Screen->Rectangle(7, 0, 0, 255, 176, C_BLACK, 1, 0, 0, 0, true, OP_TRANS);
			Waitframe();
		}
	}
}

dmapdata script PassiveSubscreen
{
	void run()
	{
		while(true)
		{
			Screen->Rectangle(7, 131, -24, 146, -9, C_BLACK, 1, 0, 0, 0, true, OP_OPAQUE);	//Because the active subscreen takes a screenshot
			Screen->Rectangle(7, 131, -49, 146, -34, C_BLACK, 1, 0, 0, 0, true, OP_OPAQUE);	//of the screen before opening, the passive
			Screen->Rectangle(7, 106, -24, 121, -9, C_BLACK, 1, 0, 0, 0, true, OP_OPAQUE);	//needs to draw black rectangles where the
			Screen->Rectangle(7, 106, -49, 121, -34, C_BLACK, 1, 0, 0, 0, true, OP_OPAQUE);	//Items should be.
			Screen->FastTile(7, 131, -24, 39001+G[G_BUTTON_A], 0, OP_OPAQUE);
			Screen->FastTile(7, 106, -24, 39001+G[G_BUTTON_B], 0, OP_OPAQUE);
			Screen->FastTile(7, 106, -49, 39001+G[G_BUTTON_L], 0, OP_OPAQUE);
			Screen->FastTile(7, 131, -49, 39001+G[G_BUTTON_R], 0, OP_OPAQUE);
			Waitframe();
		}
	}
}

//! ASSIGN ITEMS TO THE SUBSCREEN HERE!
void AssignItems()
{
	AssignSlot(1, 0, 0);
	AssignSlot(2, 1, 0);
	AssignSlot(3, 2, 0);
	AssignSlot(4, 0, 1);
	AssignSlot(5, 1, 1);
	AssignSlot(6, 2, 1);
	AssignSlot(7, 3, 0);
}

void AssignSlot(int item, int x, int y)
{
	G[G_MENUARRAY+x+(y*32)] = item;
}

int GetSlot(int x, int y)
{
	return G[G_MENUARRAY+x+(y*32)];
}