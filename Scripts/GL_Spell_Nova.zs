/*
Nova Spell, written by Orithan.
Plasma Element, Burn Damage
Charge up a ball of superheated Plasma energy and then fire it.
This may or may not get rewritten depending on where we're going with the spell system.
*/

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

CONFIG SFX_NOVA = 61;	//The first sound in a set of five sounds that Nova uses. Right now it uses the Sound Wave charging sounds.
CONFIG SPR_NOVA = 88;	//The first sprite in a set of four sprites that Nova uses. They should go in the following order: Charging sprite, Shot sprites, explosion sprite, sparkle sprite. The charging sprite goes progressively faster the longer the charge is held.

lweapon script Nova
{
	void run(int itemid)
	{
		//The following should be set in the item's metadata if we go the item route. I much prefer to do it on the item route.
		CONFIG NOVA_DAMAGE = 10;	//Nova's base damage. Placeholder
		CONFIG NOVA_COST = 64;		//Nova's base cost. Placeholder
		CONFIG NOVA_STEP = 250;		//Nova's base step speed.
		CONFIG NOVA_CHARGE_TIME = 120;	//Amount of time Nova takes to charge
		CONFIG NOVA_SFX_FREQ = 18;		//Amount of time between SFX played
		CONFIG NOVA_BLAST_TIME = 90;	//Amount of time Nova's explosion persists. It expands to full size in half the time
		CONFIG NOVA_BLAST_DRAW = 96;	//The blast is drawn this size
		//The following would not be part of the item's metadata
		CONFIG NOVA_BLAST_WIDTH = NOVA_BLAST_DRAW; //Width of the blast
		CONFIG NOVA_BLAST_HEIGHT = NOVA_BLAST_WIDTH*0.75; //Height of the blast. This is set based off the placeholder Rose Ultima/Meteor explosion sprites.
		int cost = Character::GetMagicCost(NOVA_COST, ELEMENT_NOVA); //Calculate total cost
		this->HitXOffset = -1000;
		this->DrawXOffset = -1000;
		this->CollDetection = false;
		this->X = Hero->X;
		this->Y = Hero->Y;
		lweapon Nova = Screen->CreateLWeapon(LW_SCRIPT2); //Spawn the charging graphic
		Nova->CollDetection = false;
		Nova->UseSprite(SPR_NOVA);
		Nova->Damage = Character::GetAttackDamage(NOVA_DAMAGE, ELEMENT_NOVA);
		//Hide the Nova's actual sprite
		Nova->DrawXOffset = -1000;
		int timer = 0;
		//Nova charge.
		while (IsUsingItem(itemid) && Nova->isValid() && Hero->MP >= cost)
		{
			//Position the charging shot in front of the player
			Nova->X = Hero->X+InFrontX(Hero->Dir, 10);
			Nova->Y = Hero->Y+InFrontY(Hero->Dir, 10);
			//Increase the size and intensity of the charge orb
			if(timer > 0 && timer <= NOVA_CHARGE_TIME && timer%(NOVA_CHARGE_TIME/2) == 0)
			{
				Nova->OriginalTile += 2;
				Nova->ASpeed -= 4;
			}
			//Cycle through the charge sounds.
			if(timer >= NOVA_CHARGE_TIME-(NOVA_SFX_FREQ*3) && (timer-(NOVA_CHARGE_TIME-(NOVA_SFX_FREQ*3)))%NOVA_SFX_FREQ == 0)
				Audio->PlaySound(SFX_NOVA+Min(Div(timer-(NOVA_CHARGE_TIME-(NOVA_SFX_FREQ*3)), NOVA_SFX_FREQ), 3)); //Cap it at the fourth charge sound
			//Draw the tile as overlapping or underlapping
			DrawLayerFix::FastTile(Hero->Dir == DIR_UP ? 2 : 3, Nova->X, Nova->Y-2, Nova->Tile, Nova->CSet, OP_OPAQUE); //Superimpose the tile over the player.
			timer ++;
			Waitframe();
		}
		//Insufficient time charged, insufficient Magic or the Nova weapon is removed prematurely, remove the charge shot and cancel the script.
		if(timer < NOVA_CHARGE_TIME || !Nova->isValid() || Hero->MP < cost)
		{
			if(Nova->isValid())
				Remove(Nova);
			Quit();
		}
		//The shot now fires
		//Shot graphic setting
		Hero->MP -= cost;
		Nova->UseSprite(SPR_NOVA+1);
		Nova->OriginalTile += Hero->Dir*2;
		Nova->CollDetection = true;
		Nova->Dir = Hero->Dir;
		Nova->Step = NOVA_STEP;
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
		while (Nova->isValid() && isOnScreen(Nova->X, Nova->Y) && timer < NOVA_BLAST_TIME)
		{
			//Set and expand the weapon's hitbox to match the explosion
			Nova->HitWidth = Round(NOVA_BLAST_WIDTH/48*Min(timer, 48));
			Nova->HitXOffset = 8-Round((NOVA_BLAST_WIDTH/2)/48*Min(timer, 48));
			Nova->HitHeight = Round(NOVA_BLAST_HEIGHT/48*Min(timer, 48));
			Nova->HitYOffset = 8-Round((NOVA_BLAST_HEIGHT/2)/48*Min(timer, 48));
			//Screen->Rectangle(int layer, int x, int y, int x2, int y2, int color, float scale, int rx, int ry, int rangle, false, OP_OPAQUE);	//DEBUG draw.
			
			//Placeholder Rose Ultima/Meteor explosion for now. Will need to get better explody sprites later.
			DrawLayerFix::DrawTile(2, Nova->X+8-(NOVA_BLAST_DRAW/2)/48*Min(timer, 48), Nova->Y+8-(NOVA_BLAST_DRAW/2)/48*Min(timer, 48), explosion->Tile, 4, 4, explosion->CSet, NOVA_BLAST_DRAW/48*Min(timer, 48), NOVA_BLAST_DRAW/48*Min(timer, 48), 0, 0, 0, 0, true, OP_TRANS);
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