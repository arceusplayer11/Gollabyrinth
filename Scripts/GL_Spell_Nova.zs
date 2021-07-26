//This may or may not get rewritten depending on where we're going with the spell system.

//Sets up the Nova spell.
itemdata script NovaItem
{
	void run()
	{
		for (int i = 1; i <= Screen->NumLWeapons(); ++i)
		{
			lweapon loadlw = Screen->LoadLWeapon(i);
			if (loadlw->Script == Game->GetLWeaponScript("Nova")) //Another Nova cannot be charged if one is already active
			{
				Quit();
			}
		}
		//Launch the weapon script.
		lweapon handler = Screen->CreateLWeapon(LW_SCRIPT10);
		handler->Script = Game->GetLWeaponScript("Nova");
		handler->InitD[0] = this->Script;
	}
}

const int SFX_NOVA = 61;	//The first sound in a set of five sounds that Nova uses. Right now it uses the Sound Wave charging sounds.
const int SPR_NOVA = 88;	//The first sprite in a set of four sprites that Nova uses. They should go in the following order: Charging sprite, Vertical facing sprite, Horizontal facing sprite, explosion sprite. The charging sprite goes progressively faster the longer the charge is held.

lweapon script Nova
{
	void run(int itemid)
	{
		this->HitXOffset = -1000;
		this->DrawXOffset = -1000;
		this->CollDetection = false;
		this->X = Hero->X;
		this->Y = Hero->Y;
		lweapon Nova = Screen->CreateLWeapon(LW_SCRIPT2); //Spawn the charging graphic
		Nova->CollDetection = false;
		Nova->UseSprite(SPR_NOVA);
		//Hide the Nova's actual sprite
		Nova->DrawXOffset = -1000;
		int timer = 0;
		//Nova charge.
		while (IsUsingItem(itemid) && Nova->isValid())
		{
			//Position the charging shot in front of the player
			Nova->X = Hero->X+InFrontX(Hero->Dir, 8);
			Nova->Y = Hero->Y+InFrontY(Hero->Dir, 8);
			Nova->Damage = 10;
			//Increase the size and intensity of the charge orb
			if(timer > 0 && timer <= 120 && timer%60 == 0)
			{
				Nova->OriginalTile += 2;
				Nova->ASpeed -= 4;
			}
			//Cycle through the charge sounds.
			if(timer >= 66 && (timer-66)%18 == 0)
				Audio->PlaySound(SFX_NOVA+(Min(Div(timer-66, 18), 3))); //Cap it at the fourth charge sound
			//Draw the tile as overlapping or underlapping
			DrawLayerFix::FastTile(Hero->Dir == DIR_UP ? 2 : 3, Nova->X, Nova->Y-2, Nova->Tile, Nova->CSet, OP_OPAQUE); //Superimpose the tile over the player.
			timer ++;
			Waitframe();
		}
		//Insufficient time charged or the Nova weapon is removed prematurely, remove the charge shot and cancel the script.
		if(timer < 120 || !Nova->isValid())
		{
			if(Nova->isValid())
				Remove(Nova);
			Quit();
		}
		//The shot now fires
		//Shot graphic setting
		Nova->UseSprite(SPR_NOVA+1);
		Nova->OriginalTile += Hero->Dir*2;
		Nova->CollDetection = true;
		Nova->Dir = Hero->Dir;
		Nova->Step = 250;
		Nova->DrawXOffset = 0; //Reset draw offset
		Audio->PlaySound(SFX_NOVA+4); //Shot sound
		bool collide = false;
		while (Nova->isValid() && isOnScreen(Nova->X, Nova->Y) && !collide)
		{
			Nova->DeadState = -1; //Persistent until needed to die
			//Check for collision with NPCs
			for(int nme = 1; nme <= Screen->NumNPCs(); nme ++)
			{
				npc target = Screen->LoadNPC(nme);
				if(isTargetable(target) && Collision(Nova, target))
				{
					collide = true;
					break;
				}
			}
			Waitframe();
		}
		Nova->Step = 0;
		//Nova->Dir == ToggleBlock(Nova->Dir); //The explosion cannot be blocked. To be implemented later.
		Nova->DrawXOffset = -1000; //Hide its sprite. We're drawing an explosion in its place.
		timer = 0;
		spritedata explosion = Game->LoadSpriteData(SPR_NOVA+2);
		//Explody fun times ahead. Hope you packed some popcorn!
		CONFIG BLAST_DRAW = 96;	//The blast is drawn this size
		CONFIG BLAST_WIDTH = BLAST_DRAW; //Width of the blast
		CONFIG BLAST_HEIGHT = BLAST_WIDTH*0.75; //Height of the blast. This is set based off the placeholder Rose Ultima/Meteor explosion sprites.
		while (Nova->isValid() && isOnScreen(Nova->X, Nova->Y) && timer < 90)
		{
			//Set and expand the weapon's hitbox to match the explosion
			Nova->HitWidth = Round(BLAST_WIDTH/48*Min(timer, 48));
			Nova->HitXOffset = 8-Round((BLAST_WIDTH/2)/48*Min(timer, 48));
			Nova->HitHeight = Round(BLAST_HEIGHT/48*Min(timer, 48));
			Nova->HitYOffset = 8-Round((BLAST_HEIGHT/2)/48*Min(timer, 48));
			//Screen->Rectangle(int layer, int x, int y, int x2, int y2, int color, float scale, int rx, int ry, int rangle, false, OP_OPAQUE);	//DEBUG draw.
			
			//Placeholder Rose Ultima/Meteor explosion for now. Will need to get better explody sprites later.
			DrawLayerFix::DrawTile(2, Nova->X+8-(BLAST_DRAW/2)/48*Min(timer, 48), Nova->Y+8-(BLAST_DRAW/2)/48*Min(timer, 48), explosion->Tile, 4, 4, explosion->CSet, BLAST_DRAW/48*Min(timer, 48), BLAST_DRAW/48*Min(timer, 48), 0, 0, 0, 0, true, OP_TRANS);
			if(timer%15 == 0)
			{
				Audio->PlaySound(SFX_RUMBLE);
				Screen->Quake = 1;
			}
			timer ++;
			Nova->DeadState = -1; //Still persistent
			Waitframe();
		}
		//Ensure Nova is cleared after this
		if(Nova->isValid())
			Remove(Nova);
		//Kill the launcher weapon
		this->DeadState = WDS_DEAD;					
		Quit();
	}
}