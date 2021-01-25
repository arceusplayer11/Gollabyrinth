itemdata script DroneItem
{
	void run()
	{
		for (int i = 1; i <= Screen->NumLWeapons(); ++i)
		{
			lweapon loadlw = Screen->LoadLWeapon(i);
			if (loadlw->Script == Game->GetLWeaponScript("RemoteDrones")) 
			{
				Quit();
			}
		}
		lweapon handler= Screen->CreateLWeapon(LW_SCRIPT10);
		handler->Script = Game->GetLWeaponScript("RemoteDrones");
		handler->InitD[0] = 1;
		handler->InitD[1] = this->Script;
	}
}

const int SFX_DRONEMOVE = 74;
const int SFX_DRONESTAY = 11;
const int SPR_DRONE = 106;

lweapon script RemoteDrones
{
	void run(int ishandler, int itemid)
	{
		if (ishandler)
		{
			this->HitXOffset = -1000;
			this->DrawXOffset = -1000;
			this->CollDetection = false;
			this->X = Hero->X;
			this->Y = Hero->Y;
			int drones = 2;
			for (int q = 0; q < drones && IsUsingItem(itemid); ++q)
			{
				lweapon drone = Screen->CreateLWeapon(LW_SCRIPT2);
				drone->X = Hero->X;
				drone->Y = Hero->Y;
				drone->Script = Game->GetLWeaponScript("RemoteDrones");
				drone->InitD[1] = itemid;
				for (int i = 0; i < 20 && IsUsingItem(itemid); ++i)
				{
					Waitframe();
				}
			}
		}
		else
		{
			this->Damage = 4;
			this->Dir = 8;
			this->CollDetection = false;
			this->UseSprite(SPR_DRONE);
			int dirx = 0;
			int diry = 0;
			int angle;
			while(true)
			{
				dirx = 0;
				diry = 0;
				if (Input->Button[CB_UP] && !Input->Button[CB_DOWN]) diry = -1;
				if (Input->Button[CB_DOWN] && !Input->Button[CB_UP]) diry = 1;
				if (Input->Button[CB_LEFT] && !Input->Button[CB_RIGHT]) dirx = -1;
				if (Input->Button[CB_RIGHT] && !Input->Button[CB_LEFT]) dirx = 1;
				
				angle = Angle(0, 0, dirx, diry);
				if (dirx == 0 && diry == 0) angle = DirAngle(Hero->Dir);
				Audio->PlaySound(SFX_DRONEMOVE);
				for (int i = 0; i < 8; ++i)
				{
					this->X += VectorX(6, angle);
					this->Y += VectorY(6, angle);
					DroneWaitframe(this);
				}
				for (int i = 0; i < 3; ++i)
				{
					unless (IsUsingItem(itemid))
					{
						lweapon explode = Screen->CreateLWeapon(LW_BOMBBLAST);
						explode->Damage = this->Damage;
						explode->X = this->X;
						explode->Y = this->Y;
						this->DeadState = WDS_DEAD;
						Quit();
					}
					DroneWaitframes(this, 20);
				}
				unless (IsUsingItem(itemid))
				{
					lweapon explode = Screen->CreateLWeapon(LW_BOMBBLAST);
					explode->Damage = this->Damage;
					explode->X = this->X;
					explode->Y = this->Y;
					this->DeadState = WDS_DEAD;
					Quit();
				}
			}
		}
		this->DeadState = WDS_DEAD;					
		Quit();
	}
	void DroneWaitframe(lweapon this)
	{
		if (this->DeadState == WDS_DEAD)
		{
			lweapon explode = Screen->CreateLWeapon(LW_BOMBBLAST);
			explode->Damage = this->Damage;
			explode->X = this->X;
			explode->Y = this->Y;
		}
		Waitframe();
	}
	void DroneWaitframes(lweapon this, int frames)
	{
		for (int i = 0; i < frames; ++i)
		DroneWaitframe(this);
	}
}