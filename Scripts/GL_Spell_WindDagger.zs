const int SFX_WINDDAGGER = 1;
const int TILE_WINDDAGGER = 7653;

itemdata script WindDagger
{
	void run()
	{
		for (int i = 1; i <= Screen->NumLWeapons(); ++i)
		{
			lweapon windload = Screen->LoadLWeapon(i);
			if (windload->Script == Game->GetLWeaponScript("WindDaggerWeapon") && windload->InitD[0] > 0) Quit();
		}
		lweapon wdagger = Screen->CreateLWeapon(LW_SCRIPT10);
		wdagger->Script = Game->GetLWeaponScript("WindDaggerWeapon");
		wdagger->InitD[0] = 1;
		wdagger->InitD[2] = this->Script;
	}
}

lweapon script WindDaggerWeapon
{
	void run(int ishandler, int lifespan, int itemid)
	{
		this->DrawXOffset = -1000;
		if (ishandler)
		{
			this->HitXOffset = -1000;
			this->CollDetection = false;
			this->X = Hero->X;
			this->Y = Hero->Y;
			int timer = 0;
			
			do
			{
				if (timer % 3 == 0) Audio->PlaySound(SFX_WINDDAGGER);
				++timer;
				if (timer % 2 == 0) CreateWindDagger(Hero->X + 7 + VectorX(10, DirAngle(Hero->Dir)) + Rand(-6, 6), 
				Hero->Y + 7 + VectorY(10, DirAngle(Hero->Dir)) + Rand(-6, 6), Hero->Dir, 500, 2, 21);
				Waitframes(4);
			
			}while (IsUsingItem(itemid));
		}
		else
		{
			int LastXPos[10];
			int LastYPos[10];
			this->HitWidth = 1;
			this->HitHeight = 1;
			int color2 = C_GREEN2;
			for (int i = 0; i < 10; ++i)
			{
				LastXPos[i] = this->X;
				LastYPos[i] = this->Y;
			}
			for (int i = 0; i < lifespan; ++i)
			{
				for (int i = 9; i > 0; --i)
				{
					LastXPos[i] = LastXPos[i-1];
					LastYPos[i] = LastYPos[i-1];
				}
				LastXPos[0] = this->X;
				LastYPos[0] = this->Y;
				Screen->Line(3, this->X, this->Y, LastXPos[3], LastYPos[3], color2, 1, 0, 0, 0, OP_OPAQUE);
				
				Screen->FastTile(7, this->X - 6, this->Y - 6, TILE_WINDDAGGER+this->Dir, 7, OP_OPAQUE);
				Waitframe();
			}
		}
		this->DeadState = WDS_DEAD;				
		Quit();
	}
	void CreateWindDagger(int x, int y, int dir, int step, int damage, int lifespan)
	{
		lweapon winddagger = Screen->CreateLWeapon(LW_SCRIPT2);
		winddagger->X = x;
		winddagger->Y = y;
		winddagger->HitWidth = 1;
		winddagger->HitHeight = 1;
		winddagger->Dir = dir;
		winddagger->Step = step;
		winddagger->Damage = damage;
		winddagger->Script = Game->GetLWeaponScript("WindDaggerWeapon");
		winddagger->InitD[1] = lifespan;
	}
}
