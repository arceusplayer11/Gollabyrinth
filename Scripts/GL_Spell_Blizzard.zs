itemdata script BlizzardItem
{
	void run()
	{
		for (int i = 1; i <= Screen->NumLWeapons(); ++i)
		{
			lweapon loadlw = Screen->LoadLWeapon(i);
			if (loadlw->Script == Game->GetLWeaponScript("Blizzard")) 
			{
				Quit();
			}
		}
		lweapon handler= Screen->CreateLWeapon(LW_SCRIPT10);
		handler->Script = Game->GetLWeaponScript("Blizzard");
		handler->InitD[0] = this->Script;
	}
}

const int SFX_BLIZZARD = 6;
const int SPR_BLIZZARD = 83;

lweapon script Blizzard
{
	void run(int itemid)
	{
		this->HitXOffset = -1000;
		this->DrawXOffset = -1000;
		this->CollDetection = false;
		this->X = Hero->X;
		this->Y = Hero->Y;
		int range = 64;
		while (IsUsingItem(itemid))
		{
			if (G[G_ANIM] % 32 < 2) Audio->PlaySound(SFX_BLIZZARD);
			lweapon blizz = Screen->CreateLWeapon(LW_SCRIPT2);
			blizz->X = Hero->X;
			blizz->Y = Hero->Y;
			blizz->Damage = 3;
			blizz->Dir = Hero->Dir;
			blizz->Script = Game->GetLWeaponScript("LWeaponLifespan");
			blizz->UseSprite(SPR_BLIZZARD);
			blizz->Step = Rand(125, 300);
			blizz->Angular = true;
			blizz->Angle = DegtoRad(DirAngle(Hero->Dir) + Rand(-30, 30)); 
			blizz->InitD[0] = Ceiling(range/(blizz->Step/100));
			blizz->InitD[2] = 1;
			Waitframes(2);
		}
		
		this->DeadState = WDS_DEAD;					
		Quit();
	}
}