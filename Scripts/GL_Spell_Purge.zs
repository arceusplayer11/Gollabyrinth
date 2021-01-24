/*
So originally the item script for Purge acted as a handler that summoned the beams.
However, I got a really weird crash when I tried to fire both it and flametongue at the same time.
I also realized that the way I handled item scripts meant that only one itemscript could run at a time.
So pre-empting any issues, I added a flag in the PurgeWeapon script that allows one to act as a controller,
and had the item script summon the controller. 

You know, it's really refreshing being able to summon a gazillion laser beams each with it's own code without
having to worry about running out of FFC slots. Just being able to *do* this stuff without doing roundabout
array shenanigan or etc is just... I didn't realize I needed this simplicity in my life.

I'm thinking I might give each button it's own dummy item associated with it (so 4 dummies) to run scripts to avoid
issues where only one can run at a time, but just in case we really should only run these item scripts for only one frame.
*/

const int SFX_PURGEBEAM = 52;
const int SFX_PURGEIMPACT = 3;

itemdata script Purge
{
	void run()
	{
		lweapon purge = Screen->CreateLWeapon(LW_SCRIPT10);
		purge->Script = Game->GetLWeaponScript("PurgeWeapon");
		purge->InitD[0] = 1;
		purge->InitD[1] = this->Script;
	}
}

