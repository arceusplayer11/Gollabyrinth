const int SFX_FLAMETONGUE = 13;

/*
Okay, so the way Flametongue works is that it summons a weapons script that acts as a handler
But I multipurposed this script to also control the individual flamesegment
The main handler summons these tiny frames and assigns the handler script to each,
But flags each one to act as the subhandler. The subhandler handles the movement.
*/

itemdata script Flametongue
{
	void run()
	{
		if (Hero->Action != LA_ATTACKING && !Hero->Stun && Hero->MP >= 16)
		{
			int baseangle = DirAngle(Hero->Dir);
			lweapon flametonguehandler = Screen->CreateLWeapon(LW_SCRIPT10);
			flametonguehandler->Script = Game->GetLWeaponScript("FlameTongueHandler");
			flametonguehandler->InitD[0] = baseangle;
			flametonguehandler->InitD[1] = 10;
			flametonguehandler->InitD[5] = G[G_ANIM]; //Unique ID used for tracking the children flames
			flametonguehandler->X = Hero->X+VectorX(8,baseangle);
			flametonguehandler->Y = Hero->Y+VectorY(8,baseangle);
			Hero->MP -= 16;
		}
	}
}

lweapon script FlameTongueHandler
{
	void run(int angle, int extend, int dist, int angleoffset, int stopangle, int uid)
	{
		if (dist == 0)
		{
			this->CollDetection = false;
			this->DrawXOffset = -1000;
			this->HitXOffset = -1000;
			int timer = 0;
			for (int i = 1; i <= extend; ++i)
			{
				Audio->PlaySound(SFX_FLAMETONGUE);
				lweapon flamesegment = Screen->CreateLWeapon(LW_FIRE);
				flamesegment->Script = Game->GetLWeaponScript("FlameTongueHandler");
				flamesegment->InitD[0] = angle;
				flamesegment->InitD[1] = 45;
				flamesegment->InitD[2] = i*8;
				flamesegment->InitD[3] = -(i*22);
				flamesegment->InitD[5] = uid;
				flamesegment->X = this->X;
				flamesegment->Y = this->Y;
				flamesegment->Damage = 2;
				for (int q = 0; q < 10; ++q)
				{
					if (timer < 45)
					{
						Hero->Action = LA_NONE;		//Gotta do the NoneAttack dance!
						Hero->Action = LA_ATTACKING;	//You need to do it this way to keep Link in the attack animation
						++timer;
					}
					MPWaitframe();
				}
			}
			for (int i = 1; i <= Screen->NumLWeapons(); ++i)
			{
				lweapon flameload = Screen->LoadLWeapon(i);
				unless (flameload->Script == Game->GetLWeaponScript("FlameTongueHandler") && flameload != this && flameload->InitD[5] == uid) continue;
				flameload->InitD[4] = 1;
			}
			if (this->isValid()) this->DeadState = WDS_DEAD;
		}
		else
		{
			int angle2;
			int angle3;
			int basex = this->X;
			int basey = this->Y;
			for (int i = 0; i < extend && this->isValid(); ++i)
			{
				unless(this->InitD[4]) angle3 = angleoffset+G[G_ANIM]*8;
				else angle3+=2;
				angle2 = angle + VectorY(30, angle3);
				this->X = basex + VectorX(dist, angle2);
				this->Y = basey + VectorY(dist, angle2);
				Waitframe();
			}
			if (this->isValid()) this->DeadState = WDS_DEAD;
		}
	}
}