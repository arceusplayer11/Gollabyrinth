itemdata script SpectralBarrierItem
{
	void run()
	{
		for (int i = 1; i <= Screen->NumLWeapons(); ++i)
		{
			lweapon specload = Screen->LoadLWeapon(i);
			if (specload->Script == Game->GetLWeaponScript("SpectralBarrier")) 
			{
				Quit();
			}
		}
		lweapon spechandle= Screen->CreateLWeapon(LW_SCRIPT10);
		spechandle->Script = Game->GetLWeaponScript("SpectralBarrier");
		spechandle->InitD[0] = 1;
		spechandle->InitD[1] = this->Script;
	}
}

lweapon script SpectralBarrier
{
	void run(int ishandler, int itemid, int id, int anglespeed1, int anglespeed2, int release)
	{
		if (ishandler)
		{
			this->HitXOffset = -1000;
			this->DrawXOffset = -1000;
			this->CollDetection = false;
			this->X = Hero->X;
			this->Y = Hero->Y;
			for (int i = 0; i < 3; ++i)
			{
				lweapon specorb = Screen->CreateLWeapon(LW_SCRIPT2);
				specorb->X = Hero->X;
				specorb->Y = Hero->Y;
				specorb->Script = Game->GetLWeaponScript("SpectralBarrier");
				specorb->InitD[2] = i;
				specorb->InitD[3] = (i*2)-1;
				switch(i)
				{
					case 0:
						specorb->InitD[4] = 1.5;
						break;
					case 1:
						specorb->InitD[4] = 1;
						break;
					case 2:
						specorb->InitD[4] = 2;
						break;						
				}
			}
			do
			{
				for (int q = Screen->NumLWeapons(); q > 0; --q)
				{
					lweapon specload = Screen->LoadLWeapon(q);
					if (specload->Script == Game->GetLWeaponScript("SpectralBarrier") && specload != this) break;
					if (q <= 1) 
					{
						this->DeadState = WDS_DEAD;
						Quit();
					}
				}
				Waitframe();
			}until(IsPressingItem(itemid))
			Trace(1);
			for (int i = 1; i <= Screen->NumLWeapons(); ++i)
			{
				lweapon specload = Screen->LoadLWeapon(i);
				unless (specload->Script == Game->GetLWeaponScript("SpectralBarrier") && specload != this) continue;
				specload->InitD[5] = 1;
			}
		}
		else
		{
			this->Damage = 2;
			this->Dir = 8;
			int angle = Rand(60) + (60*id);
			int orbit = 0;
			int orbitdist = 20;
			anglespeed2*=3;
			this->UseSprite(92);
			switch(id)
			{
				case 0:
					this->CSet = 7;
					break;
				case 1:
					this->CSet = 10;
					break;
				case 2:
					this->CSet = 11;
					break;	
			}
			while(true)
			{
				this->X = Hero->X + VectorX(VectorY(orbitdist, orbit), angle);
				this->Y = Hero->Y + VectorY(VectorY(orbitdist, orbit), angle);
				if (this->InitD[5])
				{
					orbitdist+=2;
					this->DeadState = -1;
					if (orbitdist > 120 && (orbit > 85 && orbit < 95 || orbit > 265 && orbit < 275)) break;
				}
				this->DrawXOffset = -1000;
				if (orbit >= 90 && orbit < 270) Screen->FastTile(2, this->X, this->Y, this->Tile, this->CSet, OP_OPAQUE);
				else Screen->FastTile(3, this->X, this->Y, this->Tile, this->CSet, OP_OPAQUE);
				if (G[G_ANIM] % 4 == 0)
				{
					lweapon afterimage = Screen->CreateLWeapon(LW_SCRIPT10);
					afterimage->CollDetection = false;
					afterimage->X = this->X;
					afterimage->Y = this->Y;
					afterimage->CSet = this->CSet;
					afterimage->Tile = this->Tile;
					afterimage->OriginalTile = this->Tile;
					afterimage->DrawStyle = DS_PHANTOM;
					afterimage->Script = Game->GetLWeaponScript("LWeaponLifespan");
					afterimage->DrawXOffset = -1000;
					afterimage->InitD[0] = 12;
					afterimage->InitD[1] = 1;
				}
				angle += anglespeed1;
				orbit += anglespeed2;
				orbit%=360;
				angle%=360;
				Waitframe();
			}
		}
		this->DeadState = WDS_DEAD;					
		Quit();
	}
}