lweapon script PurgeWeapon
{
	void run(int ishandler, int itemid)
	{
		if (ishandler) 				//Is this a handler weapon?
		{
			this->DrawXOffset = -1000;
			this->HitXOffset = -1000;
			this->CollDetection = false;
			this->X = Hero->X;
			this->Y = Hero->Y;
			int timing = 60;
			
			if (Hero->MP < 48) Quit();
			
			Hero->MP -= 48;
			
			do
			{
				CallHomingOrRandBeam();
				if (timing >= 60) for (int i = 0; i < timing && Hero->Action != LA_GOTHURTLAND && Hero->Action != LA_ATTACKING && IsUsingItem(itemid); ++i) MPWaitframe();
				else 
				{
					Hero->MP -= 4;
					PurgeWaitframes(timing, itemid);
				}
				if (timing > 5) timing -=5;
				unless (IsUsingItem(itemid) && Hero->Action != LA_GOTHURTLAND && Hero->MP > 4) break;
				Hero->MP -= 4;
				unless (Rand(3)) CallPlayerBeam();
				else CallHomingOrRandBeam();
				PurgeWaitframes(timing, itemid);
				if (timing > 5) timing -=5;
			
			}while (IsUsingItem(itemid) && Hero->Action != LA_GOTHURTLAND && Hero->MP > 4);
			while (Hero->DrawYOffset < 0) 
			{
				++Hero->DrawYOffset;
				Screen->FastCombo(2, Hero->X, Hero->Y, 5127, 8, OP_TRANS);
				Waitframe();
			}
		}
		else 					//If not, this is just a laser beam.
		{
			int color = C_HOLY + Rand(10); 		//Random light-themed color makes it look so cooool
			Audio->PlaySound(SFX_PURGEBEAM);
			int x = this->X + 8, y = this->Y + 8;
			int radius = 0;
			for (int i = 0; i < 32; i+=2)
			{
				if (i > 26) 			//Originally the circle ripple effect only appeared on impact, but it looks better having it slightly earlier
				{
					radius+=2;
					Screen->Circle(2, x, y, radius, color, 1, 0, 0, 0, false, OP_OPAQUE);
					if (radius > 2) Screen->Circle(2, x, y, radius-2, color, 1, 0, 0, 0, false, OP_OPAQUE);
					if (radius > 4) Screen->Circle(2, x, y, radius-4, color, 1, 0, 0, 0, false, OP_OPAQUE);
				}
				Screen->Rectangle(5, x-(i/4), 0, x+Max((i/4)-1, 0), y+1, color, 1, 0, 0, 0, true, OP_TRANS);
				Screen->Rectangle(5, x-(i/4)-1, 0, x+Max((i/4)-1, 0)+1, y, color, 1, 0, 0, 0, true, OP_TRANS);
				Screen->Rectangle(5, x-(i/4), 0, x+Max((i/4)-1, 0), y, color, 1, 0, 0, 0, true, OP_OPAQUE);
				if (i > 4)  			//This is to make it appear more rounded at the bottom.
				{
					Screen->Rectangle(5, x-(i/4)+1, 0, x+Max((i/4)-1, 0)-1, y+1, color, 1, 0, 0, 0, true, OP_OPAQUE);
					Screen->Rectangle(5, x-(i/4)+1, 0, x+Max((i/4)-1, 0)-1, y+2, color, 1, 0, 0, 0, true, OP_TRANS);
				}
				Waitframe();
			}
			Audio->PlaySound(SFX_PURGEIMPACT);
			lweapon purge = Screen->CreateLWeapon(LW_SCRIPT1);
			purge->X = x-7;							//x and y are the pixel center, so offset it a bit
			purge->Y = y-7;							//cause topleft corner is the sprite's x/y.
			purge->Damage = 4;
			purge->Step = 0;
			purge->Dir = 8;							//Dir is 8 so it pierces shields.
			purge->DrawXOffset = -1000;
			purge->Script = Game->GetLWeaponScript("LWeaponLifespan");	//At first I was sad lifespan didn't exist, but
			purge->InitD[0] = 4;						//holy fuck this was so easy and simple to write.
											//I'm so happy it exists.
			for (int i = 32; i > 0; i-=2)
			{
				radius+=2;
				Screen->Circle(2, x, y, radius, color, 1, 0, 0, 0, false, OP_OPAQUE);
				if (radius > 2) Screen->Circle(2, x, y, radius-2, color, 1, 0, 0, 0, false, OP_OPAQUE);
				if (radius > 4) Screen->Circle(2, x, y, radius-4, color, 1, 0, 0, 0, false, OP_OPAQUE);
				Screen->Rectangle(5, x-(i/4), 0, x+Max((i/4)-1, 0), y+1, color, 1, 0, 0, 0, true, OP_TRANS);
				Screen->Rectangle(5, x-(i/4), 0, x+Max((i/4)-1, 0), y+1, color, 1, 0, 0, 0, true, OP_TRANS);
				Screen->Rectangle(5, x-(i/4), 0, x+Max((i/4)-1, 0), y, color, 1, 0, 0, 0, true, OP_OPAQUE);
				if (i > 4) 
				{
					Screen->Rectangle(5, x-(i/4)+1, 0, x+Max((i/4)-1, 0)-1, y+1, color, 1, 0, 0, 0, true, OP_OPAQUE);
					Screen->Rectangle(5, x-(i/4)+1, 0, x+Max((i/4)-1, 0)-1, y+2, color, 1, 0, 0, 0, true, OP_TRANS);
				}
				Waitframe();
			}
			while (radius < 36)
			{
				radius+=2;
				if (radius < 32) Screen->Circle(2, x, y, radius, color, 1, 0, 0, 0, false, OP_OPAQUE);
				if (radius < 34) Screen->Circle(2, x, y, radius-2, color, 1, 0, 0, 0, false, OP_OPAQUE);
				if (radius < 36) Screen->Circle(2, x, y, radius-4, color, 1, 0, 0, 0, false, OP_OPAQUE);
				Waitframe();
			}
		}
		this->DeadState = WDS_DEAD;					//Weapon scripts should kill themselves 					
		Quit();								//Er, I don't mean that way. I mean when they should die.
	}									//...You know what I mean.
	void PurgeWaitframes(int frames, int itemid)
	{
		for (int i = 0; i < frames && Hero->Action != LA_GOTHURTLAND && IsUsingItem(itemid); ++i)
		{
			Hero->Stun = 8;
			Hero->Dir = DIR_DOWN;
			Screen->FastCombo(2, Hero->X, Hero->Y, 5127, 8, OP_TRANS);
			if (Hero->DrawYOffset > (-8 + VectorY(4, G[G_ANIM]*4))) --Hero->DrawYOffset;
			if (Hero->DrawYOffset < (-8 + VectorY(4, G[G_ANIM]*4))) ++Hero->DrawYOffset;
			bitmap B = InitOutline(Hero->Tile);									//Holy fuck the glowy effect
			MPWaitframe();												//It needs a waitframe between it.
			DrawOutline(B, Round(Hero->X+Hero->DrawXOffset), Round(Hero->Y + Hero->DrawYOffset), C_HOLY + Rand(10), OP_OPAQUE);	//Never again.
		}
	}
	
	bitmap InitOutline(int tile)					//This needs to run before the waitframe cause GetPixel is one pixel off.
	{
		bitmap B = Game->CreateBitmap(18, 18);
		B->FastTile(0, 1, 1, tile, 0, OP_OPAQUE);
		return B;
	}
	void DrawOutline(bitmap B, int x, int y, int color, int trans)	//This function means no matter the character sprite, the outline will be drawn properly
	{								//God this is probably so unoptimized.
		for (int q = 0; q < 18; ++q)				//But it saves needing to make an outline sprite for everyone.
		{							//Which is important if we want to easily add characters.
			for (int w = 0; w < 18; ++ w)
			{
				if (B->GetPixel(q,w)) continue;					//Check for adjacent pixels.
				if ((q >= 17 || !B->GetPixel(q+1,w)) 
				&& (q <= 0 || !B->GetPixel(q-1,w)) 
				&& (w >= 17 || !B->GetPixel(q,w+1)) 
				&& (w <= 0 || !B->GetPixel(q,w-1))) continue;
				Screen->PutPixel(2, x+q-1, y+w-1, color, 0, 0, 0, trans);	//Originally this was a putpixels function and this was messy.
			}									//But ultimately I'm drawing about 50 pixels at max.
		}										//Worst case scenario, assuming the worst possible sprite,
												//Only 192 draws at max would be used. Yes, I did the math.
												//(The worst possible sprite would be a dither)
												
		if (B->isAllocated()) B->Free();						//New bitmap handling means we should free them afterwards.
	}
	
	void CallPlayerBeam()	//Calls a beam around the player.
	{
		int angle = Rand(360);
		CallBeam(Hero->X+VectorX(Rand(8,24),angle), Hero->Y+Hero->DrawYOffset+VectorY(Rand(18,24),angle));
	}
	
	void CallHomingOrRandBeam() //Calls a beam on an enemy; if it can't find one then call one randomly.
	{
		unless (CallHomingBeam())
		{
			CallBeam(Rand(16, 240), Rand(16, 156));
		}
	}
	
	bool CallHomingBeam() //Calls a beam on an enemy; returns falls if it we can't get one.
	{
		int x, y;
		npc enemy = GetEnemy();
		unless (enemy) return false;
		x = enemy->X+enemy->HitXOffset+(enemy->HitWidth/2)-8;
		y = enemy->Y+enemy->HitYOffset+(enemy->HitHeight/2)-8;
		
		CallBeam(x+Rand(-4,4), y+Rand(-4,4));
		return true;
	}
	
	void CallBeam(int x, int y) //Calls a beam on an arbitrary X/Y position.
	{
		lweapon purge = Screen->CreateLWeapon(LW_SCRIPT10);
		purge->X = x;
		purge->Y = y;
		purge->Script = Game->GetLWeaponScript("PurgeWeapon");
		purge->CollDetection = false;
		purge->DrawXOffset = -1000;
		purge->HitXOffset = -1000;
	}
}